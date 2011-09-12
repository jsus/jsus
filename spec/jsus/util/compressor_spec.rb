require 'spec_helper'

describe Jsus::Util::Compressor do
  let(:source) { File.read("spec/data/test_source_one.js") }
  describe ".compress" do
    it "should take source and compress it with some default params" do
      result = described_class.compress(source)
      result.should include("var TestSourceOne")
    end

    # To test actual compression, we check for removal of comments which is
    # not the only criterion, but the easiest one to check

    it "should accept :yui for method" do
      result = described_class.compress(source, :method => :yui)
      result.should include("var TestSourceOne")
      result.should_not include("/*")
    end

    it "should accept :uglifier for method" do
      result = described_class.compress(source, :method => :uglifier)
      result.should include("var TestSourceOne")
      result.should_not include("/*")
    end

    it "should accept :frontcompiler for method" do
      result = described_class.compress(source, :method => :frontcompiler)
      result.should include("var TestSourceOne")
      result.should_not include("/*")
    end

    it "should accept :closure for method" do
      result = described_class.compress(source, :method => :closure)
      result.should include("var TestSourceOne")
      result.should_not include("/*")
    end

    it "should accept strings for methods" do
      result = described_class.compress(source, :method => "yui")
      result.should include("var TestSourceOne")
      result.should_not include("/*")
    end
  end
end
