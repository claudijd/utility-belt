# A Ruby-based solver for Cryptopals challenge 12

require 'openssl'
require 'securerandom'
require 'base64'

class String
  def chunk(size)
    (0..(self.length-1)/size).map{|i|self[i*size,size]}
  end

  def decode64
    Base64.decode64(self)
  end
end

class BlackBox
  # Generate a random unknown key for blackbox encryption
  UNKNOWN_KEY = SecureRandom.hex.slice(0,16)
  UNKNOWN_STRING = "TG9yZW0gaXBzdW0gZG9sb3Igc2l0IGFtZXQsIGNvbnNlY3RldHV" +
                   "yIGFkaXBp\nc2NpbmcgZWxpdC4gUXVpc3F1ZSBzb2RhbGVzLCBt" +
                   "YXVyaXMgdmVsIG1vbGxp\ncyBzb2RhbGVzLCBhdWd1ZSB0b3J0b" +
                   "3IgZmVybWVudHVtIHNhcGllbiwgdml0\nYWUgc2VtcGVyIGZlbG" +
                   "lzIGp1c3RvIGluIGZlbGlzLiBDdXJhYml0dXIgZWdl\ndCBkaWN" +
                   "0dW0gZHVpLCBlZ2V0IGxvYm9ydGlzIGlwc3VtLiBOdWxsYW0gYW" +
                   "xp\ncXVhbSBhIHF1YW0gaWQgbW9sZXN0aWUuIE1hdXJpcyBsb2J" +
                   "vcnRpcyB0ZW1w\ndXMgaW1wZXJkaWV0LiBNb3JiaSBjb25ndWUg" +
                   "c2FwaWVuIGxpZ3VsYS4gTWF1\ncmlzIHZlbCBtYXNzYSB2dWxwd" +
                   "XRhdGUsIHNjZWxlcmlzcXVlIGxhY3VzIGF0\nLCB2ZWhpY3VsYS" +
                   "BuaXNsLiBEdWlzIG5vbiBjb252YWxsaXMgb2RpbywgZmFj\naWx" +
                   "pc2lzIGxhY2luaWEgbmlzaS4gVXQgcXVpcyBmZXVnaWF0IGxpZ3" +
                   "VsYSwg\ndXQgaWFjdWxpcyBzZW0uIEZ1c2NlIGRpYW0gbmliaCw" +
                   "gZmF1Y2lidXMgZWdl\ndCBjb25ndWUgYSwgdnVscHV0YXRlIGNv" +
                   "bnNlcXVhdCBtaS4gRG9uZWMgZWdl\ndCBpbnRlcmR1bSBmZWxpc" +
                   "y4="

  def initialize()
    @encryption_calls = 0
  end

  def encrypt(clear = "")
    @encryption_calls += 1
    cipher = OpenSSL::Cipher::AES.new(128, :ECB)
    cipher.encrypt
    cipher.key = UNKNOWN_KEY
    digest = clear + UNKNOWN_STRING.decode64
    encrypted = cipher.update(digest) + cipher.final
  end

  def encryption_calls
    @encryption_calls
  end
end

class Solver12
  def initialize(oracle)
    @oracle = oracle
  end

  def duplicate_blocks?(string, size)
    block_array = string.chunk(size)
    if block_array.select{ |e| block_array.count(e) > 1 }.uniq.empty?
      return false
    else
      return true
    end
  end

  def build_dictionary(prefix)
    dict = {}
    chars = (1..255).map {|c| c.chr}

    magic_string = chars.map {|char|
      blob = prefix.dup
      blob << char.chr
      blob
    }.join("")

    #magic_string = test_blocks.join("")
    encrypted_magic_string = @oracle.encrypt(magic_string)
    encrypted_magic_array = encrypted_magic_string.chunk(16)

    chars.each_with_index {|char, i|
      dict[encrypted_magic_array[i]] = char.chr
    }

    # chars.each do |char|
    #   plain_text = prefix + char
    #   cipher_text = @oracle.encrypt(plain_text)
    #   dict[cipher_text[0..(self.block_size - 1)]] = char
    # end

    return dict
  end

  # Borrowed this block size detection logic from onicrypt
  # Reference: https://github.com/onicrypt/cryptopals/blob/master/set2/prob12.rb#L65-L83
  def block_size
    trial_byte = "N"
    block_length = 1
    found = false
    prev_res = ""

    while not found
      res = @oracle.encrypt(trial_byte * block_length)[0..15]
      if res == prev_res
        found = true
        block_length -= 1
      else
        prev_res = res
        block_length += 1
      end
    end

    return block_length
  end

  def decrypt_block
    known_bytes = ""

    self.block_size.times do
      known_bytes << decrypt_byte(known_bytes)
    end

    return known_bytes
  end

  def decrypt_byte(known_bytes_of_block)
    padding = "A" * ((self.block_size - known_bytes_of_block.size) - 1)
    prefix = padding + known_bytes_of_block
    dictionary = build_dictionary(prefix)
    cipher_text = @oracle.encrypt(padding)[0..(self.block_size - 1)]
    return dictionary[cipher_text]
  end

  # Assumes 16 char block-size
  def ecb?
    cipher_text = @oracle.encrypt("A" * 1000)
    duplicate_blocks?(cipher_text, 16)
  end
end


oracle = BlackBox.new
solver = Solver12.new(oracle)
oracle.encryption_calls

solver.ecb?
solver.block_size
solver.build_dictionary
solver.decrypt_block
oracle.encryption_calls


# TODO: Decrypt the rest of the blocks in the cipher-text
