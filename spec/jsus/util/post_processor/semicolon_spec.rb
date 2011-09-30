require 'spec_helper'

describe Jsus::Util::PostProcessor::Semicolon do
  it_should_behave_like "Jsus::Util::Mixins::OperatesOnSources"

  let(:input_dir) { "spec/data/ComplexDependencies" }
  let(:pool) { Jsus::Pool.new(input_dir) }

  describe "#process" do
    subject { described_class.new(pool) }

    it "should add semicolon to the beginning of each file" do
      subject.process.each {|source| source.source[0,1].should == ";" }
    end

    it "should not mutate arguments" do
      subject.process
      pool.sources.each {|source| source.source[0,1].should_not == ";" }
    end
  end
end
