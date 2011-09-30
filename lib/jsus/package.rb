module Jsus
  #
  # Package is a (self-contained) unit with all the info required to build
  # a javascript package.
  #

  class Package
    # directory which this package resides in (full path)
    attr_accessor :directory
    # an instance of Jsus::Pool
    attr_accessor :pool

    # Constructors
    #
    # Creates a package from given directory.
    #
    # @param [String] directory path to directory containing a package
    # @raise [RuntimeError] when the given directory doesn't contain a
    #                       package.yml or package.json file with meta info.
    # @api public
    def initialize(directory)
      self.directory          = File.expand_path(directory)
      @header = if File.exists?(File.join(directory, 'package.yml'))
        YAML.load_file(File.join(directory, 'package.yml'))
      elsif File.exists?(File.join(directory, 'package.json'))
        JSON.load(File.open(File.join(directory, 'package.json'), 'r:utf-8') {|f| f.read })
      else
        Jsus.logger.fatal "Directory #{directory} does not contain a valid package.yml / package.json file!"
        raise "Directory #{directory} does not contain a valid package.yml / package.json file!"
      end
      Dir.chdir(directory) do
        files.each do |filename|
          source_file = SourceFile.from_file(filename, :namespace => name)
          source_file.package = self
          if source_file
            if source_file.extension?
              extensions << source_file
            else
              source_files << source_file
            end
          else
            Jsus.logger.warn "#{filename} is not found for #{name}"
          end
        end
      end
    end


    # Public API

    # @return [Hash] parsed package header.
    # @api public
    def header
      @header ||= {}
    end

    # @return [String] a package name.
    # @api public
    def name
      header["name"] ||= ""
    end

    # @return [String] a package description.
    # @api public
    def description
      header["description"] ||= ""
    end

    # @return [String] a filename for compiled package.
    # @api public
    def filename
      header["filename"] ||= Jsus::Util::Inflection.snake_case(name) + ".js"
    end

    # @return [Array] a list of sources filenames.
    # @api public
    def files
      header["files"] = header["files"] || header["sources"] || []
    end

    # @return [Array] an array of provided tags
    # @api public
    def provides
      source_files.map {|s| s.provides }.flatten
    end
    alias_method :provisions, :provides

    # @return [Array] array dependencies tags for all source files in the package
    # @api public
    def dependencies
      result = source_files.map {|source| source.dependencies }.flatten
      result -= provides
      result
    end
    alias_method :requires, :dependencies
    alias_method :requirements, :dependencies

    # Generates tree structure for files in package into a json file.
    # @param [String] directory directory to output the result
    # @param [String] filename resulting filename
    # @return [Hash] hash with tree structure
    # @api public
    def generate_tree(directory = ".", filename = "tree.json")
      FileUtils.mkdir_p(directory)
      result = ActiveSupport::OrderedHash.new
      directory_components = self.directory.split(File::SEPARATOR)
      source_files.each do |source|
        components = File.dirname(source.filename).split(File::SEPARATOR)
        components -= directory_components
        # deleting source dir by convention
        components.delete("Source")
        node = result
        components.each do |component|
          node[component] ||= ActiveSupport::OrderedHash.new
          node = node[component]
        end
        node[File.basename(source.filename, ".js")] = source.to_hash
      end
      File.open(File.join(directory, filename), "w") { |resulting_file| resulting_file << JSON.pretty_generate(result) }
      result
    end

    # Generates info about resulting compiled package into a json file.
    # @param [String] directory directory to output the result
    # @param [String] filename resulting filename
    # @return [Hash] hash with scripts info
    # @api public
    def generate_scripts_info(directory = ".", filename = "scripts.json")
      FileUtils.mkdir_p directory
      File.open(File.join(directory, filename), "w") { |resulting_file| resulting_file << JSON.pretty_generate(self.to_hash) }
      self.to_hash
    end

    # Lists the required files for the package.
    # @return [Array] ordered list of full paths to required files.
    # @api public
    def required_files
      source_files.map {|s| s.required_files }.flatten
    end

    # Hash representation of the package.
    # @return [Hash]
    # @api public
    def to_hash
      {
        name => {
          :description => description,
          :provides    => provides.map {|tag| tag.name },
          :requires    => requires.map {|tag| tag.namespace == name ? tag.name : tag.full_name }
        }
      }
    end


    # Array with source files
    # @return [Array]
    # @api semipublic
    def source_files
      @source_files ||= []
    end

    # Array with extensions
    # @return [Array]
    # @api semipublic
    def extensions
      @extensions ||= []
    end

    # Private API


    # @param [Hash] new_header parsed header
    # @api private
    def header=(new_header)
      @header = new_header
    end
  end
end
