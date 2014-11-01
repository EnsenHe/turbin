#!/usr/bin/ruby
require 'socket'
require 'openssl'
require 'base64'
require 'digest'
require 'thread'

class TurbinDClient
  def initialize(socket, verbose=false)
    @socket = socket
    @verbose = verbose
  end
  def send(message)
    puts message if @verbose
    @socket.puts message
  end
  def gets
    message = @socket.gets.chomp
    puts message if @verbose
    return message
  end
end

class TurbinServer
  def initialize(port, verbose=false)
    @port = port
    @socket = nil
    @logins = Hash.new
    @clients = []
    @verbose = verbose
  end
  def open
    begin
      @socket = TCPServer.new @port
    rescue
      raise "Impossible d'ouvrir la socket"
    end
  end
  def loop
     while true
       Thread.start(@socket.accept) do |cli_socket|
        puts "Server : new client" if @verbose
        client = TurbinDClient.new(cli_socket, @verbose)
        @clients << client
        loop_client(client)
      end
     end
  end
  def loop_client(client)
    Thread.start do
      while line = client.gets
        cmd = line.split
        if cmd[0] == "add_user"
          send_newuser(client, cmd[1]) if @logins[cmd[1]] != cmd[2]
          @logins[cmd[1]] = cmd[2]
          @logins.each do |login, mdp|
            if (login != cmd[1])
              client.send "add_netsoul #{login}"
              salut = client.gets
              data = salut.split
              challenge = Digest::MD5.new
              mdp = @logins[login]
              challenge.update "#{data[2]}-#{data[3]}/#{data[4]}#{mdp}"
              client.send "#{challenge.hexdigest}"
            end
          end
        end
      end
    end
  end
  def send_newuser(auth_client, login)
    @clients.each do |client|
      if (client != auth_client)
        client.send "add_netsoul #{login}"
        salut = client.gets
        data = salut.split
        challenge = Digest::MD5.new
        mdp = @logins[login]
        challenge.update "#{data[2]}-#{data[3]}/#{data[4]}#{mdp}"
        client.send "#{challenge.hexdigest}"
      end
    end
  end
end

begin
  server = TurbinServer.new(9899, true)
  server.open
  server.loop
rescue
  puts "#{$!}"
  sleep(3)
  retry
end

$stdin.gets
