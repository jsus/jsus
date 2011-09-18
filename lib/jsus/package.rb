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
    # @param [Hash] options
    # @option options [Jsus::Pool] :pool which pool the package should belong to.
    # @raise an error when the given directory doesn't contain a package.yml or package.json
    # file with meta info.
    # @api public
    def initialize(directory, options = {})
      self.directory          = File.expand_path(directory)
      if File.exists?(File.join(directory, 'package.yml'))
        self.header           = YAML.load_file(File.join(directory, 'package.yml'))
      elsif File.exists?(File.join(directory, 'package.json'))
        self.header           = JSON.load(File.open(File.join(directory, 'package.json'), 'r:utf-8') {|f| f.read })
      else
        Jsus.logger.fatal "Directory #{directory} does not contain a valid package.yml / package.json file!"
        raise "Directory #{directory} does not contain a valid package.yml / package.json file!"
      end
      Dir.chdir(directory) do
        files.each do |source|
          source_file = SourceFile.from_file(source, :package => self)
          if source_file
            if source_file.extension?
              extensions << source_file
            else
              source_files << source_file
            end
          else
            Jsus.logger.warn "#{source} is not found for #{name}"
          end
        end
      end
      if options[:pool]
        self.pool = options[:pool]
        self.pool << self
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
    alias_method :sources, :files

    # @return [Array] an array of provided tags including those provided by linked external dependencies.
    # @api public
    def provides
      source_files.map {|s| s.provides }.flatten | linked_external_dependencies.map {|d| d.provides }.flatten
    end

    # @return [Array] an array of provided tags names including those provided by linked external dependencies.
    # @api public
    def provides_names
      source_files.map {|s| s.provides_names(:short => true) }.flatten |
      linked_external_dependencies.map {|d| d.provides_names }.flatten
    end

    # @return [Array] an array of unresolved dependencies' tags for the package.
    # @api public
    def dependencies
      result = source_files.map {|source| source.dependencies }.flatten
      result |= linked_external_dependencies.map {|d| d.dependencies}.flatten
      result -= provides
      result
    end

    # @return [Array] an array of unresolved dependencies' names.
    # @api public
    def dependencies_names
      dependencies.map {|d| d.name(:short => true) }
    end

    # @return [Array] an array of external dependencies' tags (including resolved ones).
    # @api public
    def external_dependencies
      source_files.map {|s| s.external_dependencies }.flatten
    end

    # @return [Array] an array of external dependencies' names (including resolved ones).
    # @api public
    def external_dependencies_names
      external_dependencies.map {|d| d.name }
    end

    # @return [Jsus::Container] source files with external dependencies in correct order.
    # @api public
    def linked_external_dependencies
      @linked_external_dependencies ||= Container.new
    end

    # Compiles source files and linked external source files into a given category.
    # @param [String, nil] directory directory to output the result into
    # @return [String] content of merged source files
    # @api public
    def compile(directory = ".")
      fn = directory ? File.join(directory, filename) : nil
      Packager.new(*source_files_for_compilation).pack(fn)
    end

    # Generates tree structure for files in package into a json file.
    # @param [String] directory directory to output the result
    # @param [String] filename resulting filename
    # @return [Hash] hash with tree structure
    # @api public
    def generate_tree(directory = ".", filename = "tree.json")
      FileUtils.mkdir_p(directory)
      result = ActiveSupport::OrderedHash.new
      source_files.each do |source|
        components = File.dirname(source.relative_filename).split(File::SEPARATOR)
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

    # Looks up all the external dependencies in the pool.
    # @api semipublic
    def include_dependencies!
      source_files.each do |source|
        if pool
          deps = pool.lookup_dependencies(source).to_a - @source_files.to_a
          linked_external_dependencies << deps
        end
      end
    end

    # Executes #include_extensions for all the source files.
    # @api semipublic
    def include_extensions!
      source_files.each do |source|
        source.include_extensions!
      end
    end

    # Lists the required files for the package.
    # @return [Array] ordered list of full paths to required files.
    # @api public
    def required_files
      source_files.map {|s| s.required_files }.flatten
    end

    # Hash representation of the package.
    # @api public
    def to_hash
      {
        name => {
          :desc => description,
          :provides => provides_names,
          :requires => dependencies_names
        }
      }
    end


    # Container with source files
    # @return [Jsus::Container]
    # @api semipublic
    def source_files
      @source_files ||= Container.new
    end

    # Returns source files AND linked external dependencies joined in one array
    # @return [Array]
    # @api semipublic
    def source_files_for_compilation
      source_files.to_a + linked_external_dependencies.to_a
    end # source_files_for_compilation

    # Container with extensions (they aren't compiled or included into #reqired_files list)
    # @return [Jsus::Container]
    # @api semipublic
    def extensions
      @extensions ||= Container.new
    end

    # Private API


    # @param [Hash] new_header parsed header
    # @api private
    def header=(new_header)
      @header = new_header
    end

    # @param [Enumerable] new_value external dependencies
    # @api private
    def linked_external_dependencies=(new_value)
      @linked_external_dependencies = new_value
    end
  end
end
