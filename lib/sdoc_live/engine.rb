module SdocLive

  class Engine < ::Rails::Engine

    rake_tasks do
      load File.expand_path("../tasks/sdoc_live.rake", __dir__)
    end

    initializer "sdoc_live.static" do
      config = SdocLive.configuration
      doc_root = (config.output_dir || Rails.root.join("tmp", "doc")).to_s
      mount_path = config.mount_path

      Rails.application.middleware.insert_before(
        Rails::Rack::Logger,
        SdocLive::StaticFiles,
        doc_root,
        mount_path
      )
    end

  end

  class StaticFiles

    def initialize(app, doc_root, mount_path)
      @app = app
      @mount_path = mount_path.chomp("/")
      @file_handler = ActionDispatch::FileHandler.new(
        doc_root,
        headers: { "cache-control" => "public, max-age=3600" }
      )
    end

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