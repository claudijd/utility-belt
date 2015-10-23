#!/usr/bin/env ruby

# Mod'd version of joernchen's Simple SSL MITM logging proxy for simple TCP comms
# Original here: https://github.com/joernchen/evil_stuff/blob/master/ruby/proxy-ssl.rb
require "socket"

remote_host = "192.168.1.1"
remote_port = 3389
listen_port = 3389
max_threads = 5
threads = []
logfilecs = "tcp-client-server.log" #logfiles will be prefixed with timestamp
logfilesc = "tcp-server-client.log" #logfiles will be prefixed with timestamp

puts "starting server"
local_sock = TCPServer.new(nil, listen_port)

while true
  # Start a new thread for every client connection.
  puts "waiting for connections"
  threads << Thread.new(local_sock.accept) do |client_sock|
    begin
      time = Time.now.to_i
      puts "#{Thread.current}: got a client connection"
      puts "writing to logfiles:  #{time}"
      logcs = time.to_s << logfilecs
      logsc = time.to_s << logfilesc
      cs = File.new(logcs,"a")
      sc = File.new(logsc,"a")
      begin
        remote_sock = TCPSocket.new(remote_host, remote_port)
      rescue Errno::ECONNREFUSED
        client_sock.close
        raise
      end
      puts "#{Thread.current}: connected to server at #{remote_host}:#{remote_port}"
      while true
        # Wait for data to be available on either socket.
        (ready_socks, dummy, dummy) = IO.select([client_sock, remote_sock])
        begin
          ready_socks.each do |sock|
            data = sock.readpartial(4096)
            if sock == client_sock
              # Read from client, write to server.
              cs.write data
              remote_sock.write data
              remote_sock.flush
            elsif sock == remote_sock
              # Read from server, write to client.
              sc.write data
              client_sock.write data
              client_sock.flush
            end
          end
        rescue EOFError
         break
       end
      end
    rescue StandardError => e
      puts "Thread #{Thread.current} got exception #{e.inspect}"
    end
    puts "#{Thread.current}: closing the connections"
    client_sock.close rescue StandardError
    remote_socket.close rescue StandardError
  end

  # Clean up the dead threads, and wait until we have available threads.
  puts "#{threads.size} threads running"
  threads = threads.select { |t| t.alive? ? true : (t.join; false) }
  while threads.size >= max_threads
    sleep 1
    threads = threads.select { |t| t.alive? ? true : (t.join; false) }
  end
end
