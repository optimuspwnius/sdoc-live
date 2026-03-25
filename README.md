# SDoc Live

Live SDoc generation for Rails — watches your source files and auto-regenerates API documentation on changes. Serves docs via Rack middleware at a configurable path (default: `/doc`).

## Requirements

- Ruby >= 3.2
- Rails >= 7.0
- **SDoc** gem (included as a dependency)

## Installation

Add to your Gemfile:

```ruby
gem "sdoc_live"
```

Then run `bundle install`.

> **Note:** If you're using Ruby 4.0+, you'll need to add the following to your Gemfile until a new version of sdoc is released with the fix ([rails/sdoc#379](https://github.com/rails/sdoc/pull/379)):
>
> ```ruby
> group :development do
>   gem "sdoc", github: "zzak/sdoc", branch: "re-379"
> end
> ```

## Quick Start

1. Add the gem to your Gemfile and run `bundle install`
2. Add the Puma plugin to `config/puma.rb`:

```ruby
if ENV.fetch("RAILS_ENV", "development") == "development"
  plugin :sdoc_live
end
```

3. Start your Rails server and visit `/doc`

That's it — documentation is generated automatically and rebuilds when you change any `.rb` file in `app/` or `lib/`.

## Usage

### Puma Plugin (Development Watch Mode)

The Puma plugin is the primary way to use SDoc Live in development. It forks a child process that generates documentation on boot and watches for file changes.

Add to your `config/puma.rb`:

```ruby
if ENV.fetch("RAILS_ENV", "development") == "development"
  plugin :sdoc_live
end
```

The plugin provides:

- **Automatic generation** on Puma boot
- **File watching** via the `listen` gem — regenerates docs when `.rb` files change
- **Lifecycle management** — the SDoc process stops when Puma stops, and vice versa

### Rake Task (Manual / CI / Deploy)

For one-off generation without file watching:

```bash
rake sdoc:build
```

This is useful for CI pipelines or production deployments where you want to pre-generate documentation.

## Serving Documentation

SDoc Live automatically inserts Rack middleware that serves generated documentation at the configured `mount_path` (default: `/doc`). No route mounting is needed — it works out of the box.

- `GET /doc` redirects to `/doc/`
- `GET /doc/` serves the documentation index
- `GET /doc/...` serves any generated documentation file

The middleware is inserted before `Rails::Rack::Logger`, so documentation requests don't appear in your Rails logs.

## Configuration

Create an initializer at `config/initializers/sdoc_live.rb`:

```ruby
SdocLive.configure do |config|
  # Title for the generated documentation (default: "Documentation")
  config.title = "My App API"

  # Main file displayed on the docs landing page (default: "README.md")
  config.main_file = "README.md"

  # Directories to scan for Ruby source files (default: ["app", "lib"])
  config.source_dirs = ["app", "lib"]

  # Directories to watch for changes in dev mode (defaults to source_dirs)
  # config.watch_dirs = ["app", "lib"]

  # Regex for file types that trigger regeneration (default: /\.rb$/)
  # config.watch_file_type_regex = /\.(rb|md)$/

  # Override the output directory (default: Rails.root.join("tmp", "doc"))
  # config.output_dir = Rails.root.join("tmp", "doc")

  # Additional RDoc options passed to the SDoc generator
  # config.rdoc_options = ["--all", "--hyperlink-all"]

  # URL path where documentation is served (default: "/doc")
  # config.mount_path = "/doc"

  # Cache-Control header for served documentation files (default: "no-cache")
  # Use "no-cache" in development to always get fresh docs.
  # Use "public, max-age=3600" in production for better performance.
  # config.cache_control = "public, max-age=3600"
end if defined?(SdocLive)
```

### Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `title` | `"Documentation"` | HTML title for the generated docs |
| `main_file` | `"README.md"` | File displayed on the docs landing page |
| `source_dirs` | `["app", "lib"]` | Directories scanned by RDoc for source files |
| `watch_dirs` | `nil` (falls back to `source_dirs`) | Directories watched for file changes in dev mode |
| `watch_file_type_regex` | `/\.rb$/` | File pattern that triggers regeneration |
| `output_dir` | `nil` (defaults to `tmp/doc`) | Where generated HTML documentation is written |
| `rdoc_options` | `nil` | Additional CLI options passed to RDoc/SDoc |
| `mount_path` | `"/doc"` | URL path where documentation is served |
| `cache_control` | `"no-cache"` | `Cache-Control` header for served files |

## How It Works

```
Rails app boots
├── Engine initializer inserts StaticFiles middleware
│   └── Serves tmp/doc/ at /doc (before Rails logger)
└── Puma plugin forks child process
    ├── Generator#build runs full SDoc generation → tmp/doc/
    ├── Listen gem watches app/ + lib/ for .rb changes
    └── On change → Generator#build again (full regeneration)
```

1. **Boot**: When Rails starts, the `SdocLive::Engine` initializer inserts `SdocLive::StaticFiles` Rack middleware that serves files from the output directory
2. **Generate**: The Puma plugin forks a child process that runs a full SDoc build
3. **Watch**: The child process uses the `listen` gem to monitor source directories for file changes
4. **Rebuild**: When a matching file changes, the generator runs a complete SDoc rebuild with `--force-output`
5. **Serve**: The middleware serves documentation files using `ActionDispatch::FileHandler`, handling path prefixing and trailing slash redirects
6. **Lifecycle**: Bidirectional process monitoring ensures the SDoc child process and Puma stay in sync — if either dies, the other is stopped

## License

[MIT](LICENSE.txt) — Copyright (c) 2026
