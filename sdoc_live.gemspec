require_relative "lib/sdoc_live/version"

Gem::Specification.new do | spec |
  spec.name          = "sdoc_live"
  spec.version       = SdocLive::VERSION
  spec.authors       = ["16554289+optimuspwnius@users.noreply.github.com"]
  spec.email         = ["16554289+optimuspwnius@users.noreply.github.com"]

  spec.summary       = "Live SDoc generation for Rails — auto-regenerates API documentation on file changes."
  spec.description   = "Watches your app and lib directories for Ruby file changes and automatically regenerates " \
                        "SDoc documentation. Includes a Puma plugin for development watch mode and a rake task " \
                        "for manual/deploy builds."
  spec.homepage      = "https://github.com/optimuspwnius/sdoc-live"
  spec.license       = "MIT"
  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = spec.homepage
  spec.metadata["changelog_uri"]     = "#{ spec.homepage }/blob/main/CHANGELOG.md"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.required_ruby_version = ">= 3.2"

  spec.files = Dir[
    "lib/**/*",
    "LICENSE.txt",
    "README.md"
  ]

  spec.require_paths = ["lib"]

  spec.add_dependency "railties", ">= 7.0"
  spec.add_dependency "rdoc", ">= 6.0"
  spec.add_dependency "sdoc", ">= 2.0"
  spec.add_dependency "listen", ">= 3.0"

  spec.add_development_dependency "puma", ">= 5.0"
end
