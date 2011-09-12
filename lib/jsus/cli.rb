module Jsus
  class Cli
    class << self
      attr_accessor :cli_options

      def run!(options)
        self.cli_options = options
        new.launch
        
        if options[:watch]
          input_dirs = [ options[:input_dir], options[:deps_dir] ]
          Jsus::Util::Watcher(input_dirs, options[:output_dir]) do
            new.launch
          end
        end
      end
    end

    attr_accessor :options

    def initialize(options = Jsus::Cli.cli_options)
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
      @package_content = compile_package(@package)
      post_process!(@package_content, options[:postproc]) if options[:postproc]
      
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
    end

    def preload_pool
      if options[:deps_dir]
        Jsus::Pool.new(options[:deps_dir])
      else
        Jsus::Pool.new
      end.tap { checkpoint(:pool) }
    end

    def load_package
      package = Jsus::Package.new(Pathname.new(options[:input_dir]), :pool => @pool)
      package.include_dependencies!
      checkpoint(:dependencies)
      package
    end

    def display_pool_stats(pool)
      checkpoint(:pool_stats)
      puts ""
      puts "Pool stats:"
      puts ""
      puts "Main package:"
      display_package @package
      puts "Supplementary packages:"
      pool.packages.each do |package|
        display_package package
      end
      puts ""
    end

    def display_package(package)
      puts "Package: #{package.name}"
      package.source_files.to_a.sort_by {|sf| sf.filename}.each do |sf|
        puts "    [#{sf.relative_filename}]"
        puts "        Provides: [#{sf.provides_names.join(", ")}]"
        puts "        Requires: [#{sf.requires_names.join(", ")}]"
      end
      puts ""
    end

    def compile_package(package)
      package.compile(nil).tap { checkpoint(:compilation) }
    end

    # Modificate content string
    def post_process!(content, postproc)
      Compiler.post_process!(content, postproc)
      checkpoint(:postproc)
    end

    def compress_package(content)
      compressed_content = Jsus::Util::Compressor.new(content).result
      if compressed_content != ""
        @compression_ratio = compressed_content.size.to_f / content.size.to_f
      else
        @compression_ratio = 1.00
        Jsus.logger.error "ERROR: YUI compressor could not parse input. "
        Jsus.logger.error "Compressor command used: #{compressor.command.join(' ')}"
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
      includes_root = Pathname.new(options[:includes_root]) || @output_dir
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
            puts "Validator #{validator_name} found errors: "
            errors.each {|e| puts "  * #{e}"}
          end
        else
          puts "No such validator: #{validator_name}"
        end
      end
      checkpoint(:validators)
    end

    def output_benchmarks
      if options[:benchmark]
        puts "Benchmarking results:"
        puts "Total execution time:   #{formatted_time_for(:all)}"
        puts ""
        puts "Of them:"
        puts "Pool preloading time:   #{formatted_time_for(:pool)}"
        puts "Docs generation time:   #{formatted_time_for(:documentation)}" if options[:documented_classes] && !options[:documented_classes].empty?
        puts "Total compilation time: #{formatted_time_for(:compilation)}"
        puts "Post-processing time:   #{formatted_time_for(:postproc)}" if options[:postproc]
        puts "Compression time:       #{formatted_time_for(:compress)}" if options[:compress]
        puts ""
        puts "Compression ratio: #{sprintf("%.2f%%", @compression_ratio * 100)}" if Jsus.verbose? && @compression_ratio
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
