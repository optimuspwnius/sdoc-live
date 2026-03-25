module SdocLive

  class Engine < ::Rails::Engine

    rake_tasks do
      load File.expand_path("../tasks/sdoc_live.rake", __dir__)
    end

    initializer "sdoc_live.static" do |app|
      doc_root = (SdocLive.configuration.output_dir || app.root.join("public", "doc")).to_s

      SdocLive::Engine.routes.draw do
        doc_app = ::Rack::Static.new(
          ->(_) { [404, { "content-type" => "text/plain" }, ["Not Found"]] },
          urls: ["/"],
          root: doc_root,
          index: "index.html"
        )

        mount doc_app, at: "/"
      end
    end

  end

end
