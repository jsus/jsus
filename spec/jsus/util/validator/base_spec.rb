require 'spec_helper'

describe Jsus::Util::Validator::Base do
  it_should_behave_like "Jsus::Util::Mixins::OperatesOnSources"
  let(:input_dir) { "spec/data/ChainDependencies/app/javascripts" }
  let!(:pool) { Jsus::Pool.new(input_dir) }
  context "initialization" do
    subject { described_class.new(pool) }
    it "should accept pool as the first argument" do
      described_class.new(pool).source_files.should =~ pool.sources.to_a
    end

    it "should accept container as the first argument" do
      described_class.new(pool.sources).source_files.should =~ pool.sources.to_a
    end

    it "should accept array as the first argument" do
      described_class.new(pool.sources.to_a).source_files.should =~ pool.sources.to_a
    end
  end

  it "should respond to #validate method" do
    subject.should respond_to(:validate)
  end

  describe ".validate" do
    subject { described_class.new(pool) }
    it "should be the same as calling new + validate" do
      validator = mock
      described_class.should_receive(:new).with([1]).and_return(validator)
      validator.should_receive(:validate).and_return(true)
      described_class.validate([1])
    end
  end
end
