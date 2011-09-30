require 'spec_helper'

describe Jsus::Tag do
  subject { Jsus::Tag.new("Wtf") }

  context "initialization" do
    it "should set given full name" do
      Jsus::Tag.new("Wtf").full_name.should == "Wtf"
      Jsus::Tag.new("Core/Wtf").full_name.should == "Core/Wtf"
    end

    it "when given a tag it should return that tag" do
      tag = Jsus::Tag.new("Wtf")
      new_tag = Jsus::Tag.new(tag)
      new_tag.should           == tag
      new_tag.object_id.should == tag.object_id
    end
  end

  describe "#name" do
    it "should return short form of the tag" do
      Jsus::Tag.new("Core/Wtf").name.should == "Wtf"
      Jsus::Tag.new("Core/Subpackage/Wtf").name.should == "Wtf"
    end

    it "should not add slashes if package name is not set" do
      Jsus::Tag.new("Wtf").name.should == "Wtf"
    end

    it "should strip leading slashes" do
      Jsus::Tag.new("./Wtf").name.should == "Wtf"
    end
  end

  describe "#namespace" do
    it "should be nil for empty namespace" do
      Jsus::Tag.new("Class").namespace.should be_nil
    end

    it "should be non-empty for non-empty namespace" do
      Jsus::Tag.new("Core/Class").namespace.should == "Core"
      Jsus::Tag.new("Mootools/Core/Class").namespace.should == "Mootools/Core"
    end
  end

  describe "#==" do
    pending "should translate mooforge styled names into jsus-styled names" do
      Jsus::Tag.new("mootools_core/Wtf").should      == Jsus::Tag.new("MootoolsCore/Wtf")
      Jsus::Tag.new("Effects.Fx/Hello.World").should == Jsus::Tag.new("EffectsFx/Hello.World")
      Jsus::Tag.new("effects.fx/Wtf").should         == Jsus::Tag.new("EffectsFx/Wtf")
    end

    it "should distinguish between same name in different namespaces" do
      Jsus::Tag.new("Mootools/Slick.Finder").should_not == Jsus::Tag.new("Slick/Slick.Finder")
    end
  end

  context "comparison to other types" do
    it "should consider tags with the same full names equal" do
      Jsus::Tag.new("Core/Wtf").should == Jsus::Tag.new("Core/Wtf")
    end

    it "should work with array operations" do
      ([Jsus::Tag.new("Core/Wtf")] - [Jsus::Tag.new("Core/Wtf")]).should == []
    end
  end

  describe "#empty?" do
    it "should return true when tag is empty" do
      Jsus::Tag.new("").should be_empty
    end

    it "should return false when tag is not empty" do
      Jsus::Tag.new("Core/Mash").should_not be_empty
    end
  end

  describe ".[]" do
    it "should be an alias to .new" do
      Jsus::Tag["Yo/Rap"].should == Jsus::Tag.new("Yo/Rap")
    end
  end


end
