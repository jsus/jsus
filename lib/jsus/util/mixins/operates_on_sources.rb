module Jsus
  module Util
    module Mixins
      module OperatesOnSources
        # @return [Array] source files for validation
        # @api public
        def source_files
          @source_files ||= []
        end
        alias_method :sources, :source_files

        # @param [Jsus::Pool, Jsus::Container, Array] pool_or_array_or_container
        #    source files for validation
        # @api public
        def source_files=(pool_or_array_or_container)
          case pool_or_array_or_container
          when Pool
            @source_files = pool_or_array_or_container.sources.to_a
          when Array
            @source_files = pool_or_array_or_container
          when Container
            @source_files = pool_or_array_or_container.to_a
          end
        end
        alias_method :sources=, :source_files=
      end # module OperatesOnSources
    end # module Mixins
  end # module Util
end # module Jsus
