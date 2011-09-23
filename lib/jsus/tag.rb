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
    attr_reader :full_name

    # Name without namespace
    # @return [String]
    # @api public
    attr_reader :name

    # Namespace part of tag name or nil
    # @return [String, nil]
    # @api public
    attr_reader :namespace


    # Assigns full name
    # @param [String] full_name full tag name, including namespace
    # @api semipublic
    def full_name=(full_name)
      @full_name = full_name
      name_parts = @full_name.split(SEPARATOR)
      @namespace = name_parts[0..-2].join(SEPARATOR) if name_parts.size > 1
      @name      = name_parts[-1]
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
    alias_method :to_s, :name

    # @return [Boolean] whether name is empty
    # @api public
    def empty?
      !@name || @name.empty?
    end

    # @api public
    def ==(other)
      if other.kind_of?(Tag)
        self.name == other.name
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
      self.name.hash
    end

    # @return [String] human-readable representation
    # @api public
    def inspect
      "<Jsus::Tag: #{name}>"
    end
  end
end
