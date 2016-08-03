require 'nmap/xml'
require 'csv'

file = ARGV[0].chomp

csv_string = CSV.generate do |csv|
  Nmap::XML.new(file) do |xml|
    xml.each_host do |host|
      host.each_port do |port|
        csv << [host.ip, port.number, port.protocol, port.state, port.service]
      end
    end
  end
end

puts csv_string
