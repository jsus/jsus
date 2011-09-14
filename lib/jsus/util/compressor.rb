module Jsus
  module Util
    module Compressor
      class <<self
        # Compresses the javascript source with given compressor and returns
        # the result.
        #
        # @param [String] source javascript source code
        # @param [Hash] options
        # @option [Symbol] (:yui) method compressor to use.
        #   Available methods: :uglifier, :frontcompiler, :closure, :yui
        # @return [String] compressed js code
        # @api public
        def compress(source, options = {})
          method = options.fetch(:method, :yui)
          @result = case method.to_s
            when "uglifier" then compress_with_uglifier(source)
            when "frontcompiler" then compress_with_frontcompiler(source)
            when "closure" then compress_with_closure(source)
            when "yui" then compress_with_yui(source)
            else
              Jsus.logger.error "tried to use unavailable method #{method.inspect}"
              source
          end
        end # compress

        private

        # @api private
        def compress_with_yui(source)
          try_compress(source, "yuicompressor") do
            YUICompressor.compress_js(source, :munge => true)
          end
        end # compress_with_yui

        # @api private
        def compress_with_uglifier(source)
          try_compress(source, "uglifier") do
            Uglifier.compile(source, :squeeze => true, :copyright => false)
          end
        end # compress_with_uglifier

        # @api private
        def compress_with_frontcompiler(source)
          try_compress(source, 'front-compiler') do
            FrontCompiler.new.compact_js(source)
          end
        end # compress_with_frontcompiler

        # @api private
        def compress_with_closure(source)
          try_compress(source, 'closure-compiler') do
            Closure::Compiler.new.compile(source)
          end
        end # compress_with_closure

        # @api private
        def try_compress(source, library, libname = nil)
          if Jsus::Util.try_load(library, libname) then
            yield
          else
            source
          end
        rescue Exception => e
          Jsus.logger.error "#{library} could not compress the file, exception raised #{e}\n" <<
                            "Returning initial source"
          source
        end # try_compress
      end # class <<self
    end # module Compressor
  end # module Util
end # module Jsus
