# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.1.11] - 2026-03-25

### Fixed

- Middleware inserted before `Rails::Rack::Logger` to suppress doc request log spam

## [0.1.10] - 2026-03-25

### Fixed

- Fixed `undefined method 'middleware'` error by using `Rails.application.middleware` instead of `app.middleware`

## [0.1.9] - 2026-03-25

### Changed

- Replaced engine mount + route introspection with `SdocLive::StaticFiles` Rack middleware
- Configurable `mount_path` option (default: `"/doc"`) — no engine mount in routes needed

### Removed

- Removed need for `mount SdocLive::Engine, at: "/doc"` in routes

## [0.1.8] - 2026-03-25

### Fixed

- Attempted fix for trailing slash redirect using app-level Rack middleware

## [0.1.7] - 2026-03-25

### Fixed

- Fixed test for default output directory (`public/doc` → `tmp/doc`)

## [0.1.6] - 2026-03-25

### Added

- Mountable engine — `mount SdocLive::Engine, at: "/doc"` in routes
- Engine serves documentation using `Rack::Static` with `index.html` support
- Trailing slash redirect — `/doc` automatically redirects to `/doc/`

### Changed

- Default output directory changed from `public/doc` to `tmp/doc` to avoid conflicts with Rails static file serving

## [0.1.5] - 2026-03-25

### Fixed

- Replaced deprecated `on_booted`/`on_stopped` Puma event hooks with `after_booted`/`after_stopped`

## [0.1.4] - 2026-03-25

### Fixed

- Removed `class SdocLive` stub from Puma plugin that clashed with the `module SdocLive` definition

## [0.1.3] - 2026-03-25

### Changed

- Renamed Puma plugin from `:sdoc` to `:sdoc_live`

## [0.1.2] - 2026-03-25

### Changed

- Updated README configuration example to guard with `if defined?(SdocLive)`

## [0.1.1] - 2026-03-25

### Added

- Note in README about needing the sdoc fork for Ruby 4.0+ ([rails/sdoc#379](https://github.com/rails/sdoc/pull/379))

## [0.1.0] - 2026-03-25

### Added

- Initial release
- `SdocLive::Generator` that wraps SDoc/RDoc for documentation generation
- Configurable source dirs, output dir, title, main file, and watch regex
- Puma plugin for development watch mode (auto-rebuild on `.rb` file changes)
- Rake task `sdoc:build` for manual/deploy builds
- Rails engine for auto-loading the rake task
- Bidirectional process monitoring between Puma and the SDoc watcher
