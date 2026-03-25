module SdocLive

  class Engine < ::Rails::Engine

    rake_tasks do
      load File.expand_path("../tasks/sdoc_live.rake", __dir__)
    end

    initializer "sdoc_live.static" do |app|
      doc_root = (SdocLive.configuration.output_dir || app.root.join("tmp", "doc")).to_s

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

    initializer "sdoc_live.trailing_slash", after: :add_routing_paths do |app|
      mount_path = nil

      app.routes.routes.each do |route|
        if route.app.respond_to?(:app) && route.app.app == SdocLive::Engine
          mount_path = route.path.spec.to_s.gsub("(.:format)", "").chomp("/")
          break
        end
      end

      if mount_path && !mount_path.empty?
        app.middleware.use(Class.new do
          define_method(:initialize) { |a| @app = a }

          define_method(:call) do |env|
            if env["PATH_INFO"] == mount_path && !env["PATH_INFO"].end_with?("/")
              query = env["QUERY_STRING"].to_s.empty? ? "" : "?#{ env['QUERY_STRING'] }"
              [301, { "location" => "#{ mount_path }/#{ query }", "content-type" => "text/html" }, ["Redirecting..."]]
            else
              @app.call(env)
            end
          end
        end)
      end
    end

  end

end
