require 'rubygems'
require 'net/irc'

module Mint
  DEFAULT_SLEEP = 360

  class Plugin < Net::IRC::Client
    def initialize(config, socket)
      @config   = config
      @socket   = socket
      @channels = @config['channels'] || @config['channel'].split(',')
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

    def run
      before_hook

      loop do
        main
        sleep @sleep
      end

      after_hook
    end
  end
end
