#!/usr/bin/env ruby
require_relative 'lib/cipher_suites'

# Do a quick evaluation of cipher suites
example_raw_cipher_suites_hex = "c023c027003cc025c02900670040c009c013002f" +
                                "c004c00e00330032c02bc02f009cc02dc031009e" +
                                "00a2c008c012000ac003c00d00160013c007c011" +
                                "0005c002c00c000400ff"

raw_cipher_suites_hex = ARGV[0] || example_raw_cipher_suites_hex
cipher_suites = CipherSuites.new(raw_cipher_suites_hex)

puts "[+] MODERN Ciphers:"
cipher_suites.supported_ciphers.each do |supported_cipher|
  puts supported_cipher if MODERN_CAPABILITY.include?(supported_cipher)
end
puts ""

puts "[+] INTERMEDIATE Ciphers:"
cipher_suites.supported_ciphers.each do |supported_cipher|
  next if MODERN_CAPABILITY.include?(supported_cipher)
  puts supported_cipher if INTERMEDIATE_CAPABILITY.include?(supported_cipher)
end
puts ""

puts "[-] OLD BACKWARD COMPATIBLE Ciphers:"
cipher_suites.supported_ciphers.each do |supported_cipher|
  next if MODERN_CAPABILITY.include?(supported_cipher)
  next if INTERMEDIATE_CAPABILITY.include?(supported_cipher)
  puts supported_cipher if OLD_BACKWARD_CAPABILITY.include?(supported_cipher)
end
puts ""

puts "[-] Bad/Unknown/Other Ciphers:"
cipher_suites.supported_ciphers.each do |supported_cipher|
  next if MODERN_CAPABILITY.include?(supported_cipher)
  next if INTERMEDIATE_CAPABILITY.include?(supported_cipher)
  next if OLD_BACKWARD_CAPABILITY.include?(supported_cipher)
  puts supported_cipher
end
puts ""
