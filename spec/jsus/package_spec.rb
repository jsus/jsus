require 'spec_helper'
require 'json'

describe Jsus::Package do
  subject { Jsus::Package.new(input_dir) }
  let(:input_dir) { "spec/data/Basic/app/javascripts/Orwik"}
  let(:output_dir) { "spec/data/Basic/public/javascripts/Orwik" }
  before(:each) { cleanup }
  after(:all) { cleanup }
  context "initialization" do
    context "from a directory" do
      context "with a package.yml" do
        let(:input_dir) { "spec/data/OutsideDependencies/app/javascripts/Orwik" }
        let(:output_dir) { "spec/data/OutsideDependencies/public/javascripts/Orwik" }

        it "should load header from package.yml" do
          subject.name.should == "Orwik"
          subject.filename.should == "orwik.js"
        end

        it "should set provided modules from source files" do
          subject.provides.should have_exactly(4).items
          subject.provides.map {|p| p.to_s }.should include("Orwik/Color", "Orwik/Input", "Orwik/Input.Color", "Orwik/Widget")
        end

        it "should set up outside dependencies" do
          subject.requires.map {|r| r.to_s}.should =~ ["Core/Class"]
        end

        it "should set directory field" do
          subject.directory.should == File.expand_path(input_dir)
        end

        it "should assign source file itself as a package" do
          subject.source_files.each {|sf| sf.package.should == subject }
        end
      end

      context "with a package.json" do
        let(:input_dir) { "spec/data/JsonPackage" }
        let(:output_dir) { "spec/data/JsonPackage" }

        it "should load header from package.json" do
          subject.name.should == "Sheet"
          subject.provides.map {|p| p.to_s}.should =~ ["Sheet/Sheet", "Sheet/SheetParser.CSS"]
          subject.requires.map {|r| r.to_s}.should =~ ["Sheet/CombineRegExp"]
        end

      end
    end
  end

  describe "#required_files" do
    it "should not include extensions" do
      required_files = Jsus::Package.new("spec/data/Extensions/app/javascripts/Orwik").required_files
      required_files.should be_empty
    end
  end

  describe "#filename" do
    it "should convert package name to snake_case" do
      subject.filename.should == "orwik.js"
    end
  end
end
