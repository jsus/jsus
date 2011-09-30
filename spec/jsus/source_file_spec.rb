# encoding: utf-8
require 'spec_helper'

describe Jsus::SourceFile do
  before(:each) { cleanup }
  after(:all) { cleanup }
  let(:filename) { "spec/data/OutsideDependencies/app/javascripts/Core/Source/Class/Class.Extras.js" }
  subject { Jsus::SourceFile.from_file(filename) }
  context "initialization" do
    context "from file" do
      subject { Jsus::SourceFile.from_file('spec/data/test_source_one.js') }

      it "should set filename field to expanded file name" do
        subject.filename.should == File.expand_path("spec/data/test_source_one.js")
      end

      it "should set original_source to file content" do
        subject.original_source.should == File.read(subject.filename)
      end

      it "should parse the header" do
        subject.header["license"].should     == "MIT-style license"
        subject.header["description"].should == "A library to work with colors"
      end

      context "when that file is problematic" do
        before(:each) { Jsus.logger.level = Logger::FATAL }
        after(:each) { Jsus.logger.level = Logger::WARN }
        context "when format is invalid" do
          it "should raise error" do
            lambda { Jsus::SourceFile.from_file('spec/data/bad_test_source_one.js') }.should raise_error
            lambda { Jsus::SourceFile.from_file('spec/data/bad_test_source_two.js') }.should raise_error
          end
        end

        context "when file does not exist" do
          it "should raise error" do
            lambda { Jsus::SourceFile.from_file('spec/data/non-existant-file.js') }.should raise_error
          end
        end

        context "when some error happens" do
          it "should raise error and mention filename" do
            YAML.stub!(:load) { raise "Could not parse the file!" }
            lambda { subject }.should raise_error(RuntimeError, %r{spec/data/test_source_one\.js})
          end
        end

      end
    end

    it "should not break on unicode files" do
      source = nil
      lambda { source = Jsus::SourceFile.from_file("spec/data/unicode_source.js") }.should_not raise_error
      source.header["authors"][1].should == "Sebastian Markbåge"
    end

    it "should recognize and ignore BOM marker" do
      source = nil
      lambda { source = Jsus::SourceFile.from_file("spec/data/unicode_source_with_bom.js")  }.should_not raise_error
      source.header["authors"][1].should == "Sebastian Markbåge"
    end

    it "should parse 'requires', 'provides', 'extends' and 'replaces' fields of the header" do
      subject.requires.should == [Jsus::Tag["Class"]]
      subject.provides.should =~ [Jsus::Tag["Chain"], Jsus::Tag["Events"], Jsus::Tag["Options"]]
      subject.replaces.should be_nil
      subject.extends.should be_nil
    end

    it "should use assigned namespace for internal dependencies" do
      subject = described_class.from_file(filename, :namespace => "Core")
      subject.requires.should == [Jsus::Tag["Core/Class"]]
      subject.provides.should == [Jsus::Tag["Core/Chain"], Jsus::Tag["Core/Events"], Jsus::Tag["Core/Options"]]
    end

    it "should accept namespace in options" do
      described_class.from_file("spec/data/test_source_one.js").namespace.should                       == nil
      described_class.from_file("spec/data/test_source_one.js", :namespace => "Core").namespace.should == "Core"
    end

    if defined?(Encoding) && Encoding.respond_to?(:default_external)
      it "should not break on unicode files even when external encoding is set to non-utf" do
        old_external = Encoding.default_external
        Encoding.default_external = 'us-ascii'
        source = nil
        lambda { source = Jsus::SourceFile.from_file("spec/data/unicode_source.js") }.should_not raise_error
        source.header["authors"][1].should == "Sebastian Markbåge"
        Encoding.default_external = old_external
      end
    end
  end

  context "when it is not an extension, " do
    subject { Jsus::SourceFile.from_file("spec/data/Extensions/app/javascripts/Core/Source/Class.js") }

    describe "#extension?" do
      it "should return false" do
        subject.should_not be_an_extension
      end
    end
  end

  context "when it is an extension, " do
    subject { Jsus::SourceFile.from_file("spec/data/Extensions/app/javascripts/Orwik/Extensions/Class.js") }

    describe "#extension?" do
      it "should return true" do
        subject.should be_an_extension
      end
    end
  end

  describe "#required_files" do
    it "should include original source" do
      subject = described_class.from_file(filename)
      subject.required_files.should == [File.expand_path(filename)]
    end
  end

  it "should allow quirky mooforge dependencies syntax" do
    subject = described_class.from_file("spec/data/mooforge_quirky_source.js")
    subject.dependencies.map {|d| d.to_s }.should == ["MootoolsCore/Core"]
  end

  describe "#==, eql, hash" do
    it "should return true for source files pointing to the same physical file" do
      subject.should == described_class.from_file(subject.filename)
      subject.should eql(described_class.from_file(subject.filename))
      subject.hash.should == described_class.from_file(subject.filename).hash
    end

    it "should return false for source files pointing to different physical files" do
      subject.should_not == described_class.from_file("spec/data/Extensions/app/javascripts/Orwik/Extensions/Class.js")
      subject.should_not eql(described_class.from_file("spec/data/Extensions/app/javascripts/Orwik/Extensions/Class.js"))
      subject.hash.should_not == described_class.from_file("spec/data/Extensions/app/javascripts/Orwik/Extensions/Class.js").hash
    end
  end

  describe "#to_hash" do
    subject { described_class.from_file(filename, :namespace => "Core") }
    it "should include shortened provides tags" do
      subject.to_hash["provides"].should =~ ["Chain", "Events", "Options"]
    end

    it "should include shortened requirement tags for local dependencies" do
      subject.to_hash["requires"].should == ["Class"]
    end

    it "should include full-form requirement tags for external dependencies" do
      subject = described_class.from_file("spec/data/OutsideDependencies/app/javascripts/Orwik/Source/Widget/Widget.js", :namespace => "Orwik")
      subject.to_hash["requires"].should == ["Core/Class"]
    end
  end
end
