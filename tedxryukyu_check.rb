#!/usr/bin/env ruby

require 'optparse'

require 'rubygems'
require 'daemons'
require 'net/irc'
require 'open-uri'
require 'nokogiri'

require 'lib/utils'

=begin

= tedxryukyu_check.rb
== TEDxRyukyu.com のサイトの更新状態をチェックし変化がある場合 Tiarra 経由で発言する Bot

Authors::    Tomohiro, TAIRA <tomohiro.t@gmail.com>
Version::    0.0.1
Copyright::  Copyright (C) Tomohiro, TAIRA, 2010. All rights reserved.
URL::        http://tomohiro.github.com

== 参考

http://github.com/cho45/net-irc/blob/master/examples/echo_bot.rb

== 起動例

(1) 通常の起動

    * $ ./tedxryukyu_check.rb -h tiarra.example.com -c "#CHANNEL@NETWORK"

(2) デーモンとして起動

    * $ ./tedxryukyu_check.rb -h tiarra.example.com -c "#CHANNEL@NETWORK" -D

=end


class TEDxRyukyuCheck < Net::IRC::Client
  def initialize
    setup_options
    super(@irc_host, @irc_port, {
      :nick => @bot_name,
      :user => @bot_name,
      :real => @bot_name
    })
    @info_count = 0
  end

  def setup_options
    @irc_port   = 6668
    @bot_name   = 'Tomochan'
    @crawl_time = 60

    ARGV.options do |o|
      o.on('-h', '--irc-host HOST', '接続先の IRC サーバ名') { |v| @irc_host = v }
      o.on('-p', "--irc-port [PORT=#{@irc_port}]", '接続先の IRC ポート番号 (規定は 6668)') { |v| @irc_port = v }
      o.on('-b', "--bot-name [BOT=#{@bot_name}]", 'bot の名前 (規定は Tomochan)') { |v| @bot_name = v }
      o.on('-c', '--channel CHANNEL', '接続先のチャンネル名') { |v| @channel = v }
      o.on('-t', "--crwal-time [SEC=#{@crawl_time}]", '情報をクロールする間隔 (規定は 60秒)') { |v| @crawl_time = v }
      o.on('-D', '--daemonize', 'プロセスをデーモン化する') { |v| Daemons.daemonize }
      o.parse!
    end
  end

  def start
    @socket = TCPSocket.open(@host, @port)
    @socket.gets

    post(NICK, @opts.nick)
    post(USER, @opts.user, '0', '*', @opts.real)

    loop do
      check_arrival
      sleep @crawl_time
    end
  rescue IOError => e
    @log.error 'IOError' + e.to_s
  ensure
    finish
  end

  def check_arrival
    uri = 'http://www.tedxryukyu.com/index.html'

    info_list = (Nokogiri::HTML(open(uri).read)/'dl.info/dd')
    
    if @info_count != info_list.count
        post(NOTICE, @channel, "#{info_list.first.text}(#{uri})")
        @info_count = info_list.count
    end
  end
end 

TEDxRyukyuCheck.new.start
