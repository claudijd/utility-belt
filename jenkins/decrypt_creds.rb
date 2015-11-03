# -*- coding: binary -*-

require 'digest/sha2'
require 'openssl'

# A Ruby adaption of tweksteen's decrypt.py used to decrypt Jenkins credentials
# Reference: https://raw.githubusercontent.com/tweksteen/jenkins-decrypt/master/decrypt.py

# Example output:
# $ ruby decrypt_creds.rb 2Alp+SzoZ9YDLjgUT8n6nkX9Xexa0MrYdFgi1dN3H5k= example_keys/
# [+] Decrypting hudson.util.Secret w/ master.key
# [+] Decrypting password w/ hudson.util.Secret
# [+] Jenkins Password is: claudijd

# Helper method to make AES ECB decrypting simple
def decrypt(key, data)
  cipher = OpenSSL::Cipher::Cipher.new("aes-128-ecb")
  cipher.decrypt
  cipher.key = key
  cipher.padding = 0
  secret = cipher.update(data) << cipher.final
  # unless secret.include?("::::MAGIC::::")
  #   raise StandardError, "Decryption failure"
  # end
  secret
end

def hexify(s)
  s.each_byte.map { |b| b.to_s(16) }.join
end

def unhexify(s)
 s.scan(/../).map { |x| x.hex.chr }.join
end

encoded_encrypted_password = ARGV[0] || "2Alp+SzoZ9YDLjgUT8n6nkX9Xexa0MrYdFgi1dN3H5k="

path = ARGV[1] || "example_keys/"
master_key = File.read(path + "master.key")
hudson_util_secret = File.read(path + "hudson.util.Secret")

hashed_master_key = Digest::SHA256.digest(master_key)[0,16]

puts "[+] Decrypting hudson.util.Secret w/ master.key"
plaintext_hudson_secret = decrypt(hashed_master_key, hudson_util_secret)
encrypted_password = encoded_encrypted_password.unpack('m')[0]

puts "[+] Decrypting password w/ hudson.util.Secret"
password_plaintext = decrypt(plaintext_hudson_secret, encrypted_password)

puts "[+] Jenkins Password is: " + password_plaintext.match(/(.*)::::MAGIC::::/)[1]
