class Jsus::Util::Watcher
  class << self
    def watch(input_dirs, output_dir, options)
      new(*args)
    end
  end
  
  def initialize(input_dirs, output_dir, options = {}, &on_change)
    
    require 'fssm'
    Jsus.logger.info "Jsus enters watch mode, it will watch your files for changes and relaunch itself"
    
    @output_dir = output_dir
    @input_dirs = input_dirs.compact.map {|path| File.expand_path(path)}
    @on_change = on_change

    @output_dir.reject! do |dir|
      # This is a work around for rb-fsevent quirk
      # Apparently, when your dependency dir is a child directory for your input dir,
      # You get problems.
      result = false
      pathname_traversal = Pathname.new(dir).descend do |parent|
        parent = parent.to_s
        result ||= @output_dir.include?(parent) && parent != dir
      end
      result
    end

    Jsus.logger.info("Watching directories: " + @output_dir.inspect)
    
    FSSM.monitor do
      @output_dir.each do |dir|
        path(dir) do
          glob ["**/*.js", "**/package.yml", "**/package.json"]
          update &method(:watch_callback) # {|base, relative| yield(base, relative) }
          delete &method(:watch_callback) # {|base, relative| yield(base, relative) }
          create &method(:watch_callback) # {|base, relative| yield(base, relative) }
        end
      end
    end

  rescue LoadError => e
    Jsus.logger.error "You need to install fssm gem for --watch option."
    Jsus.logger.error "You may also want to install rb-fsevent for OS X"
    raise e
  end
  
  def watch_callback(base, match)
      full_path = File.join(base, match)
      unless full_path.include?(@output_dir)
        Jsus.logger.info "#{match} has changed, relaunching jsus..."
        begin
          @on_change.call
          Jsus.logger.info "... done"
        rescue Exception => e
          Jsus.logger.error "Exception happened: #{e}, #{e.inspect}"
          Jsus.logger.error "\t#{e.backtrace.join("\n\t")}" if Jsus.verbose?
          Jsus.logger.error "Compilation FAILED."
        end
      end
    end
  end
end