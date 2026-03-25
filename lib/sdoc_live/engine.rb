module SdocLive

  class Engine < ::Rails::Engine

    rake_tasks do
      load File.expand_path("../tasks/sdoc_live.rake", __dir__)
    end

    initializer "sdoc_live.static" do
      config = SdocLive.configuration
      doc_root = (config.output_dir || Rails.root.join("tmp", "doc")).to_s
      mount_path = config.mount_path

      Rails.application.middleware.insert_before(Rails::Rack::Logger, SdocLive::StaticFiles, doc_root, mount_path)
    end

  end

  class StaticFiles

    def initialize(app, doc_root, mount_path)
      @app = app
      @doc_root = doc_root
      @mount_path = mount_path.chomp("/")
    end

    def call(env)
      path_info = env["PATH_INFO"]

      if path_info == @mount_path
        query = env["QUERY_STRING"].to_s.empty? ? "" : "?#{ env['QUERY_STRING'] }"
        return [301, { "location" => "#{ @mount_path }/#{ query }" }, []]
      end

      return @app.call(env) unless path_info.start_with?("#{ @mount_path }/")

      relative_path = path_info.delete_prefix(@mount_path)
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

    def serve_file(path)
      content_type = Rack::Mime.mime_type(File.extname(path), "application/octet-stream")
      body = File.read(path, mode: "rb")
      [200, { "content-type" => content_type, "content-length" => body.bytesize.to_s }, [body]]
    end

  end

end
