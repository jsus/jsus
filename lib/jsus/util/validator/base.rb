module Jsus
  module Util
    # Base for any validator class.
    module Validator
      class Base
        include Mixins::OperatesOnSources

        # Constructor accepts pool or array or container and adds every file
        # to its source files set.
        # @param [Jsus::Pool, Jsus::Container, Array] source files to validate
        # @api public
        def initialize(pool_or_array_or_container = [])
          self.source_files = pool_or_array_or_container
        end

        # @return [Boolean] whether or not given sources conform to given set of rules
        # @api public
        def validate
          validation_errors.empty?
        end

        # @return [Array] list of validation errors
        # @override
        def validation_errors
          []
        end

        # Shortcut for creating and validating a list of items
        # @param [*Array] args passed to #new
        # @api public
        def self.validate(*args)
          new(*args).validate
        end
      end
    end
  end # Util
end
