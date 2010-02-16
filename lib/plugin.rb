require 'rubygems'
require 'net/irc'

module Mint
  class Plugin < Net::IRC::Client
    def initialize(config, socket)
      @socket  = socket
      @channel = config['channel'] || '*'
    end

    def post(command, *params)
      m = Message.new(nil, command, params.map { |s| s.gsub(/\r|\n/, " ") })
      @socket << m
    end
  end
end
