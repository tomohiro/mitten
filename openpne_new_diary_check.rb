#!/usr/bin/env ruby

require 'optparse'

require 'rubygems'
require 'daemons'
require 'net/irc'
require 'mechanize'
require 'nokogiri'

require 'lib/utils'

=begin

= openpne_new_diary_check.rb
== OpenPNE に新しい日記が投稿されたら Tiarra 経由で発言する Bot

Authors::    Tomohiro, TAIRA <tomohiro.t@gmail.com>
Version::    0.0.1
Copyright::  Copyright (C) Tomohiro, TAIRA, 2010. All rights reserved.
URL::        http://tomohiro.github.com

== 参考

http://github.com/cho45/net-irc/blob/master/examples/echo_bot.rb

== 起動例

(1) 通常の起動

    * $ ./openpne_new_diary_check.rb -h tiarra.example.com -c "#CHANNEL@NETWORK" -A openpne.example.com -U username -P password

(2) デーモンとして起動

    * $ ./openpne_new_diary_check.rb -h tiarra.example.com -c "#CHANNEL@NETWORK" -A openpne.example.com -U username -P password -D

=end

class OpenPNENewDiaryCheck < Net::IRC::Client
  def initialize
    setup_options
    super(@irc_host, @irc_port, {
      :nick => @bot_name,
      :user => @bot_name,
      :real => @bot_name
    })

    @agent = WWW::Mechanize.new
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
      o.on('-t', "--crwal-time [SEC=#{@crawl_time}]", 'OpenPNE の情報をクロールする間隔 (規定は 60秒)') { |v| @crawl_time = v }
      o.on('-A', '--address OpenPNE URI', 'OpenPNE のアドレス') { |v| @openpne_uri = v }
      o.on('-U', '--username USERNAME', 'OpenPNE のログインユーザ') { |v| @username = v }
      o.on('-P', '--password PASSWORD', 'OpenPNE のログインパスワード') { |v| @password = v }
      o.on('-D', '--daemonize', 'プロセスをデーモン化する') { |v| Daemons.daemonize }
      o.parse!
    end
  end

  def start
    login

    @socket = TCPSocket.open(@host, @port)
    @socket.gets

    post(NICK, @opts.nick)
    post(USER, @opts.user, '0', '*', @opts.real)

    @diaries = {}
    loop do
      check_diaries
      sleep @crawl_time
    end
  rescue IOError => e
    @log.error 'IOError' + e.to_s
  ensure
    finish
  end

  def login
    @agent.get(@openpne_uri) do |login_page|
      login_page.form_with(:name => 'login') do |f|
        f.username = @username
        f.password = @password
      end.submit
    end
  end

  def check_diaries 
    diary_page = @agent.get "#{@openpne_uri}/?m=pc&a=page_h_diary_list_all"
    diaries = Nokogiri::HTML(diary_page.body)/'div.item'

    diaries[1...diaries.size].each do |diary|
      uri   = URI.short("#{@openpne_uri}/#{(diary/'td.photo/a').first.attributes['href']}")
      nick  = ((diary/'td').to_a)[1].text.gsub(/ \(.*\)$/, '')
      title = ((diary/'td').to_a)[2].text.gsub(/ \([0-9].?\)/, '')

      message = "#{nick}さんが「#{title}」を投稿しました！ (#{uri})"

      unless @diaries.has_key? uri
        @diaries[uri] = message
        post(NOTICE, @channel, message) if @diaries.size > 20
      end
    end
  end
end

OpenPNENewDiaryCheck.new.start
