require 'benchmark'
require 'rubygems'
require 'rgl/adjacency'
require 'rgl/topsort'
$:.unshift(File.expand_path("../../../lib/", __FILE__))
require 'extensions/rgl'

edges = [[
  1,3,  1,4,
  2,3,
  3,7,
  4,7,
  5,6,
  6,7,
  7,8
]] * 10

edges.each_with_index do |v_list, i|
  v_list.each {|v| v += i * 100 }
end

edges.flatten!

n = 5_000
graph = RGL::DirectedAdjacencyGraph[*edges]
Benchmark.bmbm do |x|
  x.report("default") { n.times { graph.topsort_iterator.to_a ; graph.cycles.to_a  } }
  x.report("custom") { n.times { graph.topsorted_vertices }  }
end
