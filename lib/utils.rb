require 'rubygems'
require 'open-uri'
require 'json'

module URI
  def short(uri)
    begin
      login   = ''
      api_key = ''

      query  = "http://api.j.mp/shorten?version=2.0.1&longUrl=#{URI.encode(uri.gsub('&', '%26'))}&login=#{login}&apiKey=#{api_key}"
      result = JSON.parse(open(query).read)

      result.first[1].first[1]['shortUrl']
    rescue
      URI.encode(uri)
    end
  end

  module_function :short
end
