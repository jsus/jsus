module Jsus
  module Util
    module PostProcessor
      class MooltIE8 < Base
        # Removes everything between <ltIE8> </ltIE8> tags
        # @return [Array]
        # @see Jsus::Util::PostProcessor::Base#process
        def process(options = {})
          source_files.map do |file|
            file = file.dup
            file.source = file.source.gsub(/\/\/<ltIE8>.*?\/\/<\/ltIE8>/m, '')
            file.source = file.source.gsub(/\/\*<ltIE8>\*\/.*?\/\*<\/ltIE8>\*\//m, '')
            file
          end
        end # process
      end # class MooltIE8
    end # module PostProcessor
  end # module Util
end # module Jsus
