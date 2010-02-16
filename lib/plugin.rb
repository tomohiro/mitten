require 'rubygems'
require 'net/irc'

module Mint
  class Plugin < Net::IRC::Client
    def initialize(config, socket)
      @socket  = socket
      @channel = config['channel'] || '*'
    end

    def post(command, *params)
      @socket <<  Message.new(nil, command, params.map { |s| s.gsub(/\r|\n/, " ") })
    end
  end
end
