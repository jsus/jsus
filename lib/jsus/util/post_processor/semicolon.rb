module Jsus
  module Util
    module PostProcessor
      class Semicolon < Base
        # Adds a semicolon to the beginning of every file
        # @return [Array]
        # @see Jsus::Util::PostProcessor::Base#process
        def process(options = {})
          source_files.map do |source|
            source = source.dup
            source.content = source.original_content.gsub(/^([^;])/, ";\n")
            source
          end
        end # process
      end # class Semicolon
    end # module PostProcessor
  end # module Util
end # module Jsus
