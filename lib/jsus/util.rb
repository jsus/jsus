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

      # Reads file in UTF-8 encoding in a safe way.
      # Some ruby versions mess up the encodings and some spill out lots of warnings
      # unless you do the right thing
      def read_file(filename)
        mode_string = RUBY_VERSION =~ /^1.9/ ? 'r:utf-8' : 'r'
        File.open(filename, mode_string) {|f| f.read }
      end # read_file
    end # class <<self
  end # Util
end # Jsus
