module Jsus
  module Util
    class Compressor
      attr_reader :result
      def initialize(source, options = {}) # todo - non-java compressor
        @result = case options[:method]
          when :uglifier then compress_with_uglifier(source)
          when :frontcompiler then compress_with_frontcompiler(source)
          when :closure then compress_with_closure(source)
          else compress_with_yui(source)
        end
      end # initialize

      def compress_with_yui(source)
        try_load("yui-compressor", 'yui/compressor') do
          YUI::JavaScriptCompressor.new(:munge => true).compress(source)
        end
      end # compress_with_yui

      def compress_with_uglifier(source)
        try_load("uglifier") do
          Uglifier.new.compile(source)
        end
      end

      def compress_with_frontcompiler(source)
        try_load('front-compiler') do
          FrontCompiler.new.compact_js(source)
        end
      end

      def compress_with_closure(source)
        try_load('closure-compiler') do
          Closure::Compiler.new.compile(source)
        end
      end

      private
      def try_load(gemname, lib = nil)
        begin
          require(lib || gemname)
          content = yield
        rescue LoadError
          Jsus.logger.fatal %{ERROR: You need "#{gemname}" gem in order to use compression option}
        end
        content
      end
    end # class Compressor
  end # module Util
end # module Jsus
