# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-03-25

### Added

- Initial release
- `SdocLive::Generator` that wraps SDoc/RDoc for documentation generation
- Configurable source dirs, output dir, title, main file, and watch regex
- Puma plugin for development watch mode (auto-rebuild on `.rb` file changes)
- Rake task `sdoc:build` for manual/deploy builds
- Rails engine for auto-loading the rake task
- Bidirectional process monitoring between Puma and the SDoc watcher
