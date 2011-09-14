require 'yaml'
require 'pathname'
require 'rubygems'
require 'json'
require 'active_support/ordered_hash'
require 'active_support/core_ext/module/delegation'
require 'rgl/adjacency'
require 'rgl/topsort'

require 'fileutils'
require 'pathname'

#
# Jsus -- your better javascript packager.
#
module Jsus
  autoload :SourceFile, 'jsus/source_file'
  autoload :Package,    'jsus/package'
  autoload :Tag,        'jsus/tag'
  autoload :Container,  'jsus/container'
  autoload :Packager,   'jsus/packager'
  autoload :Pool,       'jsus/pool'
  autoload :Util,       'jsus/util'
  autoload :Middleware, 'jsus/middleware'
  autoload :Cli,        'jsus/cli'
  autoload :Compiler,   'jsus/compiler'

  # In verbose mode jsus shows a lot of warnings like missing dependencies.
  # Default: false
  #
  # @return [Boolean] jsus verbosity mode
  # @api public
  def self.verbose?
    !!@verbose
  end

  # @see .verbose?
  # @param [Boolean] verbose verbose verbosity mode
  # @api public
  def self.verbose=(verbose)
    @verbose = verbose
    logger.level = verbose ? Logger::DEBUG : Logger::ERROR
  end

  # @return [String] Jsus version
  # @api public
  def self.version
    @version ||= File.read(File.dirname(__FILE__) + "/../VERSION")
  end


  # Circular dependencies cannot be resolved and lead to "impossible"
  # situations and problems, like missing source files or incorrect ordering.
  #
  # However, checking for cycles is quite computationally expensive, which
  # is why you may want to disable it in production mode.
  #
  # @return [Boolean]
  # @api public
  def self.look_for_cycles?
    @look_for_cycles == nil ? true : @look_for_cycles
  end

  # @see .look_for_cycles?
  # @param [Boolean]
  def self.look_for_cycles=(value)
    @look_for_cycles = value
  end

  # Jsus logger used for all the output. By default uses Logger::ERROR level
  # severity and screen as output device.
  #
  # @return [Jsus::Util::Logger]
  def self.logger
    @@logger ||= Jsus::Util::Logger.new($stdout).tap do |logger|
      logger.level = Logger::ERROR
      logger.formatter = lambda {|severity, time, progname, msg|
        "[#{time.strftime("%Y-%m-%d %H:%M:%S")}] [JSUS:#{severity}] #{msg}\n"
      }
    end
  end # self.logger

  # Reassign jsus logger whenever needed (E.g. use rails logger)
  #
  # @param value Logger responding to #info, #warn, #debug, #error, #fatal,
  #              and #buffer
  # @note In case you use non-jsus logger, you might want to extend it with
  #       Jsus::Util::Logger::Buffering module.
  def self.logger=(value)
    @@logger = value
  end # self.logger=
end
