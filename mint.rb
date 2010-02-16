#!/usr/bin/env ruby

$KCODE = 'u'

require 'optparse'
require 'pathname'

require 'rubygems'
require 'net/irc'
require 'ostruct'
require 'yaml'

require 'lib/utils'
require 'lib/plugin'

module Mint
  class Core < Net::IRC::Client
    def initialize
      @config  = setup_options
      @general = @config.general

      super(@general['host'], @general['port'], {
        :nick => @general['nick'],
        :user => @general['user'],
        :real => @general['real']
      })
    end

    def setup_options
      config_file = 'config.yaml'

      ARGV.options do |o|
        o.on('-c', "--config-file [CONFIG FILE=#{config_file}]", "設定ファイルのパス (規定は#{config_file})") { |v| config_file = v }
        o.parse!
      end

      unless File.exist?(config_file)
        config_file = MINT_PATH + '/' + config_file
      end
      config = OpenStruct.new(File.open(config_file) { |f| YAML.load(f) })
    end

    def start
      @socket = TCPSocket.open(@general['host'], @general['port'])
      @socket.gets

      post(NICK, @opts.nick)
      post(USER, @opts.user, '0', '*', @opts.real)

      @plugins = load_plugins(@general['plugin_dir'], @config.plugins)
      @plugins.each do |plugin|
        Thread.start(plugin) do |t|
          plugin.start
          t.join
        end
      end

      loop do
        break if Thread.list.empty?
      end
    rescue IOError => e
      @log.error 'IOError' + e.to_s
    ensure
      finish
    end

    def load_plugins(plugin_dir, plugin_configs)
      unless File.directory?(plugin_dir)
        plugin_dir = MINT_PATH + '/' + plugin_dir
      end

      class_tables = {}

      Pathname.glob("#{plugin_dir}/*.rb") do |file|
        plugin = {}
        m = Module.new
        m.module_eval(file.read, file)
        m.constants.each do |name|
          const = m.const_get(name)
          if const.is_a? Class
            plugin[name] = {
              :class   => const,
              :file    => file,
              :configs => plugin_configs[name]
            }
          end
        end
        class_tables.update(plugin)
      end

      plugins = instantiation(class_tables)
    end

    def instantiation(class_tables)
      plugins = []
      class_tables.each do |name, plugin|
        plugins << plugin[:class].new(plugin[:configs], @socket)
      end

      plugins
    end
  end

  class << self
    def run
      Core.new.start
    end
  end
end

Mint.run
