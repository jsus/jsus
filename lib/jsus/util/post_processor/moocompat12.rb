module Jsus
  module Util
    module PostProcessor
      class Moocompat12 < Base
        # Removes everything between <1.2compat> </1.2compat> tags
        # @return [Array]
        # @see Jsus::Util::PostProcessor::Base#process
        def process(options = {})
          source_files.map do |source|
            source = source.dup
            source.content = source.original_content.gsub(/\/\/<1.2compat>.*?\/\/<\/1.2compat>/m, '')
            source.content = source.original_content.gsub(/\/\*<1.2compat>\*\/.*?\/\*<\/1.2compat>\*\//m, '')
            source
          end
        end # process
      end # class Moocompat12
    end # module PostProcessor
  end # module Util
end # module Jsus
