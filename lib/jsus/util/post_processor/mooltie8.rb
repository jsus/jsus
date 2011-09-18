module Jsus
  module Util
    module PostProcessor
      class MooltIE8 < Base
        # Removes everything between <ltIE8> </ltIE8> tags
        # @return [Array]
        # @see Jsus::Util::PostProcessor::Base#process
        def process(options = {})
          source_files.map do |source|
            source = source.dup
            source.content = source.original_content.gsub(/\/\/<ltIE8>.*?\/\/<\/ltIE8>/m, '')
            source.content = source.original_content.gsub(/\/\*<ltIE8>\*\/.*?\/\*<\/ltIE8>\*\//m, '')
            source
          end
        end # process        
      end # class MooltIE8
    end # module PostProcessor
  end # module Util
end # module Jsus