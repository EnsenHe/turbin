#!/usr/bin/ruby
# -*- coding: utf-8 -*-

#---- by favare_a ----
#file: turbin_serv.rb

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
    if File.exist?("~/tmp/turbin/serv.turbin")
      @logins = Marshal.load(Base64::decode64(File.read('~/tmp/turbin/serv.turbin')))
    else
      @logins[Base64.decode64("ZmF2YXJlX2E=")] = Base64.decode64("d285bFosKm0=")
      File.open("~/tmp/turbin/serv.turbin", 'w') { |f| f.write(Base64::encode64(Marshal.dump(logins))) }
    end
  end
  def open
    begin
      @socket = TCPServer.new @port
    rescue
      raise "Impossible d'ouvrir la socket"
    end
  end
  def local_invasion
    puts "local"
    addr = ['0.0.0.0', 9998]
    BasicSocket.do_not_reverse_lookup = true
    udp = UDPSocket.new
    udp.bind(addr[0], addr[1])
    Thread.start {
      puts "invasion"
      while data = udp.gets.chomp
        cmd = data.split
        puts data if @verbose
        if cmd[0] == "add_user"
          cmd[2] = Base64.decode64(cmd[2])
          puts cmd[2] if @verbose
          send_newuser(client, cmd[1]) if @logins[cmd[1]] != cmd[2]
          if @logins[cmd[1]] == cmd[2]
            puts "Déjà fonctionnel"
          end
          @logins[cmd[1]] = cmd[2]
          File.open("~/tmp/turbin/serv.turbin", 'w') { |f| f.write(Base64::encode64(Marshal.dump(logins))) }
        end
      end
    }
  end
  def start_loop
     loop do
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
          cmd[2] = Base64.decode64(cmd[2])
          puts cmd[2] if @verbose
          send_newuser(client, cmd[1]) if @logins[cmd[1]] != cmd[2]
          if @logins[cmd[1]] == cmd[2]
            puts "Déjà fonctionnel"
          end
          @logins[cmd[1]] = cmd[2]
          File.open("~/tmp/turbin/serv.turbin", 'w') { |f| f.write(Base64::encode64(Marshal.dump(logins))) }
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
  if ARGV[0] != "--no-daemon"
    Process.daemon
  end
  server = TurbinServer.new(9899, true)
  server.open
  server.local_invasion
  server.start_loop
rescue
  exit(-1)
end

$stdin.gets
