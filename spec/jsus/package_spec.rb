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

  describe "#generate_scripts_info" do
    it "should create scripts.json file containing all the info about the package" do
      subject.generate_scripts_info(output_dir)
      File.exists?("#{output_dir}/scripts.json").should be_true
      info = JSON.parse(IO.read("#{output_dir}/scripts.json"))
      info = info["Orwik"]
      info["provides"].should have_exactly(4).items
      info["provides"].should include("Color", "Widget", "Input", "Input.Color")
    end
  end

  describe "#generate_tree" do
    it "should create a json file containing tree information and dependencies" do
      subject.generate_tree(output_dir)
      File.exists?("#{output_dir}/tree.json").should be_true
      tree = JSON.parse(IO.read("#{output_dir}/tree.json"))
      tree["Library"]["Color"]["provides"].should == ["Color"]
      tree["Widget"]["Widget"]["provides"].should == ["Widget"]
      tree["Widget"]["Input"]["Input"]["requires"].should == ["Widget"]
      tree["Widget"]["Input"]["Input"]["provides"].should == ["Input"]
      tree["Widget"]["Input"]["Input.Color"]["requires"].should have_exactly(2).elements
      tree["Widget"]["Input"]["Input.Color"]["requires"].should include("Input", "Color")
      tree["Widget"]["Input"]["Input.Color"]["provides"].should == ["Input.Color"]
    end

    it "should allow different filenames" do
      subject.generate_tree(output_dir, "structure.json")
      File.exists?("#{output_dir}/structure.json").should be_true
      tree = JSON.parse(IO.read("#{output_dir}/structure.json"))
      tree["Library"]["Color"]["provides"].should == ["Color"]
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
