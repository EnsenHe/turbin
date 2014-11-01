#!/usr/bin/ruby
# -*- coding: utf-8 -*-
#---- by favare_a ----
#file: turbin.rb

require 'socket'
require 'openssl'
require 'base64'
require 'digest'
require 'io/console'
require 'open3'

class Netsoul
  attr_accessor :login
  attr_accessor :mdp
  attr_accessor :host
  attr_accessor :port
  attr_accessor :isauth
  def initialize(login, mdp="", verbose=false, host="ns-server.epitech.net", port=4242)
    @login = login
    @mdp = mdp
    @host = host
    @port = port
    @salut = ""
    @expectedresp = ""
    @sock = nil
    @isauth = false
    @verbose = verbose
    @next = nil
  end
  def send(message)
    puts "send : #{message}" if @verbose
    @sock.puts message
  end
  def connect
    begin
      @sock = TCPSocket.open(@host, @port)
    rescue
      raise "Impossible de se connecter au serveur"
    end
  end
  def disconnect
    begin
      @sock.close
    rescue
      raise "Impossible de fermer la socket"
    end
  end
  def ns_auth_ag
    @expectedresp = "002"
    @next = method(:ns_ext_user_log)
    send "auth_ag ext_user none none"
  end
  def ns_ext_user_log
    data = @salut.split
    challenge = Digest::MD5.new
    challenge.update "#{data[2]}-#{data[3]}/#{data[4]}#{@mdp}"
    @next = method(:ns_state)
    send "ext_user_log #{@login} #{challenge.hexdigest} Turbin Turbin" 
  end
  def ns_ext_user_log_hash(hash)
    @next = method(:ns_state)
    send "ext_user_log #{@login} #{hash} none Turbin" 
  end
  def ns_state
    @isauth = true
    @next = nil
    send "state actif:#{Time.now.to_i.to_s}"
  end
  def salut
    line = @sock.gets.chomp
    @salut = line
    return @salut
  end
  def loop
    Thread.start do
      while line = @sock.gets.chomp
        puts line if @verbose
        cmd = line.split
        if cmd[0] == "salut"
          @salut = line
          ns_auth_ag
        elsif cmd[0] == "rep"
          if cmd[1] != @expectedresp
            raise "Echec de la dernière commande"
          else
            if @next != nil
              @next.call()
            end
          end
        elsif cmd[0] == "ping"
          send "ping #{cmd[1]}"
        end
      end
    end
  end
end

class TurbinClient
  def initialize(host, port)
    @host = host
    @port = port
    @rsa_server = nil
    @rsa_client = nil
    @socket = nil
    @client = nil
  end
  def connect
    begin
      @socket = TCPSocket.open(@host, @port)
    rescue
      raise "#{$!}"
    end
  end
  def start_loop
    Thread.start do
      while line = @socket.gets
        cmd = line.chomp.split
        if (cmd[0] == "add_netsoul")
          begin
            ns = Netsoul.new(cmd[1])
            puts "#{cmd[1]}"
            ns.connect
            salut = ns.salut
            @socket.puts salut
            hash = @socket.gets.chomp
            ns.ns_auth_ag
            ns.ns_ext_user_log_hash(hash)
            ns.loop
          rescue
            puts "Skip.."
          end
        end
      end
    end
  end
  def add_log(login, password)
    Thread.start {
      loop do
        addr = ['<broadcast>', 9998]
        zbroad = UDPSocket.new
        zbroad.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
        zbroad.send("add_user #{login} #{Base64.encode64(password)}", 0, addr[0], addr[1])
      end
    }
    @socket.puts "add_user #{login} #{Base64.encode64(password)}"
  end
end

def usage
  puts "turbin [start | stop]"
  return 0
end

begin
  exit usage if ARGV.length != 1
  if ARGV[0] == "start"
    Open3.popen3 "turbin_serv.rb"
    sleep 0.5
    print "Login : "
    login = $stdin.gets.chomp
    print "Password : "
    password = $stdin.noecho(&:gets).chomp
    print "\n"
    tb = TurbinClient.new("127.0.0.1", 9899)
    tb.connect
    ns = Netsoul.new(login, password)
    ns.connect
    ns.loop
    sleep 0.5
    if !ns.isauth
      puts "Echec de la connection."
    else
      tb.add_log(login, password)
      tb.start_loop
      Process.daemon
    end
  elsif ARGV[0] == "stop"
    system("pkill turbin --signal 9")
    exit
  end
rescue
  puts "#{$!}."
end
