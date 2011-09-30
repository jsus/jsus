require 'spec_helper'

describe Jsus::Util::PostProcessor::MooltIE8 do
  it_should_behave_like "Jsus::Util::Mixins::OperatesOnSources"

  let(:input_dir) { "spec/data/ComplexDependencies" }
  let(:pool) { Jsus::Pool.new(input_dir) }

  describe "#process" do
    subject { described_class.new(pool) }
    let!(:source) { pool.sources.detect {|s| s.source.index("ltIE8") } }

    it "should remove ltIE8 tags" do
      subject.process.each {|s| s.source.index("ltIE8").should be_nil }
    end

    it "should not mutate arguments" do
      source.source.index("ltIE8").should_not be_nil
      subject.process
      source.source.index("ltIE8").should_not be_nil
    end
  end
end
