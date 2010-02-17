class Sample < Mint::Plugin
  def initialize(*args)
    super
  end

  def main
    @channels.each { |channel| notice(channel, Time.now.to_s) }
  end
end
