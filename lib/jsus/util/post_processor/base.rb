module Jsus
  module Util
    module PostProcessor
      # Base class for post-processing routines.
      # Post-processors are non-mutating boxes that accept a collection of
      # SourceFile-s on input and return a collection of SourceFiles on output.
      #
      # Post-processing is not mutating the arguments, but dupes them instead
      class Base
        include Jsus::Util::Mixins::OperatesOnSources

        # Constructor accepts pool or array or container and adds every file
        # to its source files set.
        # @param [Jsus::Pool, Jsus::Container, Array] source files to validate
        # @api public
        def initialize(pool_or_array_or_container = [])
          self.source_files = pool_or_array_or_container
        end # initialize

        # Processes input source files, return a resulting collection
        # @note This method should not mutate input sources
        # @abstract Override in subclasses
        # @param [Hash] options options hash
        # @return [Array] processed source files
        # @api public
        def process(options = {})
          raise NotImplementedError, "override #process in subclasses"
        end # process
      end # class Base
    end # module PostProcessor
  end # module Util
end # module Jsus
