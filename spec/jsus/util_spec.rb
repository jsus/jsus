require 'spec_helper'

describe Jsus::Util do
  describe "#try_load" do
    before(:each) do
      @old_logger = Jsus.logger
      Jsus.logger = Jsus::Util::Logger.new("/dev/null")
    end

    after(:each) do
      Jsus.logger = @old_logger
    end

    it "should return true if it is possible to require file" do
      Jsus::Util.try_load('pathname').should be_true
    end

    it "should return false if LoadError happens" do
      Jsus::Util.try_load('wakka-wakka-wakka').should be_false
    end

    it "should use second argument as load name" do
      Jsus::Util.try_load('Net::HTTP', 'net/http').should be_true
    end

    it "should log error when load error happens" do
      lambda {
        Jsus::Util.try_load('wakka-wakka-wakka')
      }.should change(Jsus.logger.buffer, :size).by(1)
    end
  end
end
