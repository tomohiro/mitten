require 'rubygems'
require 'open-uri'
require 'json'

module URI
  SHORT_URI_API_LOGIN = ENV['SHORT_URI_API_LOGIN']
  SHORT_URI_API_TOKEN = ENV['SHORT_URI_API_TOKEN']

  def self.short(uri)
    return uri if SHORT_URI_API_LOGIN == nil
    begin
      query  = "http://api.bit.ly/v3/shorten?version=2.0.1&longUrl=#{uri.gsub('&', '%26')}&login=#{SHORT_URI_API_LOGIN}&apiKey=#{SHORT_URI_API_TOKEN}"
      result = JSON.parse(open(query).read)

      result.first[1].first[1]['shortUrl']
    rescue Exception => e
      URI.encode(uri)
    end
  end
end
