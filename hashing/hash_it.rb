require 'digest'

string = ARGV[0]

puts "Raw: " + string
puts "MD5: " + Digest::MD5.hexdigest(string)
puts "SHA1: " + Digest::SHA1.hexdigest(string)
puts "SHA256: " + Digest::SHA256.hexdigest(string)
