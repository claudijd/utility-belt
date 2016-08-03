require 'net/http'
require 'uri'
require 'openssl'

sleep_interval = 2 # seconds between each guess
username = URI.escape("jclaudius@mozilla.com") # Test account
password_guess = URI.escape("test")

# dictionary = []
# # Stub dictionary with bogus creds
# 10.times { dictionary << (0...8).map { (65 + rand(26)).chr }.join}
# # Add a real credential for testing
# dictionary << URI.escape(password)

http = Net::HTTP.new('vreplay.mozilla.com', 443)
http.use_ssl = true
path = '/replay/login.html'


# GET request -> so the host can set his cookies
resp, data = http.get(path, nil)
set_cookies = resp.response['set-cookie'].split(",")
cookie = set_cookies.map {|set_cookie| set_cookie.split(";")[0]}.join(";")

#dictionary.each do |password_guess|
  data = "username=#{username}&password=#{password_guess}&Login=Login"
  headers = {
    'Cookie' => cookie,
    'Referer' => 'https://vreplay.mozilla.com/replay/login.html',
    'Content-Type' => 'application/x-www-form-urlencoded'
  }

  resp, data = http.post(path, data, headers)

  # require 'pry'
  # binding.pry

  if resp.body.match(/VidyoReplay Login/)
    puts "Authentication Failed with: " + password_guess
  # elsif resp.body.match(/Bugzilla Main Page/)
  #   puts "Authentication Succesful with: " + password_guess
  # elsif resp.body.match(/Account Locked/)
  #   puts "#{account} Bugzilla account is locked"
  #   exit
  else
    puts "Errored " + password_guess
    require 'pry'
    binding.pry
  end

  sleep sleep_interval
#end
