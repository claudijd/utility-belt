require 'net/http'
require 'json'

# A quick and dirty script to enumerate injected env var
# values from all jobs on a Jenkins server

scheme = "https"
host = "192.168.1.1"
base_api_path = "/api/json?pretty=true"

uri = URI(scheme + "://" + host + base_api_path)
res = Net::HTTP.get_response(uri)
parsed_json = JSON.parse(res.body)

parsed_json['jobs'].each do |job|
  name = job['name']
  url = job['url']

  last_build_uri = URI(url + "lastBuild/injectedEnvVars/api/json?pretty=true")
  last_build_res = Net::HTTP.get_response(last_build_uri)

  # Handle case where not builds have been performed yet
  next if last_build_res.body.match(/Not Found/)

  last_build_parsed_json = JSON.parse(last_build_res.body)

  last_build_parsed_json['envMap'].each do |env_name, env_value|
    puts name.to_s + "," + url.to_s + "," + env_name.to_s + "," + env_value.to_s
  end

  # Try to be nice to Jenkins and not request deets too fast
  sleep 1
end
