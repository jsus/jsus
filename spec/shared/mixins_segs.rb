shared_examples_for "Jsus::Util::Mixins::OperatesOnSources" do
  let(:sources) { (0..3).map {|i| Jsus::SourceFile.from_file("spec/data/test_source_one.js") } }
  it "should respond to source_files, source_files=" do
    subject.should respond_to(:source_files, :source_files=)
  end

  describe "#source_files=" do
    it "should accept array" do
      subject.source_files = sources
      subject.source_files.should =~ sources
    end

    it "should accept container" do
      container = mock("Container", :to_a => sources)
      subject.source_files = sources
      subject.source_files.should =~ sources
    end

    it "should accept pool" do
      pool = mock("Pool", :sources => sources)
      subject.source_files = sources
      subject.source_files.should =~ sources
    end

    it "should default to empty array if given anything else" do
      subject.source_files = nil
      subject.source_files.should == []
      subject.source_files = 0
      subject.source_files.should == []
    end
  end

  describe "#source_files" do
    it "should default with empty array" do
      subject.source_files.should == []
    end
  end
end
