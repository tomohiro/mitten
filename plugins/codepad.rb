require 'mechanize'
require 'nokogiri'

class CodePad < Mint::Plugin
  def initialize(*args)
    super

    @agent = Mechanize.new
    proxy = ENV['https_proxy'] || ENV['http_proxy']
    if proxy
      proxy = URI.parse(proxy)
      @agent.set_proxy(proxy.host, proxy.port)
    end
    @prefixes = ['C', 'Haskell', 'Lua', 'OCaml', 'PHP', 'Perl', 'Python', 'Ruby', 'Scheme']
  end

  def on_privmsg(prefix, channel, message)
    @language, @code = nil, nil
    @prefixes.select do |item|
      if message =~ Regexp.new("^#{item}:(.+)$")
        @language = item
        @code = $1.gsub('\\', '').strip
      end
    end

    unless @language == nil
      notice(channel, @language)
      notice(channel, run_code)
    end
  end

  private

  def run_code
    output = nil

    begin
      @agent.get('http://codepad.org/') do |run_page|
        result = run_page.form_with(:action => '/') do |f|
          f.radiobutton_with(:value => @language).check
          f.code = code_prefix(@language) + @code
        end.submit
        doc = Nokogiri::HTML(result.body)
        output = (doc/'pre').last.text
      end
      output
    rescue Exception
      'なんかだめー／(^o^)＼'
    end
  end

  def code_prefix(language)
    prefix = ''
    case language
    when 'C'
      prefix = "#include <stdio.h>\n"
    when 'PHP'
      prefix = "<?php \n"
    else
      prefix
    end
  end
end
