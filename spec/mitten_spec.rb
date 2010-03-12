require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Mitten" do
  before(:all) do
    @mitten = Mitten::Bot.new
  end

  it 'Mitten::Bot Instantiation' do
    @mitten.class.should == Mitten::Bot
  end
end
