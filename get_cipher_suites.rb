#!/usr/bin/env ruby
require_relative 'lib/cipher_suites'

# Reasoning: there doesn't seem to be an easy way to export the human-friendly
# cipher names out of an SSL/TLS client hello packet from Wireshark.  Yes, it
# parses them, but trying to get the list of names to export into a report or
# just to share via email to an auditor or a vendor was a pain, so I created
# this little helper.

# Just an example, so you know what you're trying to export from Wireshark
#
# Select SSL Client Hello packet, drill down to CipherSuites node, right-click,
# copy, bytes, hex stream to populate your own string value
example_raw_cipher_suites_hex = "c023c027003cc025c02900670040c009c013002f" +
                                "c004c00e00330032c02bc02f009cc02dc031009e" +
                                "00a2c008c012000ac003c00d00160013c007c011" +
                                "0005c002c00c000400ff"

raw_cipher_suites_hex = ARGV[0] || example_raw_cipher_suites_hex
cipher_suites = CipherSuites.new(raw_cipher_suites_hex)
cipher_suites.print_supported_ciphers

# Example usage
# $ ruby get_cipher_suites.rb <= Just demonstrates the concept, need to provide your own string to have value
# $ ruby get_cipher_suites.rb c023c027003cc025c02900670040c009c013002fc004c00e00330032c02bc02f009cc02dc031009e00a2c008c012000ac003c00d00160013c007c0110005c002c00c000400ff
