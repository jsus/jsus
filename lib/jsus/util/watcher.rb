class Jsus::Util::Watcher
  class << self
    # Watches input directories and their subdirectories for changes in
    # js source files and package metadata files.
    # @param [String, Array] input_dirs directory or directories to watch
    # @yield [filename] Callback to trigger on creation / update / removal of
    #        any file in given directories
    # @yieldparam [String] filename Updated filename full path
    # @return [FSSM::Monitor] fssm monitor instance
    # @api public
    def watch(input_dirs, &callback)
      new(input_dirs, &callback)
    end
  end

  # Instantiates a FSSM monitor and starts watching. Consider using class method
  # Jsus::Util::Watcher.watch instead.
  # @see .watch
  # @api semipublic
  def initialize(input_dirs, &callback)
    require 'fssm'
    @callback = callback
    input_dirs = Array(input_dirs).compact
    @semaphore = Mutex.new
    watcher = self
    FSSM.monitor do
      input_dirs.each do |dir|
        dir = File.expand_path(dir)
        path(dir) do
          glob ["**/*.js", "**/package.yml", "**/package.json"]
          create &watcher.method(:watch_callback)
          update &watcher.method(:watch_callback)
          delete &watcher.method(:watch_callback)
        end
      end
    end

  rescue LoadError => e
    Jsus.logger.error "You need to install fssm gem for --watch option."
    Jsus.logger.error "You may also want to install rb-fsevent for OS X" if RUBY_PLATFORM =~ /darwin/
    raise e
  end

  # Default callback for the FSSM watcher.
  # @note Defers the processing to a separate thread and ignores all the incoming
  #       events received during the processing.
  # @param [String] base base part of filename
  # @param [String] match matched part of filename
  # @api semipublic
  def watch_callback(base, match)
    Thread.new do
      run do
        full_path = File.join(base, match)
        @callback.call(full_path)
      end
    end
  end # watch_callback

  # @api semipublic
  def run
    if @semaphore.try_lock
      begin
        yield
      rescue Exception => e
        Jsus.logger.error "Exception happened during watching: #{e}, #{e.inspect}"
        Jsus.logger.error "\t#{e.backtrace.join("\n\t")}" if Jsus.verbose?
        Jsus.logger.error "Compilation FAILED."
      ensure
        @semaphore.unlock
      end
    end
  end # run

  # @return [Boolean]
  # @api public
  def running?
    @semaphore.locked?
  end # running?
end
