require 'spec_helper'

describe Jsus::Util::PostProcessor::Moocompat12 do
  it_should_behave_like "Jsus::Util::Mixins::OperatesOnSources"

  let(:input_dir) { "spec/data/ComplexDependencies" }
  let(:pool) { Jsus::Pool.new(input_dir) }

  describe "#process" do
    subject { described_class.new(pool) }
    let!(:source) { pool.sources.detect {|s| s.content.index("1.2compat") } }

    it "should remove 1.2compat tags" do
      subject.process.each {|s| s.content.index("1.2compat").should be_nil }
    end

    it "should not mutate arguments" do
      source.content.index("1.2compat").should_not be_nil
      subject.process
      source.content.index("1.2compat").should_not be_nil
    end
  end
end
