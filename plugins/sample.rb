class Sample < Mint::Plugin
  def initialize(config, socket)
    super(config, socket)
  end

  def run
    loop do
      post(NOTICE, @channel, 'sample')
      sleep 10
    end
  end
end
