#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'socket'
require 'openssl'
require 'base64'
require 'digest'

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
    send "ext_user_log #{@login} #{challenge.hexdigest} none Turbin" 
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
  def loop
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
    @socket.puts "add_user #{login} #{password}"
  end
end

begin
  Process.daemon
  tb = TurbinClient.new("127.0.0.1", 9899)
  tb.connect
  ns = Netsoul.new(ARGV[0], ARGV[1])
  ns.connect
  ns.loop
  sleep(2)
  if !ns.isauth
    puts "Echec de la connection."
    exit (1)
  end
  tb.add_log("favare_a", "wo9lZ,*m")
  tb.loop
rescue
  puts "#{$!}."
  retry
end
