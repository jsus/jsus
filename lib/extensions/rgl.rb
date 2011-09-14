module RGL
  class TopsortedGraphHasCycles < Exception; end
  class DirectedAdjacencyGraph
    def topsorted_vertices
      v_num = vertices.size
      result = []
      available_vertices = []
      reversed_graph = reverse
      out_degrees = {}
      vertices.each do |v|
        out_degrees[v] = reversed_graph.out_degree(v)
        available_vertices.push(v) if out_degrees[v] == 0
      end
      while available_vertices.size > 0
        vertice = available_vertices.pop
        result.push(vertice)
        each_adjacent(vertice) do |dependent|
          reversed_graph.remove_edge(dependent, vertice)
          out_degrees[dependent] -= 1
          available_vertices.push(dependent) if out_degrees[dependent] == 0
        end
      end
      raise TopsortedGraphHasCycles unless result.size == vertices.size
      result
    end # topsorted_vertices
  end # class DirectedAdjacencyGraph
end # module RGL
