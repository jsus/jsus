module Jsus
  #
  # Packager is a plain simple class accepting several source files
  # and joining their contents.
  #
  # It uses Container for storage which means it automatically sorts sources.
  #
  class Packager
    # Container with source files
    attr_accessor :container

    #
    # Inits packager with the given sources.
    #
    # @param [*SourceFile] sources source files
    # @api public
    def initialize(*sources)
      self.container = Container.new(*sources)
    end

    # @return [Jsus::Container] container with source files
    # @api public
    def sources
      container
    end

    # Concatenates all the sources' contents into a single string.
    # If given a filename, outputs into a file.
    #
    # @param [String, nil] output_file output file name
    # @return [String] concatenated source files
    # @api public
    def pack(output_file = nil)
      result = sources.map {|s| s.source }.join("\n")

      if output_file
        FileUtils.mkdir_p(File.dirname(output_file))
        File.open(output_file, "w") {|f| f << result }
      end

      result
    end


  end
end
