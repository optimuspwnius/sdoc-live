require_relative "sdoc_live/version"

module SdocLive

  class << self

    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

  end

  class Configuration

    attr_accessor :output_dir, :title, :main_file, :source_dirs, :watch_dirs,
                  :watch_file_type_regex, :rdoc_options, :mount_path

    def initialize
      @source_dirs = ["app", "lib"]
      @watch_file_type_regex = /\.rb$/
      @title = "Documentation"
      @main_file = "README.md"
      @mount_path = "/doc"
    end

  end

end

require_relative "sdoc_live/generator"
require_relative "sdoc_live/engine" if defined?(Rails)
