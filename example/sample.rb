class Sample < Mint::Plugin
  def initialize(*args)
    super
  end

  def befavior(line)
    @channels.each { |channel| notice(channel, line) }
  end

  def notify
    @channels.each { |channel| notice(channel, Time.now.to_s) }
  end
end
