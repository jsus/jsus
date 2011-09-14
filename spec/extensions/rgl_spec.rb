require 'spec_helper'

describe "RGL extensions" do
  describe "DirectedAdjacencyGraph#topsorted_vertices" do
    let(:edges) do
      [
        1,3,  1,4,
        2,3,
        3,7,
        4,7,
        5,6,
        6,7,
        7,8
      ]
    end
    subject { RGL::DirectedAdjacencyGraph[*edges] }
    it "should return list of topologically sorted vertices" do
      result = subject.topsorted_vertices
      result.index(1).should < result.index(3)
      result.index(2).should < result.index(3)
      result.index(1).should < result.index(4)
      result.index(1).should < result.index(7)
      result.index(5).should < result.index(6)
      result.index(5).should < result.index(7)
      result.index(6).should < result.index(7)
      result.index(7).should < result.index(8)
    end

    it "should throw an exception if graph contains cycles" do
      subject.add_edge(7,2)
      lambda { subject.topsorted_vertices }.should raise_error(RGL::TopsortedGraphHasCycles)
    end
  end
end
