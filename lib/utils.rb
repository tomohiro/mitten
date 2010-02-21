require 'rubygems'
require 'open-uri'
require 'json'

module URI
  def short(uri)
    uri = URI.escape("http://j.mp/?s=&keyword=&url=#{target}")
    Nokogiri::HTML(open(uri).read).at('#shortened-url')['value']
  end

  module_function :short
end
