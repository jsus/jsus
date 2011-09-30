module Jsus
  #
  # Tag is basically just a string that contains a package name and a name for class
  # (or not necessarily a class) which the given SourceFile provides/requires/extends/replaces.
  #
  # @example
  # "Core/Class" is a tag
  class Tag
    # Default separator of full name parts
    SEPARATOR = "/".freeze

    # Constructors

    #
    # Creates a tag from given string.
    #
    # @example
    #
    #     a = Tag.new("Class")         # :namespace => nil,             :name => "Class"
    #     b = Tag.new("Core/Class")    # :namespace => "Core",          :name => "Class"
    #     c = Tag.new("Mootools/Core") # :namespace => "Mootools/Core", :name => "Class"
    #
    # @param [String] name full tag name
    # @api public
    def initialize(full_name)
      self.full_name = full_name
    end

    # Full name, including namespace
    # @return [String]
    # @api public
    def full_name
      if namespace
        "#{namespace}#{SEPARATOR}#{name}"
      else
        "#{name}"
      end
    end # full_name
    alias_method :to_s, :full_name


    # Assigns full name
    # @param [String] full_name full tag name, including namespace
    # @api semipublic
    def full_name=(full_name)
      @full_name     = full_name
      name_parts     = @full_name.split(SEPARATOR)
      self.namespace = name_parts[0..-2].join(SEPARATOR) if name_parts.size > 1
      self.name      = name_parts[-1]
    end # full_name=

    # Instantiates a tag.
    # @note When given a tag instead of tag name, returns the input
    # @api public
    def self.new(tag_or_name, *args, &block)
      if tag_or_name.kind_of?(Tag)
        tag_or_name
      else
        super
      end
    end

    # Alias for Tag.new
    # @api public
    def self.[](*args)
      new(*args)
    end

    # Public API

    # Returns the last part of the tag.
    # @example
    #     Tag.new('Core/Class').name # => 'Class'
    # @return [String] last part of the tag
    # @api public
    def name
      @name
    end

    # Set name.
    # @param [String] name
    # @api semipublic
    def name=(name)
      @name = normalize(name)
    end # name=


    # Name without namespace
    # @return [String]
    # @api public
    attr_reader :namespace

    # Set namespace
    # @param [String] namespace
    # @api semipublic
    def namespace=(namespace)
      @namespace = normalize(namespace)
    end # namespace=

    # Normalizes name or namespace (converts snake_case to MixedCase)
    # @param [String] string
    # @return [String]
    # @api semipublic
    def normalize(string)
      return unless string
      return string if string.include?("*")
      parts = string.split(SEPARATOR)
      parts.map {|part| Util::Inflection.random_case_to_mixed_case_preserve_dots(part) }.join(SEPARATOR)
    end # normalize

    # @return [Boolean] whether name is empty
    # @api public
    def empty?
      !@name || @name.empty?
    end

    # @api public
    def ==(other)
      if other.kind_of?(Tag)
        self.name == other.name && self.namespace == other.namespace
      else
        super
      end
    end

    # @api semipublic
    def eql?(other)
      self.==(other)
    end

    # @api semipublic
    def hash
      [self.name, self.namespace].hash
    end

    # @return [String] human-readable representation
    # @api public
    def inspect
      "<Jsus::Tag: #{full_name}>"
    end
  end
end
