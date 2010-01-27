#!/usr/bin/env ruby

require 'optparse'

require 'rubygems'
require 'daemons'
require 'net/irc'
require 'open-uri'
require 'nokogiri'

require 'lib/utils'

=begin

= kurosheeva_check.rb
== 玄箱芝の入荷情報をチェックし変化がある場合 Tiarra 経由で発言する Bot

Authors::    Tomohiro, TAIRA <tomohiro.t@gmail.com>
Version::    0.0.1
Copyright::  Copyright (C) Tomohiro, TAIRA, 2010. All rights reserved.
URL::        http://tomohiro.github.com

== 参考

http://github.com/cho45/net-irc/blob/master/examples/echo_bot.rb

== 起動例

(1) 通常の起動

    * $ ./Kurosheeva_check.rb -h tiarra.example.com -c "#CHANNEL@NETWORK"

(2) デーモンとして起動

    * $ ./kurosheeva_check.rb -h tiarra.example.com -c "#CHANNEL@NETWORK" -D

=end


class KurosheevaCheck < Net::IRC::Client
  def initialize
    setup_options
    super(@irc_host, @irc_port, {
      :nick => @bot_name,
      :user => @bot_name,
      :real => @bot_name
    })
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
    uri = 'http://www.buffalo-direct.com/directshop/products/detail.php?product_id=8097'

    (Nokogiri::HTML(open(uri).read)/'div.add2cart/form/div.attention').each do |m|
      if m.text.empty? or m.text != '申し訳ございません、在庫がなくなりました。'
        message = m.text || 'Updated?'
        post(NOTICE, @channel, "#{message} (#{URI.short(uri)})")
      end
    end
  end
end 

KurosheevaCheck.new.start
