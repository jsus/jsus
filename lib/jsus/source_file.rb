module Jsus
  # Generic exception for 'bad' source files (no yaml header, for example)
  class BadSourceFileException < Exception; end

  #
  # SourceFile is a base for any Jsus operation.
  #
  # It contains general info about source as well as file content.
  #
  class SourceFile
    # Package owning the sourcefile
    # Is not directly used in SourceFile, but might be useful for introspection.
    attr_accessor :package

    # Original filename (immutable)
    attr_accessor :original_filename

    # Full filename (when initialized from file)
    attr_accessor :filename
    alias_method :path, :filename
    alias_method :path=, :filename=

    # Original source code (immutable)
    attr_reader :original_source

    # Source code (mutable)
    attr_accessor :source

    # Default namespace for source
    attr_reader :namespace


    # Constructors

    # Basic constructor.
    #
    # Initializes a file from source.
    # @param [String] source original source for the file
    # @param [Hash] options
    # @option options [String] :namespace source file namespace
    # @api semipublic
    def initialize(source, options = {})
      @namespace       = options[:namespace]
      @original_source = source.dup
      prepare_original_source
      @source          = @original_source.dup
      parse_header
      @original_source.freeze
    end

    #
    # Initializes a SourceFile given the filename and options
    #
    # @param [String] filename
    # @param [Hash] options
    # @option options [String] :namespace namespace to which the source file by default belongs
    # @return [Jsus::SourceFile]
    # @raise [Jsus::BadSourceFileException] when file cannot be parsed or does not exist
    # @api public
    def self.from_file(filename, options = {})
      filename = File.expand_path(filename)
      raise BadSourceFileException, "File does not exist." unless File.exists?(filename)
      source = File.open(filename, 'r:utf-8') {|f| f.read }
      source_file = new(source, options)
      source_file.filename = source_file.original_filename = filename
      source_file.original_filename.freeze
      source_file
    rescue Exception => e
      e.message.sub! /^/, "Unexpected exception happened while processing #{filename}: "
      Jsus.logger.error e.message
      raise e
    end

    # @return [Hash] a header parsed from YAML-formatted source file first comment.
    # @api public
    def header
      @header ||= {}
    end

    # @return [String] description of the source file.
    # @api public
    def description
      header["description"]
    end

    # @return [String] license of source file
    def license
      header["license"]
    end # license

    # @return [Array] list of authors
    # @api public
    def authors
      @authors
    end # authors

    # @return [Array] list of dependencies for given file
    # @api public
    def requires
      @requires
    end
    alias_method :dependencies, :requires
    alias_method :requirements, :requires

    # @return [Array] array with provides tags.
    # @api public
    def provides
      @provides
    end
    alias_method :provisions, :provides


    # @return [Jsus::Tag] tag for replaced file, if any
    # @api public
    def replaces
      @replaces
    end

    # @returns [Jsus::Tag] tag for source file, for which this one is an extension.
    # @example file Foo.js in package Core provides ['Class', 'Hash']. File
    # Bar.js in package Bar extends 'Core/Class'. That means its contents would be
    # appended to the Foo.js when compiling the result.
    # @api public
    def extends
      @extends
    end

    # @return [Boolean] whether the source file is an extension.
    # @api public
    def extension?
      extends && !extends.empty?
    end

    # @return [Boolean] whether the source file is an extension.
    # @api public
    def replacement?
      replaces && !replaces.empty?
    end # replacement?

    # @api private
    def reset
      @source   = @original_source.dup
      @filename = @original_filename.dup if @original_filename
    end # reset_linked

    # @return [Array] array of files required by this files including all the filenames for extensions.
    #    SourceFile filename always goes first, all the extensions are unordered.
    # @api public
    def required_files
      [filename].flatten
    end

    # @return [Hash] hash containing basic info with dependencies/provides tags' names
    #   and description for source file.
    #
    # @api public
    def to_hash
      {
        "desc"     => description,
        "requires" => requires.map {|tag| tag.namespace == namespace ? tag.name : tag.full_name},
        "provides" => provides.map {|tag| tag.name}
      }
    end

    # Human readable description of source file.
    # @return [String]
    # @api public
    def inspect
      self.to_hash.merge("namespace" => namespace).inspect
    end

    # @api public
    def ==(other)
      eql?(other)
    end

    # @api public
    def eql?(other)
      other.kind_of?(SourceFile) && filename == other.filename
    end

    # @api public
    def hash
      [self.class, filename].hash
    end

    private

    # @api private
    def prepare_original_source
      bom = RUBY_VERSION[/1.9/] ? "\uFEFF" : "\xEF\xBB\xBF"
      original_source.gsub!(bom, "")
    end # prepare_original_source

    # @api private
    def parse_header
      yaml_data = source.match(%r(^/\*\s*(---.*?)\*/)m)
      if yaml_data && yaml_data[1] && header = YAML.load(yaml_data[1])
        @header   = header
        @authors  = Array(@header["author"] || @header["authors"])
        @requires = process_tag_list(@header["requires"])
        @provides = process_tag_list(@header["provides"])
        @replaces = process_tag(@header["replaces"]) if @header["replaces"]
        @extends  = process_tag(@header["extends"]) if @header["extends"]
      else
        raise BadSourceFileException, "#{filename} is missing a header or header is invalid"
      end
    end # parse_header

    # @api private
    def process_tag(tag_name)
      if tag_name.kind_of?(String)
        tag_name.sub!(%r{^\.?/}, "") # remove leading slash / dot+slash
        if tag_name.index("/") || !namespace
          Tag[tag_name]
        else
          Tag["#{namespace}/#{tag_name}"]
        end
      elsif tag_name.kind_of?(Hash)
        # Quirky mootools tags
        ns, tag = tag_name.first[0], tag_name.first[1]
        # Removes strings like "/1.3.0" from the end of namespace part
        ns = ns.sub(%r{/(\d+\.?)+\d+$}, "")
        ns = Util::Inflection.random_case_to_mixed_case(ns)
        "#{ns}/#{tag}"
      else
        nil
      end
    end # process_tag

    # @api private
    def process_tag_list(tag_list)
      Array(tag_list).map {|tag| process_tag(tag) }.compact
    end # process_tag_list

  end
end
