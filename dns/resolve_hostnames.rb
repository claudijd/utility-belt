require 'resolv'

list = File.read("dns_list.txt").split("\n")
out_file = "dns_list.out"

# Delete the old file, if it already exists
File.unlink(out_file) if File.exists?(out_file)

list.each_with_index do |name, i|
  puts "Testing #{name} (#{i} of #{list.size} - #{(i / list.size.to_f * 100.0).to_i}%)"
  begin
    resp = Resolv.getaddress(name)
    out = "#{name}, #{resp}"
  rescue
    out = "#{name}, Error!"
  end

  File.open(out_file, "a") { |file| file.puts(out) }
  sleep 0.1
end

