require_relative 'cipher_constants'

class CipherSuites
  def initialize(data)
    @data = data
  end

  def supported_ciphers
    list = []
    @data.scan(/..../).each do |cipher_id|
      name = CIPHER_MAP[cipher_id.hex]
      name = "UNKNOWN (0x" + cipher_id + ")" if name.nil?
      list << name
    end
    return list
  end

  def print_supported_ciphers
    supported_ciphers.each do |supported_cipher|
      puts supported_cipher
    end
  end
end
