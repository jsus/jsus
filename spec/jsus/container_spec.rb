require 'spec_helper'


describe Jsus::Container do
  let(:simple_source)         { Jsus::SourceFile.from_file("spec/data/SimpleSources/simple_source_one.js", :namespace => "Test") }
  let(:another_simple_source) { Jsus::SourceFile.from_file("spec/data/SimpleSources/simple_source_two.js", :namespace => "Test") }
  let(:dependant_source)      { Jsus::SourceFile.from_file("spec/data/SimpleSources/dependent_source_one.js", :namespace => "Test") }
  let(:replacement_source)    { Jsus::SourceFile.from_file("spec/data/SimpleSources/replacement_source_one.js", :namespace => "Test") }
  let(:simple_container)        { Jsus::Container.new(simple_source, another_simple_source) }
  let(:container_with_dependency) { Jsus::Container.new(dependant_source, simple_source) }

  describe "initialization" do
    it "should accept sources as arguments" do
      simple_container.should have_exactly(2).sources
      simple_container.sources.should include(simple_source, another_simple_source)
    end
  end

  describe "#<<" do
    subject { Jsus::Container.new }
    it "should allow multiple items via arrays" do
      subject << [simple_source, another_simple_source]
      subject.should have_exactly(2).sources
    end

    it "should allow multiple items via containers" do
      subject << Jsus::Container.new(simple_source, another_simple_source)
      subject.should have_exactly(2).sources
    end
  end

  describe "#sources" do
    subject { container_with_dependency }
    it "should always be sorted" do
      subject.index(simple_source).should < subject.sources.index(dependant_source)
      subject << another_simple_source
      subject.index(simple_source).should < subject.sources.index(dependant_source)
    end

    it "should not allow duplicates" do
      subject.should have_exactly(2).sources
      subject << simple_source
      subject.should have_exactly(2).sources
      subject << another_simple_source
      subject.should have_exactly(3).sources
    end

    it "should not allow nils" do
      lambda {
        subject << nil
      }.should_not raise_error
    end
  end

  describe "#required_files" do
    subject { container_with_dependency }
    it "should return includes for all the sources" do
      subject.required_files.should == [simple_source.filename, dependant_source.filename]
    end

    it "should generate routes from given root" do
      subject.required_files(File.expand_path("spec/data/SimpleSources")).should == [File.basename(simple_source.filename), File.basename(dependant_source.filename)]
    end
  end

  context "lazy sorting" do
    subject { container_with_dependency.sort! }

    it "should only call topsort when it's needed" do
      subject.should_not_receive(:topsort)
      subject.sort!
      subject.each {|source| } # no-op
    end

    it "should not call topsort when adding resources" do
      subject.should_not_receive(:topsort)
      subject << simple_source
    end

    it "should call topsort for kicker methods" do
      subject << simple_source
      subject.should_receive(:topsort).and_return([])
      subject.each {|source| }
    end
  end

  context "when extensions are present" do
    let(:klass) { Jsus::SourceFile.from_file("spec/data/Extensions/app/javascripts/Core/Source/Class.js", :namespace => "Core") }
    let(:hash) { Jsus::SourceFile.from_file("spec/data/Extensions/app/javascripts/Core/Source/Hash.js", :namespace => "Core") }
    let(:mash) { Jsus::SourceFile.from_file("spec/data/Extensions/app/javascripts/Core/Source/Mash.js", :namespace => "Core") }
    let(:sources) { [klass, hash, mash] }
    let(:klass_ext) { Jsus::SourceFile.from_file("spec/data/Extensions/app/javascripts/Orwik/Extensions/Class.js", :namespace => "Orwik") }
    let(:mash_ext)  { Jsus::SourceFile.from_file("spec/data/Extensions/app/javascripts/Orwik/Extensions/Mash.js", :namespace => "Orwik") }
    let(:extensions) { [klass_ext, mash_ext] }

    subject { described_class.new }
    before(:each) do
      sources.each {|sf| subject << sf }
      extensions.each {|sf| subject << sf }
    end

    it "should return extensions immediately after the sources they extend" do
      subject.to_a.should =~ sources + extensions
      subject.to_a.index(klass).should == subject.to_a.index(klass_ext) - 1
      subject.to_a.index(mash).should == subject.to_a.index(mash_ext) - 1
    end
  end

  context "when replacements are present" do
    let(:source) { Jsus::SourceFile.from_file("spec/data/OutsideDependencies/app/javascripts/Core/Source/Class/Class.Extras.js", :namespace => "Core") }
    let(:replacement) { Jsus::SourceFile.from_file("spec/data/replacement.js", :namespace => "Test") }
    subject { described_class.new(source, replacement) }

    it "should only include replacement in the output" do
      subject.sources.should == [replacement]
    end
  end
end
