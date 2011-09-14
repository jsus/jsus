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
        if source.kind_of?(Array) || source.kind_of?(Container)
          source.each {|s| self.push(s) }
        else
          sources.push(source) unless sources.include?(source)
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

    # Contains the source files. Please, don't use sources directly, if you
    # depend on them to be topologically sorted. Use collection methods like
    # inject/reject/map directly on the container instead.
    #
    # @return [Array]
    # @api semipublic
    def sources
      @sources ||= []
    end
    alias_method :to_a, :sources

    # Sets sources to new value.
    #
    # @api semipublic
    def sources=(new_value) # :nodoc:
      @sources = new_value
    end

    # Topologically sorts items in container if required.
    #
    # @return [self]
    # @api semipublic
    def sort!
      unless sorted?
        remove_replaced_files!
        self.sources = topsort
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

    # Private API

    # Performs topological sort inside current container.
    #
    # @api private
    def topsort
      graph = RGL::DirectedAdjacencyGraph.new
      # init vertices
      items = sources
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
      rescue RGL::TopsortedGraphHasCycles
        output_cycles(graph)
        []
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
      sources.each do |file|
        file.provides.each do |tag|
          tree[tag] = file
        end
      end
      # Replacements
      sources.each do |file|
        if file.replaces
          tree[file.replaces] = file
        end
      end
      tree
    end

    # Removes files which are marked as replaced by other sources.
    #
    # @api private
    def remove_replaced_files!
      sources.reject! do |sf|
        !sf.provides.empty? && sf.provides.any? { |tag| replacements_tree[tag] && replacements_tree[tag] != sf }
      end
    end

    # Cached tree of what source files replace.
    #
    # @api private
    # @return [Jsus::Util::Tree]
    def replacements_tree
      @replacements_tree ||= replacements_tree!
    end

    # Returns tree of what source files replace.
    #
    # @api private
    # @return [Jsus::Util::Tree]
    def replacements_tree!
      tree = Util::Tree.new
      sources.each do |file|
        if file.replaces
          tree[file.replaces] = file
        end
      end
      tree
    end

    # Clears all caches for given container.
    #
    # @api private
    def clear_cache!
      @provides_tree = nil
      @replacements_tree = nil
      @dependency_cache = nil
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
      class_eval <<-EVAL
        def #{m}(*args, &block)
          sort!
          #{"clear_cache!" if CACHE_CLEAR_METHODS.include?(m)}
          self.sources.send(:#{m}, *args, &block)
        end
      EVAL
    end
  end
end
