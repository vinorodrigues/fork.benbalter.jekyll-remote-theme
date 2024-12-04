# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("lib", __dir__)
require "jekyll-remote-theme2/version"

Gem::Specification.new do |s|
  s.name          = "jekyll-remote-theme2"
  s.version       = Jekyll::RemoteTheme::VERSION
  s.authors       = ["Ben Balter", "Vino Rodrigues"]
  s.email         = ["ben.balter@github.com", "F09F9695+vinorodrigues@users.noreply.github.com"]
  s.homepage      = "https://github.com/vinorodrigues/jekyll-remote-theme2"
  s.summary       = "Jekyll plugin for building Jekyll sites with any GitHub-hosted theme"

  s.files         = `git ls-files app lib`.split("\n")
  s.require_paths = ["lib"]
  s.license       = "MIT"

  s.add_dependency "jekyll", ">= 3.10", "< 5.0"
  s.add_dependency "rubyzip", ">= 1.3.0", "< 3.0"

  s.required_ruby_version = ">= 2.3.0"
end
