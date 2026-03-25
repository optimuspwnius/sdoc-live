require_relative "sdoc_live/version"

# Live SDoc generation for Rails. Watches source files and auto-regenerates
# API documentation on changes, serving it via Rack middleware.
#
# == Quick Start
#
#   # config/initializers/sdoc_live.rb
#   SdocLive.configure do |config|
#     config.title = "My App API"
#   end if defined?(SdocLive)
#
# See Configuration for all available options.
module SdocLive

  class << self

    attr_writer :configuration

    # Returns the current configuration, initializing with defaults if needed.
    def configuration
      @configuration ||= Configuration.new
    end

    # Yields the current Configuration for modification.
    #
    #   SdocLive.configure do |config|
    #     config.title = "My Docs"
    #     config.source_dirs = ["app", "lib", "engines"]
    #   end
    def configure
      yield(configuration)
    end

  end

  # Holds all configuration options for SDoc Live.
  #
  # == Attributes
  #
  # [output_dir]             Where generated HTML is written. Default: +Rails.root.join("tmp", "doc")+.
  # [title]                  HTML title for generated docs. Default: +"Documentation"+.
  # [main_file]              Landing page source file. Default: +"README.md"+.
  # [source_dirs]            Directories scanned by RDoc. Default: <tt>["app", "lib"]</tt>.
  # [watch_dirs]             Directories watched for changes (falls back to +source_dirs+). Default: +nil+.
  # [watch_file_type_regex]  File pattern that triggers regeneration. Default: +/\.rb$/+.
  # [rdoc_options]           Additional CLI options passed to RDoc/SDoc. Default: +nil+.
  # [mount_path]             URL path where docs are served. Default: +"/doc"+.
  # [cache_control]          Cache-Control header value for served files. Default: +"no-cache"+.
  class Configuration

    attr_accessor :output_dir, :title, :main_file, :source_dirs, :watch_dirs,
                  :watch_file_type_regex, :rdoc_options, :mount_path, :cache_control

    def initialize
      @source_dirs = ["app", "lib"]
      @watch_file_type_regex = /\.rb$/
      @title = "Documentation"
      @main_file = "README.md"
      @mount_path = "/doc"
      @cache_control = "no-cache"
    end

  end

end

require_relative "sdoc_live/generator"
require_relative "sdoc_live/engine" if defined?(Rails)
