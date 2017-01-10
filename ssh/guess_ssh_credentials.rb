require 'nmap/xml'
require 'json'
require 'net/ssh'

# Get the credentials we care about from SSH_GUESS_CREDENTIALS
credentials = []
if ENV['SSH_GUESS_CREDENTIALS']
  ENV['SSH_GUESS_CREDENTIALS'].split(",").each do |cred_pair|
    user, pass = cred_pair.split("/")
    credentials << {:username => user, :password => pass}
  end
else
  warn "Environment variable SSH_GUESS_CREDENTIALS not defined, exiting..."
  exit 1
end

# Get the services we want to perform SSH guessing for
services = []
Nmap::XML.new("scan.xml") do |xml|
  xml.each_up_host do |host|
    host.open_ports.each do |port|
      next if port.to_i != 22
      services << {:ip => host.ip, :port => port.to_i}
    end
  end
end

# For each service, test each set of credentials given
guessable_credentials = []

services.each do |service|
  credentials.each do |credentials|
    puts "Testing #{service[:ip]}:#{service[:port]}:#{credentials[:username]}:#{credentials[:password]}"
    begin
      ssh = Net::SSH.start(
              service[:ip],
              credentials[:username],
              :password => credentials[:password],
              :number_of_password_prompts => 0,
              :timeout => 3,
              :paranoid => Net::SSH::Verifiers::Null.new #avoid host-key mismatch issues due to duplicate keys
            )
      ssh.close
      guessable_credentials << {:ip => service[:ip], :port => service[:port], :username => credentials[:username], :password => credentials[:password]} 
    rescue Net::SSH::ConnectionTimeout
      break
    rescue Net::SSH::AuthenticationFailed,Net::SSH::Disconnect
      # this is ok, failure to auth is ideal in this context
    end
  end
end

if guessable_credentials.empty?
  puts "No guessable credentials detected"
  exit 0
else
  puts "Guessable credentials detected"
  puts JSON.pretty_generate(guessable_credentials)
  exit 1
end
