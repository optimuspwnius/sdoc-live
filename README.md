# SDoc Live

Live SDoc generation for Rails — watches your source files and auto-regenerates API documentation on changes. Serves docs from `public/doc/` so they're available at `/doc/index.html` in development.

## Requirements

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

## Usage

### 1. Puma Plugin (Development Watch Mode)

Add to your `config/puma.rb`:

```ruby
if ENV.fetch("RAILS_ENV", "development") == "development"
  plugin :sdoc_live
end
```

This watches `app/` and `lib/` for `.rb` file changes and automatically regenerates SDoc documentation.

Docs are served at `/doc/index.html` via Rails' `public/` directory.

### 2. Rake Task (Manual / Deploy)

```bash
rake sdoc:build
```

## Configuration

```ruby
# config/initializers/sdoc_live.rb
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

  # Override the output directory (default: Rails.root.join("public", "doc"))
  # config.output_dir = Rails.root.join("public", "doc")

  # Additional RDoc options passed to the SDoc generator
  # config.rdoc_options = ["--all", "--hyperlink-all"]
end if defined?(SdocLive)
```

## How It Works

1. **Development**: Puma boots → forks a child process that runs `SdocLive::Generator#build_watch`
2. The `listen` gem monitors `app/` and `lib/` for `.rb` file changes
3. On change, SDoc regenerates documentation into `public/doc/`
4. Docs are immediately available at `/doc/index.html`
5. Clean subprocess management with bidirectional lifecycle monitoring (Puma ↔ SDoc)

## License

[MIT](LICENSE.txt) — Copyright (c) 2026
