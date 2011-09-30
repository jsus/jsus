require 'spec_helper'
describe Jsus::Pool do
  let(:input_dir) { "spec/data/ChainDependencies/app/javascripts" }
  let(:packages) {
    [
      Jsus::Package.new("#{input_dir}/Mash"),
      Jsus::Package.new("#{input_dir}/Class"),
      Jsus::Package.new("#{input_dir}/Hash")
    ]
  }

  let(:sources) {
    packages.map {|p| p.source_files[0] }
  }

  subject { Jsus::Pool.new }

  context "initialization" do
    context "without any arguments" do
      subject { Jsus::Pool.new }
      it "should be available" do
        lambda {
          subject
        }.should_not raise_error
      end
    end

    context "from directory" do
      subject { Jsus::Pool.new(input_dir)}
      it "should search for packages recursively and add them to itself" do
        subject.should have_exactly(3).packages
        subject.packages.map {|p| p.name }.should include("Mash", "Hash", "Class")
      end

      it "should add all the source files to pool" do
        subject.should have_exactly(3).sources
        subject.sources.map {|s| s.provides.map {|tag| tag.to_s } }.flatten.should include("Mash/Mash", "Hash/Hash", "Class/Class")
      end

      it "should keep track of extensions" do
        pool = Jsus::Pool.new("spec/data/Extensions/app/javascripts")
        pool.send(:extensions_map).keys.should include(Jsus::Tag["Core/Class"])
      end

      it "should load package.json packages too" do
        pool = Jsus::Pool.new("spec/data/JsonPackage")
        pool.should have_exactly(1).packages
      end

      it "should accept array of directories" do
        pool = Jsus::Pool.new(["spec/data/JsonPackage", "spec/data/Basic"])
        pool.should have_exactly(2).packages
      end
    end
  end


  describe "#lookup" do
    before(:each) { packages.each {|package| subject << package} }

    it "should find a source file providing given full name" do
      subject.lookup("Class/Class").should == sources[1]
    end

    it "should return nil if nothing could be found" do
      subject.lookup("Core/WTF").should be_nil
    end

    it "should allow tags" do
      subject.lookup(Jsus::Tag["Class/Class"]).should == sources[1]
    end

    it "should return replacements whenever possible" do
      pkg = Jsus::Package.new("spec/data/ClassReplacement")
      subject << pkg
      subject.lookup("Class/Class").should == pkg.source_files[0]
      subject.lookup(Jsus::Tag["Class/Class"]).should == pkg.source_files[0]
    end
  end

  describe "#lookup_direct_dependencies" do
    before(:each) do
      packages.each {|package| subject << package.source_files }
    end

    it "should return an array with direct dependencies" do
      subject.lookup_direct_dependencies("Mash/Mash").should be_an(Array)
      subject.lookup_direct_dependencies("Mash/Mash").should == [sources[2]]
      subject.lookup_direct_dependencies(Jsus::Tag["Mash/Mash"]).should be_a(Array)
      subject.lookup_direct_dependencies(Jsus::Tag["Mash/Mash"]).should == [sources[2]]
    end

    it "should return empty array if pool doesn't contain given source" do
      subject.lookup_direct_dependencies("Lol/Wtf").should == []
      subject.lookup_direct_dependencies(Jsus::Tag["Lol/Wtf"]).should == []
    end
  end

  describe "#lookup_dependencies" do
    before(:each) do
      packages.each {|package| subject << package.source_files }
    end

    it "should return a container with files and dependencies" do
      subject.lookup_dependencies("Mash/Mash").should == [sources[1], sources[2]]
      subject.lookup_dependencies(Jsus::Tag["Mash/Mash"]).should == [sources[1], sources[2]]
    end

    it "should return empty array if pool doesn't contain given source" do
      subject.lookup_dependencies("Lol/Wtf").should == []
      subject.lookup_dependencies(Jsus::Tag["Caught/Mosh"]).should == []
    end

    context "wildcard support" do
      let(:input_dir) { "spec/data/DependenciesWildcards/app/javascripts" }

      it "should support wildcards" do
        subject.lookup_dependencies("Mash/Mash").should == [sources[1], sources[2]]
      end
    end
  end


  context "when external dependencies have internal dependencies" do
    let(:input_dir) { "spec/data/ExternalInternalDependencies" }
    subject { Jsus::Pool.new(input_dir) }
    it "#lookup_dependencies should include them" do
      subject.lookup_dependencies("Class/Class").should have_exactly(1).element
    end
  end


  describe "#lookup_extensions" do
    let(:input_dir) { "spec/data/Extensions/app/javascripts" }
    subject { Jsus::Pool.new(input_dir) }

    it "should return empty array if there's not a single extension for given file" do
      source = Jsus::SourceFile.from_file("spec/data/test_source_one.js", :namespace => "Test")
      subject.lookup_extensions(source).should be_empty
    end

    it "should return an array with extensions if there are extensions for given tag" do
      source = subject.lookup("Core/Class")
      subject.lookup_extensions(source).should_not be_empty
    end
  end

  describe "#source_tree" do
    let(:input_dir) { "spec/data/Extensions/app/javascripts" }
    subject { Jsus::Pool.new(input_dir) }

    it "should return a tree with all the source elements in it" do
      subject.source_tree["/Core/Class.js"].should be_a(Jsus::SourceFile)
    end

    it "should not choke when sources got no referenced package" do
      subject.send(:sources).each {|s| s.package = nil}
      lambda { subject.source_tree }.should_not raise_error
    end
  end

  describe "#provides_tree" do
    let(:input_dir) { "spec/data/Extensions/app/javascripts" }
    subject { Jsus::Pool.new(input_dir) }

    it "should return a tree with all the source elements in it" do
      subject.provides_tree.glob("/Core/Class")[0].should == Jsus::Tag["Core/Class"]
    end

    it "should allow wildcards" do
      subject.provides_tree.glob("/Core/*")[0].should == Jsus::Tag["Core/Class"]
    end
  end

end
