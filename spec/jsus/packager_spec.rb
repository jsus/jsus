require 'spec_helper'


describe Jsus::Packager do
  let(:simple_source)         { Jsus::SourceFile.from_file("spec/data/SimpleSources/simple_source_one.js", :namespace => "Test") }
  let(:another_simple_source) { Jsus::SourceFile.from_file("spec/data/SimpleSources/simple_source_two.js", :namespace => "Test") }
  let(:dependant_source)      { Jsus::SourceFile.from_file("spec/data/SimpleSources/dependent_source_one.js", :namespace => "Test") }

  let(:simple_package)          { Jsus::Packager.new([simple_source, another_simple_source]) }
  let(:package_with_dependency) { Jsus::Packager.new([dependant_source, simple_source]) }

  before(:each) { cleanup }
  after(:each)  { cleanup }

  describe "initialization" do
    it "should accept sources as arguments" do
      simple_package.should have_exactly(2).sources
      simple_package.sources.should include(simple_source, another_simple_source)
    end
  end

  describe "#pack" do
    subject { Jsus::Packager.new(simple_source) }
    it "should concatenate source files" do
      simple_package.pack.should include(simple_source.source, another_simple_source.source)
    end

    it "should output to file if given a filename" do
      simple_package.pack("spec/tmp/test.js")
      IO.read("spec/tmp/test.js").should include(simple_source.source, another_simple_source.source)
    end

    it "should resolve dependencies" do
      package_with_dependency.pack.should == "#{simple_source.source}\n#{dependant_source.source}"
    end
  end
end
