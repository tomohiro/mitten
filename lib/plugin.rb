require 'rubygems'
require 'net/irc'

module Mint
  DEFAULT_SLEEP = 360

  class Plugin < Net::IRC::Client
    def initialize(config, socket)
      @socket  = socket
      @channel = config['channel']
      @sleep   = config['sleep'] || DEFUALT_SLEEP
    end

    def post(command, *params)
      @socket <<  Message.new(nil, command, params.map { |s| s.gsub(/\r|\n/, " ") })
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
