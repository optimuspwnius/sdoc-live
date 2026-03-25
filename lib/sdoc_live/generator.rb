require "fileutils"

module SdocLive

  # Generates SDoc documentation from Ruby source files. Wraps +RDoc::RDoc+
  # with SDoc formatting and supports both one-shot builds and continuous
  # watch-mode regeneration.
  class Generator

    # Creates a new generator.
    #
    # [root] Project root directory. Defaults to +Rails.root+ when available,
    #        otherwise +Dir.pwd+. All configured paths are resolved relative
    #        to this root.
    def initialize(root: nil)
      @root = root || defined?(Rails) && Rails.root || Pathname.new(Dir.pwd)
      @root = Pathname.new(@root) unless @root.is_a?(Pathname)

      config = SdocLive.configuration

      @output_dir = config.output_dir || @root.join("tmp", "doc")
      @title      = config.title
      @main_file  = config.main_file

      @source_dirs = (config.source_dirs || ["app", "lib"]).map { @root.join(it).to_s }

      @watch_dirs = (config.watch_dirs || config.source_dirs || ["app", "lib"]).map do
        path = @root.join(it)
        path.exist? ? path : nil
      end.compact

      @watch_file_type_regex = config.watch_file_type_regex
      @rdoc_options          = config.rdoc_options
    end

    # Runs a full SDoc generation pass into the configured output directory.
    # Uses <tt>--force-output</tt> to overwrite any existing docs. Prints
    # elapsed time on completion.
    def build
      start_time = Time.now

      require "sdoc"
      require "rdoc/rdoc"

      main_file = @root.join(@main_file)

      args = [
        "--format", "sdoc",
        "--output", @output_dir.to_s,
        "--title", @title,
        "--force-output",
        "--quiet"
      ]

      args.push("--main", main_file.to_s) if main_file.exist?

      if @rdoc_options
        args.concat(@rdoc_options)
      end

      args.push(main_file.to_s) if main_file.exist?
      args.concat(@source_dirs.select { File.directory?(it) })

      rdoc = RDoc::RDoc.new
      rdoc.document(args)

      elapsed = Time.now - start_time
      puts "[SdocLive] Generated in #{ format('%.2f', elapsed) }s → #{ @output_dir }"
    end

    # Builds documentation once, then watches +watch_dirs+ for file changes
    # matching +watch_file_type_regex+ and rebuilds on each change. Blocks
    # the current thread until interrupted.
    #
    # This is the method called by the Puma plugin in a forked child process.
    def build_watch
      require "listen"

      build

      puts "[SdocLive] Starting watch mode..."

      listener = Listen.to(*@watch_dirs, only: @watch_file_type_regex) do | modified, added, _removed |
        next if (modified + added).empty?

        puts "[SdocLive] Detected changes, regenerating..."
        build
      end

      listener.start

      loop { sleep 1 }
    rescue Interrupt
      puts "[SdocLive] Watch stopped"
      listener&.stop
    end

  end

end
