class BMI < Mitten::Plugin
  def initialize(*args)
    super

    @prefix = @config['prefix'] || 'BMI'
  end

  def on_privmsg(prefix, channel, message)
    case message
    when /^#{@prefix} ([0-9].+) ([0-9].+)$/
      judge = judge($1, $2)
      notice(channel, judge) unless judge.empty?
    end
  end

  private

  def judge(height, weight)
    bmi = bmi(height, weight)

    judge = case
            when 26.4 <= bmi
              '肥満'
            when 24.2 <= bmi
              '過体重'
            when 19.8 <= bmi && bmi < 24.2
              '理想体重'
            when bmi < 17.6
              'やせすぎ'
            when bmi < 19.8
              'やせ気味'
            end

    "あなたの BMI は #{bmi} で #{judge} です！ 理想体重は #{ideal_body_weight(height)}kg だよっ"
  end

  def bmi(height, weight)
    height = height.to_f / 100
    weight = weight.to_f

    (weight / height / height).to_i
  end

  def ideal_body_weight(height)
    height = height.to_f / 100
    (22 * height * height).to_i
  end
end
