require 'spec_helper'

describe Jsus::Util::Validator::Lint do
  let(:sources) { [] }
  subject { described_class.new(sources) }

  context "for bad sources" do
    let(:source_file) { Jsus::SourceFile.from_file("spec/data/bad_source_for_lint.js") }
    let(:sources) { [source_file] }

    it "should return list of errors" do
      subject.validation_errors.should_not be_empty
    end
  end

  context "for good sources" do
    let(:pool) { Jsus::Pool.new("spec/data/Basic") }
    let(:sources) { pool.sources }

    it "should return empty list of errors" do
      subject.validation_errors.should == []
    end
  end

end
