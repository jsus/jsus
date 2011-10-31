module Jsus
  module Util
    # Very opinionated documenter class. It uses Murdoc to generate the
    # documentation using the template and stylesheet bundled with the
    # jsus gem file. Also generates indices for navigation.
    class Documenter
      # Default documenter options
      DEFAULT_OPTIONS = {:highlight_source => true}

      # Documenter options
      attr_accessor :options

      # Constructor. Accepts options as the argument.
      # @param [Hash] options
      # @option options [Boolean] :highlight_source use syntax highlighting
      #    (via pygments)
      # @api public
      def initialize(options = DEFAULT_OPTIONS)
        require "murdoc"
        self.options = options
      rescue LoadError
        raise "You should install murdoc gem in order to produce documentation"
      end

      # Generates documentation tree into the given directory.
      #
      # @param [String] doc_dir output directory
      # @api public
      def generate(doc_dir = Dir.pwd)
        #FileUtils.rm_rf(doc_dir)
        FileUtils.mkdir_p(doc_dir)
        template_path = File.dirname(__FILE__) + "/../../../markup"
        template = File.read("#{template_path}/template.haml")
        index_template = File.read("#{template_path}/index_template.haml")
        stylesheet_path = "#{template_path}/stylesheet.css"
        documented_sources.traverse(true) do |node|
          if node.value # leaf
            dir = doc_dir + File.dirname(node.full_path)
            FileUtils.mkdir_p(dir)
            file_from_contents(dir + "/#{node.name}.html", create_documentation_for_source(node.value, template))
          else
            dir = doc_dir + node.full_path
            FileUtils.mkdir_p(dir)
            FileUtils.cp(stylesheet_path, dir)
            file_from_contents(dir + "/index.html", create_index_for_node(node, index_template))
          end
        end
      end

      # Adds a source file to the documented source tree
      #
      # @param [Jsus::SourceFile] source pushed source
      # @api public
      def <<(source) # :nodoc:
        filename = File.basename(source.filename)
        if source.package

          tree["#{source.package.name}/#{filename}"] = source
        else
          tree["#{filename}"] = source
        end
        self
      end

      # @return [Jsus::Util::Tree] tree with all sources
      # @api public
      def tree
        @tree ||= Tree.new
      end

      # Scope for documentation in pathspec format. See Jsus::Util::Tree::Node#find_children_matching
      # @return [Array] scope
      # @api public
      def current_scope
        @current_scope ||= default_scope
      end

      # @return [Array] default documentation scope
      # @api semipublic
      def default_scope
        ["/**/*"]
      end

      # @api semipublic
      def current_scope=(scope)
        @current_scope = scope
      end

      # Sets documenter to exclusive scope for documentation.
      # Exclusive scope overrides all the other scopes.
      # @param [Array, String] scope documentation scope
      # @api public
      def only(scope)
        result = clone
        result.current_scope = [scope].flatten
        result
      end

      # Sets documenter to additive scope for documentation.
      # Additive scopes match any of the pathspecs given
      #
      # @param [Array, String] scope documentation scope
      # @api public
      def or(scope)
        result = clone
        result.current_scope = current_scope + [scope].flatten
        result
      end

      # @return [Jsus::Util::Tree] tree with documented sources only
      # @api public
      def documented_sources
        @documented_sources ||= documented_sources!
      end

      # @see #documented_sources
      # @api private
      def documented_sources!
        doctree = Tree.new
        current_scope.map {|pathspec| tree.find_nodes_matching(pathspec) }.
                      flatten.each {|s| doctree.insert(s.full_path, s.value)}
        doctree
      end

      protected

      # @api private
      def create_documentation_for_source(source, template) # :nodoc:
        skipped_lines = 0
        content = source.original_source.gsub(/\A\s*\/\*.*?\*\//m) {|w| skipped_lines += w.split("\n").size; "" }
        annotator = Murdoc::Annotator.new(content, :javascript, options)
        Murdoc::Formatter.new(template).render(:paragraphs => annotator.paragraphs, :header => source.header, :source => source, :skipped_lines => skipped_lines)
      end

      # @api private
      def create_index_for_node(node, template) # :nodoc:
        Haml::Engine.new(template).render(self, :node => node)
      end

      # @api private
      def file_from_contents(filename, contents) # :nodoc:
        File.open(filename, "w+") {|f| f << contents }
      end
    end
  end
end
