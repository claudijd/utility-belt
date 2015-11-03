require 'openssl'
require 'base64'

# A counter to monitor the number of
# calls we make to the encryption oracle
# to demonstrate work required
@count = 0
@encrypt_content = []

def encrypt(key, data)
  @count += 1
  @encrypt_content << data
  data = pkcs_pad(data, 16)
  cipher = OpenSSL::Cipher::Cipher.new("aes-128-ecb")
  cipher.encrypt
  cipher.key = key
  secret = cipher.update(data) << cipher.final
end

def decrypt(key, data)
  cipher = OpenSSL::Cipher::Cipher.new("aes-128-ecb")
  cipher.decrypt
  cipher.key = key
  secret = cipher.update(data) << cipher.final
end

def pkcs_pad(string, block_size)
  return string if string.size % block_size == 0
  pads = block_size - (string.size % block_size)
  string << "\x04" * pads
end

# These aren't "known" to us, but are used for PoC purposes
unknown_data = Base64.encode64("My voice is my passport")
key = Array.new(16){rand(36).to_s(36)}.join

dict = {}

# Full char set (insane mode!)
#chars = Array(1..255)
# Alpha/Num/Symbol
chars = Array(32..127)
padding = ("A" * 15)

chars.map { |char|
  blob = padding.dup
  blob << char.chr
  dict[encrypt(key, blob)[0,16]] = char.chr
}

plain_text_string = ""

Base64.decode64(unknown_data).each_char do |char|
  content = ("A" * 15) + char
  encrypted_content = encrypt(key, content)
  plain_text_string << dict[encrypted_content[0,16]]
end

puts "Your secret: " + plain_text_string
puts "Calls to \#encrypt: #{@count.to_s}"
# puts "Keys and strings to pass encryption oracle: "
# @encrypt_content.each do |content|
#   puts content.inspect
# end
