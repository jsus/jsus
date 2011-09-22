module Jsus
  module Util
    module PostProcessor
      autoload :Base,        "jsus/util/post_processor/base"
      autoload :Moocompat12, "jsus/util/post_processor/moocompat12"
      autoload :MooltIE8,    "jsus/util/post_processor/mooltie8"
      autoload :Semicolon,   "jsus/util/post_processor/semicolon"

      AVAILABLE_PROCESSORS = ["mooltie8", "moocompat12", "semicolon"].freeze
      # Accepts a collection of source files and list of processors and applies
      # these processors to the sources.
      #
      # @param [Array, Pool, Container] source_files source files
      # @param [Array] processors array with names of processors
      #        Available postprocs: "mooltie8", "moocompat12"
      # @return [Array] processed sources
      def self.process(source_files, processors)
        Array(processors).each do |processor|
          source_files = case processor.strip
          when /moocompat12/i
            Moocompat12.new(source_files).process
          when /mooltie8/i
            MooltIE8.new(source_files).process
          when /semicolon/i
            Semicolon.new(source_files).process
          else
            Jsus.logger.error "Unknown post-processor: #{processor}"
            source_files
          end
        end
        source_files
      end # self.process
    end # module PostProcessor
  end # module Util
end # module Jsus
