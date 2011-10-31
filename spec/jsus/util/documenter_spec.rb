require "spec_helper"

describe Jsus::Util::Documenter do
  subject { described_class.new }
  let(:input_dir) { "spec/data/Basic/app/javascripts/Orwik" }
  let(:pool) { Jsus::Pool.new(input_dir) }

  describe "<<" do
    it "should add source files to tree" do
      pool.sources.each {|s| subject << s}
      subject.tree["/Orwik/Color.js"].should be_a(Jsus::SourceFile)
    end
  end

  describe "#documented_sources" do
    before(:each) { pool.sources.each {|s| subject << s} }
    it "should return all sources by default" do
      subject.documented_sources.glob("/**/*").should have(4).elements
    end

    it "should accept #only scope as exclusive scope" do
      subject.only("/Orwik/Wid*").documented_sources.glob("/**/*").should have(1).element # /Orwik/Widget.js
    end

    it "should accept #or scope as additive scope" do
      # /Orwik/Widget.js, /Orwik/Input.js, /Orwik/Input.Color.js
      subject.only("/Orwik/Wid*").or("/Orwik/Inp*").documented_sources.glob("/**/*").should have(3).elements
    end
  end

end
