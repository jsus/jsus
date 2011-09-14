require 'spec_helper'
require 'fileutils'

# Until I figure out how to test this stuff better, here is what is going on:
#    * main thread is set as a timeout thread. it launches some child threads
#      and goes to sleep until woken up or timed out
#
#    * FSSM thread watches for filesystem updates
#      Note: there is a 1 second delay after FSSM launch, it can be slow even
#            on fast enough systems
#
describe Jsus::Util::Watcher do
  let(:directory) { File.expand_path("spec/tmp/watcher") }

  before(:each) do
    FileUtils.rm_rf(directory)
    FileUtils.mkdir_p(directory)
  end

  after(:each) do
    FileUtils.rm_rf(directory)
  end

  describe ".watch" do
    let(:watched_file) { "#{directory}/hello.js" }
    def watch(directory, callback_countdown = 1, &block)
      @main_thread = Thread.current
      @watcher_thread = Thread.new do
        described_class.watch(directory) do |*args|
          yield(*args)
          callback_countdown -= 1
          @main_thread.wakeup if callback_countdown <= 0
        end
      end
      @watcher_thread.abort_on_exception = true
      sleep(1) # give it some time to init
    end # watch

    def stop_watching(timeout = 5)
      sleep(timeout) if timeout && timeout > 0
      @watcher_thread.kill
    end # stop_watching

    it "should trigger the callback on file creation" do
      watch(directory) do
        @callback_called = true
      end
      File.open(watched_file, "w+") {|f| f << "var Hello = 1;"}
      stop_watching
      @callback_called.should be_true
    end

    it "should trigger the callback on file update" do
      File.open(watched_file, "w+") {|f| f << "var Hello = 1;"}
      watch(directory) do
        @callback_called = true
      end
      @callback_called.should be_false
      File.open(watched_file, "a+") {|f| f << "var World = 2;"}
      stop_watching
      @callback_called.should be_true
    end

    it "should trigger the callback on file removal" do
      File.open(watched_file, "w+") {|f| f << "var Hello = 1;"}
      watch(directory) do
        @callback_called = true
      end
      @callback_called.should be_false
      FileUtils.rm_f(watched_file)
      stop_watching
      @callback_called.should be_true
    end

    it "should pass a filename to the callback" do
      watch(directory) do |filename|
        @filename = filename
      end
      File.open(watched_file, "w+") {|f| f << "var Hello = 1;"}
      stop_watching
      @filename.should == watched_file
    end

    it "should ignore events happening between callback calls" do
      @callback_called_times = 0
      watch(directory, 2) do
        @callback_called_times += 1
        other_file = "#{directory}/output.js"
        Thread.new { File.open(other_file, "w+") {|f| f.puts "// Hello, world 2" } }
        sleep(3)
      end
      File.open(watched_file, "w+") {|f| f.puts "// Hello, world" }
      stop_watching
      @callback_called_times.should == 1
    end

    it "should accept multiple input directories and ignore events happening at two dirs at once" do
      inner_directory = "#{directory}/inner"
      FileUtils.mkdir_p(inner_directory)
      watched_file = "#{inner_directory}/hello.js"
      @callback_called_times = 0
      watch([inner_directory, directory], 2) do
        @callback_called_times += 1
        sleep(1) # Simulate some work
      end
      File.open(watched_file, "w+") {|f| f.puts "var Hello = 1;"}
      stop_watching
      @callback_called_times.should == 1
    end

    it "should catch exceptions in callbacks" do
      watch(directory) do |filename|
        @callback_called = true
        Jsus.logger = Jsus::Util::Logger.new("/dev/null")
        raise "Terrible, terrible error"
      end
      File.open(watched_file, "w+") {|f| f << "var Hello = 1;"}
      stop_watching
      @callback_called.should == true
    end
  end
end
