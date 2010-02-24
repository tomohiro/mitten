require 'ostruct'
require 'yaml'
require 'open-uri'
require 'nokogiri'
 
class TwitterBot < Mitten::Plugin
  def initialize(*args)
    super

    @config_file = @config['config']
    @bot_list = load_config
  end

  def load_config
    OpenStruct.new(File.open(@config_file) { |f| YAML.load(f) }).bot_list
  end

  def on_privmsg(prefix, channel, message)
    @bot_list.each_key do |key|
      notice(channel, get_tweet(@bot_list[key])) if message =~ Regexp.new(/#{key}(|？|\?)/)
    end
  end

  def get_tweet(bot)
    html = Nokogiri::HTML(open("http://twitter.com/#{bot}").read)

    tweet = (html/'.entry-content').first
    if !tweet.nil?
      tweet = tweet.text
    end
  end
end
