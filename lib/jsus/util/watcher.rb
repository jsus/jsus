class Jsus::Util::Watcher
  class << self
    # Watches input directories and their subdirectories for changes in
    # js source files and package metadata files. Main thread goes to sleep
    # afterwards.
    # @param [String, Array] input_dirs directory or directories to watch
    # @param [String, Array] ignored_dirs directory or directories to ignore
    # @yield [filename] Callback to trigger on creation / update / removal of
    #        any file in given directories
    # @yieldparam [String] filename Updated filename full path
    # @return [Listen::Listener] listener monitor instance
    # @api public
    def watch(input_dirs, ignored_dirs = [], &callback)
      new(input_dirs, ignored_dirs, &callback)
      sleep
    end
  end

  # Instantiates a Listener monitor and starts watching.
  # Consider using class method Jsus::Util::Watcher.watch instead.
  # @see .watch
  # @api semipublic
  def initialize(input_dirs, ignored_dirs = [], &callback)
    require 'listen'
    @callback = callback
    @input_dirs = Array(input_dirs).compact
    @semaphore = Mutex.new
    @ignored_dirs = Array(ignored_dirs).map {|dir| File.expand_path(dir) }
    @listeners = []
    @listener_threads = []
    @input_dirs.each do |dir|
      listener = Listen.to(dir).
                        filter(/(\.js|package\.yml|package\.json)$/).
                        ignore(*@ignored_dirs).
                        latency(0.1).
                        change {|*paths| watch_callback(dir, *paths) }
      @listeners << listener
      listener_thread = Thread.new { listener.start }
      listener_thread.abort_on_exception = true
      @listener_threads << listener_thread
    end
    @main_thread = Thread.current
  rescue LoadError => e
    Jsus.logger.error "You need to install 'listen' gem for --watch option. `gem install listen -v '~> 0.3.1'"
    Jsus.logger.error "You may also want to install rb-fsevent for OS X" if RUBY_PLATFORM =~ /darwin/
    raise e
  end

  # Default callback for watcher.
  # @param [String] base_path base directory path
  # @param [Array[String]] modified modified files
  # @param [Array[String]] added added files
  # @param [Array[String]] removed removed files
  # @api semipublic
  def watch_callback(base_path, modified, added, removed)
    changed_file = (modified + added + removed).first # we pick one at random
    full_path = File.join(base_path, changed_file)
    run { @callback.call(full_path) }
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

  # @api semipublic
  def threads
    @listener_threads ||= []
  end # threads

  # @api semipublic
  def listeners
    @listeners ||= []
  end # listeners
end
