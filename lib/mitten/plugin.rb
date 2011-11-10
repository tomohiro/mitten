# encoding:utf-8

module Mitten
  DEFAULT_SLEEP = 360

  class Plugin
    include Net::IRC
    include Constants

    def initialize(config, server, socket)
      @config   = config || {}
      @server   = server
      @socket   = socket
      @channels = @config['channels'] || (@config['channel'] || [@server.channel])
      @sleep    = @config['sleep'] || DEFAULT_SLEEP
    end

    def before_hook
      # Do something
    end

    def post(command, *args)
      @socket <<  Message.new(nil, command, args.map { |s| s.gsub(/\r|\n/, " ") })
    end

    def notice(*args)
      post(NOTICE, *args)
    end

    def message(*args)
      post(PRIVMSG, *args)
    end

    def response(*args)
      begin
        on_privmsg(*args)
      rescue Exception => e
        post(NOTICE, @server.channel, "#{e.class} #{e.to_s}") if @server.channel
      end
    end

    def notify
      begin
        loop do
          sleep @sleep
          main
        end
      rescue Exception => e
        post(NOTICE, @server.channel, "#{e.class} #{e.to_s}") if @server.channel
      end
    end

  end
end
