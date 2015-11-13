require 'net/http'
require 'netaddr'
require 'json'

class AmazonIPChecker
  def initialize
    uri = URI('https://ip-ranges.amazonaws.com/ip-ranges.json')
    resp = Net::HTTP.get(uri)
    parsed_response = JSON.parse(resp)

    @amazon_ranges = []

    parsed_response['prefixes'].each do |prefix|
      @amazon_ranges << NetAddr::CIDR.create(prefix['ip_prefix'])
    end
  end

  def amazon_ip?(ip)
    @amazon_ranges.each do |amazon_range|
      if amazon_range.contains?(ip)
        return true
      end
    end

    return false
  end
end

# Example usage
# checker = AmazonIPChecker.new()
# checker.amazon_ip?("43.250.192.1")
# checker.amazon_ip?("42.250.193.1")

