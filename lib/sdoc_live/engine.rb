module SdocLive

  class Engine < ::Rails::Engine

    rake_tasks do
      load File.expand_path("../tasks/sdoc_live.rake", __dir__)
    end

    initializer "sdoc_live.static" do
      doc_root = (SdocLive.configuration.output_dir || Rails.root.join("tmp", "doc")).to_s

      config.middleware.use(SdocLive::StaticFiles, doc_root)
    end

  end

  class StaticFiles

    def initialize(app, doc_root)
      @app = app
      @doc_root = doc_root
    end

    def call(env)
      mount_path = find_mount_path(env)
      return @app.call(env) unless mount_path

      path_info = env["PATH_INFO"]

      if path_info == mount_path
        query = env["QUERY_STRING"].to_s.empty? ? "" : "?#{ env['QUERY_STRING'] }"
        return [301, { "location" => "#{ mount_path }/#{ query }" }, []]
      end

      return @app.call(env) unless path_info.start_with?("#{ mount_path }/")

      relative_path = path_info.delete_prefix(mount_path)
      relative_path = "/index.html" if relative_path == "/"

      file_path = File.join(@doc_root, relative_path)
      file_path = File.join(file_path, "index.html") if File.directory?(file_path)

      if File.file?(file_path)
        serve_file(file_path)
      else
        @app.call(env)
      end
    end

    private

    def find_mount_path(env)
      @mount_path ||= begin
        routes = Rails.application.routes.routes
        route = routes.detect { |r| r.app.respond_to?(:app) && r.app.app == SdocLive::Engine }
        route&.path&.spec&.to_s&.gsub("(.:format)", "")&.chomp("/")
      end
    end

    def serve_file(path)
      content_type = Rack::Mime.mime_type(File.extname(path), "application/octet-stream")
      body = File.read(path, mode: "rb")
      [200, { "content-type" => content_type, "content-length" => body.bytesize.to_s }, [body]]
    end

  end

end
