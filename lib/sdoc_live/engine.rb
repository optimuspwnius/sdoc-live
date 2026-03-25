module SdocLive

  # Rails engine that registers the SdocLive::StaticFiles middleware and
  # loads the +sdoc:build+ rake task. No route mounting is required — the
  # middleware is inserted automatically before +Rails::Rack::Logger+ so
  # documentation requests don't appear in application logs.
  class Engine < ::Rails::Engine

    rake_tasks do
      load File.expand_path("../tasks/sdoc_live.rake", __dir__)
    end

    # Inserts the StaticFiles middleware using the current SdocLive configuration.
    initializer "sdoc_live.static" do
      config = SdocLive.configuration
      doc_root = (config.output_dir || Rails.root.join("tmp", "doc")).to_s
      mount_path = config.mount_path
      cache_control = config.cache_control

      Rails.application.middleware.insert_before(
        Rails::Rack::Logger,
        SdocLive::StaticFiles,
        doc_root,
        mount_path,
        cache_control
      )
    end

  end

  # Rack middleware that serves generated SDoc files from +doc_root+ at the
  # configured +mount_path+. Uses +ActionDispatch::FileHandler+ for efficient
  # file serving with configurable +Cache-Control+ headers.
  #
  # == Behavior
  #
  # - +GET /doc+ → 301 redirect to +/doc/+
  # - +GET /doc/...+ → serves matching file from +doc_root+, or falls through
  #   to the Rails app if no file matches
  class StaticFiles

    # Initializes the middleware.
    #
    # [app]           The next Rack app in the middleware stack.
    # [doc_root]      Absolute path to the directory containing generated docs.
    # [mount_path]    URL prefix where docs are served (e.g. +"/doc"+).
    # [cache_control] Value for the +Cache-Control+ response header.
    #                 Default: +"no-cache"+.
    def initialize(app, doc_root, mount_path, cache_control = "no-cache")
      @app = app
      @mount_path = mount_path.chomp("/")
      @file_handler = ActionDispatch::FileHandler.new(
        doc_root,
        headers: { "cache-control" => cache_control }
      )
    end

    # Handles an incoming Rack request. Redirects bare mount path to trailing
    # slash, attempts to serve a file for paths under the mount path, and
    # falls through to the next middleware otherwise.
    def call(env)
      path_info = env["PATH_INFO"]

      if path_info == @mount_path
        query = env["QUERY_STRING"].to_s.empty? ? "" : "?#{env['QUERY_STRING']}"
        return [301, { "location" => "#{@mount_path}/#{query}" }, []]
      end

      if path_info.start_with?("#{@mount_path}/")
        env["PATH_INFO"] = path_info.delete_prefix(@mount_path)
        response = @file_handler.attempt(env)
        env["PATH_INFO"] = path_info
        return response if response
      end

      @app.call(env)
    end

  end

end
