# encoding: utf-8

class Echo < Mitten::Plugin

  def initialize(*args)
    super
  end

  def on_privmsg(prefix, channel, message)
    notice(channel, message)
  end

  def main
    @channels.each do |channel|
      notice(channel, Time.now.to_s)
    end
  end

end
