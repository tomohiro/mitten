#!/usr/bin/env ruby

$KCODE = 'u'

require 'ostruct'
require 'yaml'
require 'optparse'
require 'pathname'

require 'rubygems'
require 'net/irc'

require 'lib/utils'
require 'lib/plugin'

module Mitten
  DEFAULT_CONFIG_FILE_PATH = 'configs/environment.yaml'

  class Bot < Net::IRC::Client
    def self.boot
      new.boot
    end

    def initialize
      load_configs

      super(@server['host'], @server['port'], {
        :nick    => @server['nick'],
        :user    => @server['user'],
        :real    => @server['real'],
        :pass    => @server['pass'],
        :channel => @server['channel']
      })
    end

    def load_configs
      @mode = 'production'
      config_file = DEFAULT_CONFIG_FILE_PATH

      ARGV.options do |o|
        o.on('-c', "--config-file CONFIG_FILE", " (default: #{config_file})") { |v| config_file = v }
        o.on('-d', "--development") { |v| @mode = 'development' }
        o.parse!
      end

      @config = OpenStruct.new(File.open(config_file) { |f| YAML.load(f) })
      @server = @config.method(@mode).call
    end

    def connect
      puts "TCPSocket open to #{@server['host']}:#{@server['port']}"
      TCPSocket.open(@server['host'], @server['port'])
    end

    def boot 
      begin
        @socket = connect
        @socket.gets

        post(PASS, @opts.pass) if @opts.pass
        post(NICK, @opts.nick)
        post(USER, @opts.user, '0', '*', @opts.real)
        post(JOIN, @opts.channel) if @opts.channel

        run_plugins
      rescue Exception => e
        post(NOTICE, @opts.channel, "#{e.class} #{e.to_s}") if @opts.channel
        @log.error "#{e.class} #{e.to_s}"
      ensure
        finish
      end
    end

    def run_plugins
      threads = []
      load_plugins(@server['plugin_dir'], @config.plugins)

      threads.push(
        Thread.fork do
          while line = @socket.gets
            message = Message.parse(line)
            if message.command.upcase == 'PRIVMSG'
              @response_plugins.each do |plugin|
                plugin.response(message.prefix, message[0], message[1])
              end
            end
          end
        end
      )

      @notify_plugins.each do |plugin|
        plugin.before_hook
        threads.push(Thread.fork { plugin.notify })
      end

      threads.each { |t| t.join }
    end

    def load_plugins(plugin_dir, plugin_configs)
      class_tables = {}

      Pathname.glob("#{plugin_dir}/*.rb") do |file|
        plugin = {}
        m = Module.new
        m.module_eval(file.read, file)
        m.constants.each do |name|
          break unless plugin_configs.has_key? name
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
      instance_categorize(plugins)
    end

    def instantiation(class_tables)
      plugins = []
      class_tables.each do |name, plugin|
        plugins << plugin[:class].new(plugin[:configs], @opts, @socket)
        puts "Plugin: #{name} is loaded"
      end

      plugins
    end

    def instance_categorize(plugins)
      @response_plugins = []
      @notify_plugins   = []

      plugins.each do |plugin|
        @response_plugins << plugin if plugin.respond_to? 'on_privmsg'
        @notify_plugins   << plugin if plugin.respond_to? 'main'
      end
    end
  end
end
