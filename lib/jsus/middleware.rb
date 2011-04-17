require 'rack/utils'
module Jsus
  class Middleware
    include Rack
    class <<self
      DEFAULT_SETTINGS = {
        :packages_dir     => ".",
        :cache            => false,
        :cache_path       => nil,
        :prefix           => "jsus"
      }.freeze

      def settings
        @settings ||= DEFAULT_SETTINGS.dup
      end # settings

      def settings=(new_settings)
        settings.merge!(new_settings)
      end # settings=

      def pool
        @pool ||= Jsus::Pool.new(settings[:packages_dir])
      end # pool
    end # class <<self

    def initialize(app)
      @app = app
    end # initialize

    def call(env)
      path = Utils.unescape(env["PATH_INFO"])
      return @app.call(env) unless handled_by_jsus?(path)
      path.sub!(path_prefix_regex, "")
      components = path.split("/")
      return @app.call(env) unless components.size >= 2
      if components[0] == "require"
        generate(components[1].sub(/.js$/, ""))
      else
        not_found!
      end
    end # call

    protected

    def generate(path_string)
      path_args = parse_path_string(path_string)
      # p path_args
      files = []
      path_args[:include].each {|tag| files += get_associated_files(tag).to_a }
      path_args[:exclude].each {|tag| files -= get_associated_files(tag).to_a }
      if !files.empty?
        respond_with(Container.new(*files).map {|f| f.content }.join("\n"))
      else
        not_found!
      end
    end # generate

    # Notice: + is a space after url decoding
    # input:
    # "Package:A~Package:C Package:B~Other:D"
    # output:
    # {:include => ["Package/A", "Package/B"], :exclude => ["Package/C", "Other/D"]}
    def parse_path_string(path_string)
      path_string = " " + path_string unless path_string[0,1] =~ /\+\-/
      included = []
      excluded = []
      path_string.scan(/([ ~])([^ ~]*)/) do |op, arg|
        arg = arg.gsub(":", "/")
        if op == " "
          included << arg
        else
          excluded << arg
        end
      end
      {:include => included, :exclude => excluded}
    end # parse_path_string

    def get_associated_files(source_file_or_package)
      if package = pool.packages.detect {|pkg| pkg.name == source_file_or_package}
        package.include_dependencies!
        package.linked_external_dependencies.to_a + package.source_files.to_a
      elsif source_file = pool.lookup(source_file_or_package)
        pool.lookup_dependencies(source_file) << source_file
      else
        []
      end
    end # get_associated_files

    def not_found!
      [404, {"Content-Type" => "text/plain"}, ["Jsus doesn't anything know about this entity"]]
    end # not_found!

    def respond_with(text)
      [200, {"Content-Type" => "text/javascript"}, [text]]
    end # respond_with


    def handled_by_jsus?(path)
      path =~ path_prefix_regex
    end # handled_by_jsus?

    def path_prefix
      @path_prefix ||= self.class.settings[:prefix] ? "/javascripts/#{self.class.settings[:prefix]}/" : "/javascripts/"
    end # path_prefix

    def path_prefix_regex
      @path_prefix_regex ||= %r{^#{path_prefix}}
    end # path_prefix_regex

    def pool
      self.class.pool
    end # pool

  end # class Middleware
end # module Jsus