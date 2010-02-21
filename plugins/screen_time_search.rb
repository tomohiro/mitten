require 'open-uri'
require 'nokogiri'

class ScreenTimeSearch < Mitten::Plugin
  def initialize(*args)
    super

    @theaters_uri = [
      'http://www.startheaters.jp/schedule',
      'http://www.google.co.jp/movies?tid=3d1a4be489681836'
    ]
    @movies_uri = 'http://www.startheaters.jp/movie'
    @pickup_uri = 'http://www.startheaters.jp/'

    @all    = @config['all'] || '映画見たい'
    @suffix = @config['suffix'] || 'の上映時間教えて'
    @pickup = @config['pickup'] || 'おすすめ映画'
  end

  def on_privmsg(prefix, channel, message)
    @results = []

    case message
    when /^#{@all}(.+|)$/
      @results << '今やってる映画だよ♪'
      get_movies_list @movies_uri
    when /^#{@pickup}(.+|)$/
      @results << 'おすすめ映画ピックアップしてみたよ♪'
      get_movies_list @pickup_uri
    when /^(.+)#{@suffix}$/
      get_screen_time($1) 
      @results << 'そんな映画はにゃいっ／(^o^)＼' if @results.empty?
    end

    @results.each { |message| notice(channel, message) }
  end

  private

  def get_movies_list(uri)
    begin
      doc = Nokogiri::HTML(open(uri).read)

      movies = []
      (doc/'h3/a').each do |movie|
        movies << movie.text.gsub(/　+/, ' ')
      end

      @results << movies.join(' / ')
    rescue
      '／(^o^)＼ こわれたっ'
    end
  end

  def get_screen_time(search_title)
    begin
      expression = Regexp.new(Regexp.quote(search_title))

      @theaters_uri.each do |theater|
        html = Nokogiri::HTML(open(theater).read)

        if theater.include? 'startheaters'
          (html/'div.unit_block').each do |movie_info|
            title = movie_info.at('h3/a').text

            if title =~ expression
              site  = movie_info.at('div.pic_block/a[@target="_blank"]').attributes['href']
              @results << "#{title.gsub('　', '')}  #{site}"

              (movie_info/'table.set_d').each do |screen|
                movie = [" - [#{screen.at('th.cinema/img').attributes['alt']}]"]
                (screen/'td').each do |time|
                  movie << time.text unless time.text.to_i == 0
                end
                @results << movie.join('  ')
              end
            end
          end
        else
          theater_name = '[桜坂劇場]'

          (html/'div.movie').each do |info|
            movie_title = (info/'div.name/a/span[@dir="ltr"]').text

            if movie_title =~ expression
              time = info.inner_html.scan(/(..:..+?)</).last
              @results << "#{theater_name} #{movie_title} #{time} (http://www.sakura-zaka.com/)"
            end
          end
        end
      end
    rescue
      '／(^o^)＼ こわれたっ'
    end
  end
end
