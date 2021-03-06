module Jsus
  #
  # Container is an array that contains source files. Main difference
  # from an array is the fact that container maintains topological
  # sort for the source files.
  #
  # This class is mostly used internally.
  #
  class Container
    # Instantiates a container from given sources.
    #
    # @param [*SourceFile] sources
    def initialize(*sources)
      @sources        = []
      @normal_sources = []
      @extensions     = []
      @replacements   = []
      sources.each do |source|
        push(source)
      end
    end

    # Public API

    # Pushes an item to the container
    #
    # @param [SourceFile] source source pushed file
    def push(source)
      if source
        if source.kind_of?(Array)
          source.each {|s| self.push(s) }
        elsif source.kind_of?(Container)
          source.all_sources.each {|s| self.push(s) }
        else
          if source.extension?
            @extensions << source unless @extensions.include?(source)
          elsif source.replacement?
            @replacements << source unless @replacements.include?(source)
          else
            @normal_sources << source unless @normal_sources.include?(source)
          end
        end
      end
      clear_cache!
      self
    end
    alias_method :<<, :push

    # Flattens the container items
    #
    # @return [Array]
    def flatten
      map {|item| item.respond_to?(:flatten) ? item.flatten : item }.flatten
    end

    # Contains the source files.
    #
    # @return [Array]
    # @api public
    def sources
      sort!
      @sources
    end
    alias_method :to_a, :sources

    # Includes all sources, even those that would normally be replaced.
    # Without any order.
    #
    # @return [Array]
    # @api semipublic
    def all_sources
      @normal_sources + @extensions + @replacements
    end # all_sources

    # Topologically sorts items in container if required.
    #
    # @return [self]
    # @api semipublic
    def sort!
      unless sorted?
        @sources = topsort
        insert_extensions!
        insert_replacements!
        @sources.uniq!
        @sorted = true
      end
      self
    end

    # Returns whether container requires sorting.
    #
    # @return [Boolean]
    # @api semipublic
    def sorted?
      !!@sorted
    end

    # Lists all the required files (dependencies and extensions) for
    # the sources in the container. Consider it a projection from source files
    # space onto filesystem space.
    #
    # Optionally accepts a filesystem point to calculate relative paths from.
    #
    # @param [String] root root point from which the relative paths are calculated.
    #   When omitted, full paths are returned.
    # @return [Array] ordered list of required files
    # @api public
    def required_files(root = nil)
      sort!
      files = sources.map {|s| s.required_files }.flatten
      if root
        root = Pathname.new(File.expand_path(root))
        files = files.map {|f| Pathname.new(File.expand_path(f)).relative_path_from(root).to_s }
      end
      files
    end

    # Shows inspection of the container.
    # @api public
    def inspect
      "#<#{self.class.name}:#{self.object_id} #{self.sources.inspect}>"
    end

    # Returns all the tags provided by source files.
    # @return [Array]
    # @api public
    def provides
      sort!
      sources.map {|s| s.provides }.flatten
    end # provides

    # Returns all the tags required by source files, except for those which are
    # provided by other files in the container (i.e. unresolved dependencies)
    # @return [Array]
    # @api public
    def requires
      sort!
      sources.map {|s| s.requires }.flatten - provides
    end # requires

    # Private API

    # Performs topological sort inside current container.
    #
    # @api private
    def topsort
      graph = RGL::DirectedAdjacencyGraph.new
      # init vertices
      items = @normal_sources
      items.each {|item| graph.add_vertex(item) }
      # init edges
      items.each do |item|
        item.dependencies.each do |dependency|
          # If we can find items that provide the required dependency...
          # (dependency could be a wildcard as well, hence items)
          dependency_cache[dependency] ||= provides_tree.glob(dependency)
          # ... we draw an edge from every required item to the dependant item
          dependency_cache[dependency].each do |required_item|
            graph.add_edge(required_item, item)
          end
        end
      end

      begin
        graph.topsorted_vertices
      rescue RGL::TopsortedGraphHasCycles => e
        output_cycles(graph)
        raise e # fail fast
      end
    end

    # @api private
    def output_cycles(graph)
      cycles = graph.cycles
      error_msg = []
      unless cycles.empty?
        error_msg << "Jsus has discovered you have circular dependencies in your code."
        error_msg << "Please resolve them immediately!"
        error_msg << "List of circular dependencies:"
        cycles.each do |cycle|
          error_msg << "-" * 30
          error_msg << (cycle + [cycle.first]).map {|sf| sf.filename}.join(" => ")
        end
        error_msg << "-" * 30
        error_msg = error_msg.join("\n")
        Jsus.logger.fatal(error_msg)
      end
    end # output_cycles

    # Cached map of dependencies pointing to source files.
    # @return [Hash]
    # @api private
    def dependency_cache
      @dependency_cache ||= {}
    end

    # Cached tree of what source files provide.
    #
    # @api private
    # @return [Jsus::Util::Tree]
    def provides_tree
      @provides_tree ||= provides_tree!
    end

    # Returns tree of what source files provide.
    #
    # @api private
    # @return [Jsus::Util::Tree]
    def provides_tree!
      tree = Util::Tree.new
      # Provisions
      @normal_sources.each do |file|
        provisions = file.provides
        if replacement = @replacements.detect {|r| provisions.any? {|tag| tag == r.replaces } }
          file = replacement
        end
        provisions.each do |tag|
          tree[tag] = file
        end
      end
      tree
    end

    # @api private
    def insert_extensions!
      @extensions.each do |ext|
        ext_tag = ext.extends
        @sources.dup.each_with_index do |src, i|
          if src.provides.any? {|tag| tag == ext_tag }
            @sources.insert(i+1, ext)
            break
          end
        end
      end
    end # insert_extensions!

    # @api private
    def insert_replacements!
      @replacements.each do |repl|
        @sources.each_with_index do |src, i|
          if src.provides.any? {|tag| tag == repl.replaces }
            @sources[i] = repl
            break
          end
        end
      end
    end # insert_replacements!

    # Clears all caches for given container.
    #
    # @api private
    def clear_cache!
      @sorted = false
    end

    # List of methods that clear cached state of container when called.
    CACHE_CLEAR_METHODS = [
      "map!", "reject!", "inject!", "collect!", "delete", "delete_at"
    ]

    # List of methods that are delegated to underlying array of sources.
    DELEGATED_METHODS = [
      "==", "to_a", "map", "map!", "each", "inject", "inject!",
      "collect", "collect!", "reject", "reject!", "detect", "size",
      "length", "[]", "empty?", "index", "include?", "select",
      "delete_if", "delete", "-", "+", "|", "&"
    ]

    (DELEGATED_METHODS).each do |m|
      class_eval(<<-EVAL, __FILE__, __LINE__ + 1)
        def #{m}(*args, &block)
          #{"clear_cache!" if CACHE_CLEAR_METHODS.include?(m)}
          self.sources.send(:#{m}, *args, &block)
        end
      EVAL
    end
  end
end
