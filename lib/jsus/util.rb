module Jsus
  # Utility namespace.
  module Util
    autoload :CodeGenerator, 'jsus/util/code_generator'
    autoload :Compressor,    'jsus/util/compressor'
    autoload :Documenter,    'jsus/util/documenter'
    autoload :FileCache,     'jsus/util/file_cache'
    autoload :Inflection,    'jsus/util/inflection'
    autoload :Logger,        'jsus/util/logger'
    autoload :Mixins,        'jsus/util/mixins'
    autoload :PostProcessor, 'jsus/util/post_processor'
    autoload :Tree,          'jsus/util/tree'
    autoload :Validator,     'jsus/util/validator'
    autoload :Watcher,       'jsus/util/watcher'

    class <<self
      # Tries to load given gem.
      # @param [String] gemname gem name
      # @param [String, nil] lib path to load. When set to nil, uses gemname
      #    param
      # @return [Boolean] true if that lib could be required, false otherwise
      # @api semipublic
      def try_load(gemname, lib = nil)
        required_file = lib || gemname
        begin
          require(required_file)
          true
        rescue LoadError
          Jsus.logger.error %{ERROR: missing file #{required_file}}
          false
        end
      end
    end # class <<self
  end # Util
end # Jsus
