module Jsus
  # Utility namespace.
  module Util
    autoload :Compressor,    'jsus/util/compressor'
    autoload :Tree,          'jsus/util/tree'
    autoload :Documenter,    'jsus/util/documenter'
    autoload :Validator,     'jsus/util/validator'
    autoload :Inflection,    'jsus/util/inflection'
    autoload :FileCache,     'jsus/util/file_cache'
    autoload :CodeGenerator, 'jsus/util/code_generator'
    autoload :Logger,        'jsus/util/logger'

    class <<self
      # Tries to load given gem.
      # @param [String] gemname gem name
      # @param [String, nil] lib path to load. When set to nil, uses gemname
      #    param
      # @return [Boolean] true if that lib could be required, false otherwise
      # @api semipublic
      def try_load(gemname, lib = nil)
        begin
          require(lib || gemname)
          true
        rescue LoadError
          Jsus.logger.fatal %{ERROR: You need "#{gemname}" gem in order to use compression option}
          false
        end
      end
    end # class <<self
  end # Util
end # Jsus
