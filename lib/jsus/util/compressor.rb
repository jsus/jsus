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
          @result = case method
            when :uglifier then compress_with_uglifier(source)
            when :frontcompiler then compress_with_frontcompiler(source)
            when :closure then compress_with_closure(source)
            when :yui then compress_with_yui(source)
            else
              Jsus.logger.error "tried to use unavailable method #{method.inspect}"
              source
          end
        end # compress

        private

        # @api private
        def compress_with_yui(source)
          if Jsus::Util.try_load("yui-compressor", 'yui/compressor')
            YUI::JavaScriptCompressor.new(:munge => true).compress(source)
          else
            source
          end
        end # compress_with_yui

        # @api private
        def compress_with_uglifier(source)
          if Jsus::Util.try_load("uglifier")
            Uglifier.compile(source, :squeeze => true, :copyright => false)
          else
            source
          end
        end # compress_with_uglifier

        # @api private
        def compress_with_frontcompiler(source)
          if Jsus::Util.try_load('front-compiler')
            FrontCompiler.new.compact_js(source)
          else
            source
          end
        end # compress_with_frontcompiler

        # @api private
        def compress_with_closure(source)
          if Jsus::Util.try_load('closure-compiler')
            Closure::Compiler.new.compile(source)
          else
            source
          end
        end # compress_with_closure
      end # class <<self
    end # module Compressor
  end # module Util
end # module Jsus
