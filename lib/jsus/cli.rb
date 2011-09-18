# TODO: document Cli class
module Jsus
  class CLI
    class << self
      attr_accessor :cli_options

      def run!(options)
        self.cli_options = options
        new.launch

        if options[:watch]
          input_dirs = [ options[:input_dir], options[:deps_dir] ].compact
          Jsus.logger.info "Jsus enters watch mode, it will watch your files for changes and relaunch itself"
          Jsus::Util::Watcher.watch(input_dirs) do |filename|
            Jsus.logger.info "#{filename} changed, recompiling..."
            new.launch
            Jsus.logger.info "... done"
          end
        end
      end
    end

    attr_accessor :options

    def initialize(options = Jsus::CLI.cli_options)
      @options = options
    end

    def setup_output_directory
      output_dir = Pathname.new(options[:output_dir])
      output_dir.mkpath
      output_dir
    end

    def launch
      checkpoint(:start)
      @output_dir = setup_output_directory
      @pool = preload_pool
      @package = load_package
      display_pool_stats(@pool) if options[:display_pool_stats]

      @resulting_sources = @package.source_files_for_compilation
      @resulting_sources = post_process(@resulting_sources, options[:postproc]) if options[:postproc]
      @package_content = compile_package(@resulting_sources)

      package_filename = @output_dir + @package.filename

      if options[:compress]
        File.open(package_filename.to_s.chomp(".js") + ".min.js", 'w') do |f|
          f.write compress_package(@package_content)
        end
      end

      package_filename.open('w') {|f| f << @package_content  }

      generate_supplemental_files
      validate_sources
      generate_includes if options[:generate_includes]
      generate_docs if options[:documented_classes] && !options[:documented_classes].empty?
      output_benchmarks
    rescue Exception => e
      $stderr.puts "Exception was raised: #{e.inspect}\n\nBacktrace: #{e.backtrace.join("\n")}"
      output_benchmarks
    end

    def preload_pool
      result = if options[:deps_dir]
        Jsus::Pool.new(options[:deps_dir])
      else
        Jsus::Pool.new
      end
      checkpoint(:pool)
      result
    end

    def load_package
      package = Jsus::Package.new(Pathname.new(options[:input_dir]), :pool => @pool)
      package.include_dependencies!
      package.include_extensions!
      checkpoint(:dependencies)
      package
    end

    def display_pool_stats(pool)
      checkpoint(:pool_stats)
      message = <<-EOF
Pool stats:
Main package:
#{display_package @package}

Supplementary packages:
#{pool.packages.map {|package| display_package package}.join }

EOF
      Jsus.logger.info message
    end

    def display_package(package)
      result = "Package: #{package.name}\n"
      package.source_files.to_a.sort_by {|sf| sf.filename}.each do |sf|
        result << "    [#{sf.relative_filename}]\n"
        result << "        Provides: [#{sf.provides_names.join(", ")}]\n"
        result << "        Requires: [#{sf.requires_names.join(", ")}]\n"
      end
      result << "\n"
    end

    def compile_package(sources)
      result = Packager.new(*sources.to_a).pack(nil)
      checkpoint(:compilation)
      result
    end

    # Modificate content string
    def post_process(source_files, processors)
      result = Util::PostProcessor.process(source_files, processors)
      checkpoint(:postproc)
      result
    end

    def compress_package(content)
      compression_method = options.fetch(:compression_method, :yui)
      compressed_content = Jsus::Util::Compressor.compress(content, :method => compression_method)
      if compressed_content != ""
        @compression_ratio = compressed_content.size.to_f / content.size.to_f
      else
        @compression_ratio = 1.00
        Jsus.logger.error "YUI compressor could not parse input. \n" <<
                          "Compressor command used: #{compressor.command.join(' ')}"
      end
      checkpoint(:compress)

      compressed_content
    end

    def generate_supplemental_files
      @package.generate_scripts_info(@output_dir) unless options[:without_scripts_info]
      @package.generate_tree(@output_dir) unless options[:without_tree_info]
      checkpoint(:supplemental_files)
    end

    def generate_includes
      includes_root = Pathname.new(options[:includes_root] || @output_dir)
      Compiler.generate_includes(@package, includes_root, @output_dir + "includes.js")
      checkpoint(:includes)
    end

    def generate_docs
      documenter = Jsus::Util::Documenter.new(:highlight_source => !options[:no_syntax_highlight])
      @package.source_files.each {|source| documenter << source }
      @pool.sources.each {|source| documenter << source }
      documenter.only(options[:documented_classes]).generate(@output_dir + "/docs")
      checkpoint(:documentation)
    end

    def validate_sources
      validators_map = {"mooforge" => Jsus::Util::Validator::Mooforge}
      (options[:validators] || []).each do |validator_name|
        if validator = validators_map[validator_name]
          errors = validator.new(@pool.sources.to_a & @package.source_files.to_a).validation_errors
          unless errors.empty?
            Jsus.logger.info "Validator #{validator_name} found errors: " <<
                             errors.map {|e| Jsus.logger.info "  * #{e}"}.join("\n")
          end
        else
          Jsus.logger.info "No such validator: #{validator_name}"
        end
      end
      checkpoint(:validators)
    end

    def output_benchmarks
      if options[:benchmark]
        message = "Benchmarking results:\n"
        message << "Total execution time:   #{formatted_time_for(:all)}\n"
        message << "\n"
        message << "Of them:\n"
        message << "Pool preloading time:   #{formatted_time_for(:pool)}\n" if checkpoint?(:pool)
        message << "Docs generation time:   #{formatted_time_for(:documentation)}\n" if checkpoint?(:documentation)
        message << "Total compilation time: #{formatted_time_for(:compilation)}\n" if checkpoint?(:compilation)
        message << "Post-processing time:   #{formatted_time_for(:postproc)}\n" if checkpoint?(:postproc)
        message << "Compression time:       #{formatted_time_for(:compress)}\n" if checkpoint?(:compress)
        message << "\n"
        message << "Compression ratio: #{sprintf("%.2f%%", @compression_ratio * 100)}\n" if Jsus.verbose? && @compression_ratio
        Jsus.logger.info message
      end
    end

    def checkpoint(checkpoint_name)
      @checkpoints ||= {}
      @time_for    ||= {}
      @checkpoints[checkpoint_name] = Time.now
      if @last_checkpoint
        @time_for[checkpoint_name] = @checkpoints[checkpoint_name] - @last_checkpoint
      end
      @last_checkpoint = Time.now
    end

    def checkpoint?(checkpoint_name)
      @checkpoints[checkpoint_name]
    end

    def time_for(checkpoint_name)
      if checkpoint_name == :all
        @last_checkpoint - @checkpoints[:start]
      else
        @time_for[checkpoint_name]
      end
    end

    def formatted_time_for(checkpoint_name)
      "#{format("%.3f", time_for(checkpoint_name))}s"
    end
  end
end
