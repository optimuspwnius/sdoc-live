module SdocLive

  class Engine < ::Rails::Engine

    rake_tasks do
      load File.expand_path("../tasks/sdoc_live.rake", __dir__)
    end

  end

end
