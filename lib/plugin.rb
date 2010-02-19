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

    def before_hook
    end

    def run
      threads = []

      threads.push(
        Thread.fork do
          while line = @socket.gets
            message = Message.parse(line)
            if message.command.upcase == 'PRIVMSG'
              behavior(message)
            end
          end
        end
      )

      threads.push(
        Thread.fork do
          loop do
            notify
            sleep @sleep
          end
        end
      )

      threads.each { |t| t.join }
    end
  end
end
