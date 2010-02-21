require 'rubygems'
require 'net/irc'

module Mitten
  DEFAULT_SLEEP = 360

  class Plugin < Net::IRC::Client
    def initialize(config, socket)
      @config   = config || {}
      @socket   = socket
      @channels = @config['channels'] || @config['channel']
      @sleep    = @config['sleep'] || DEFAULT_SLEEP
    end

    def post(command, *params)
      @socket <<  Message.new(nil, command, params.map { |s| s.gsub(/\r|\n/, " ") })
    end

    def notice(*params)
      post(NOTICE, *params)
    end

    def message(*params)
      post(PRIVMSG, *params)
    end

    def on_privmsg(prefix, channel, message)
    end

    def notify
      loop do
        main
        sleep @sleep
      end
    end
  end
end
