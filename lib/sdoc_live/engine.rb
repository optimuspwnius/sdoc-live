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
        ActionDispatch::Static,
        doc_root,
        headers: { "cache-control" => "public, max-age=3600" },
        index: "index.html",
        urls: [mount_path]
      )
    end

  end

end
