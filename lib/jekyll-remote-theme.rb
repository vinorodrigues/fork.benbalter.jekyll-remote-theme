# frozen_string_literal: true

require "jekyll"
require "fileutils"
require "tempfile"
require "addressable"
require "net/http"
require "zip"

$LOAD_PATH.unshift(File.dirname(__FILE__))

module Jekyll
  module RemoteTheme
    class DownloadError < StandardError; end

    autoload :Downloader,    "jekyll-remote-theme/downloader"
    autoload :MockGemspec,   "jekyll-remote-theme/mock_gemspec"
    autoload :Munger,        "jekyll-remote-theme/munger"
    autoload :Theme,         "jekyll-remote-theme/theme"
    autoload :LocalTheme,    "jekyll-remote-theme/local_theme"
    autoload :VERSION,       "jekyll-remote-theme/version"
    autoload :DataLoader,    "jekyll-remote-theme/data_loader"
    autoload :FileIncluder,  "jekyll-remote-theme/file_includer"

    CONFIG_KEY           = "remote_theme"
    LOCAL_THEME_KEY      = "local_theme"
    INCLUDE_FILES_KEY    = "remote_theme_include"
    LOG_KEY              = "Remote Theme:"
    TEMP_PREFIX          = "jekyll-remote-theme-"

    def self.init(site)
      Munger.new(site).munge!
    end

    def self.load_theme_data(site)
      if site.theme.is_a?(Jekyll::RemoteTheme::Theme) || site.theme.is_a?(Jekyll::RemoteTheme::LocalTheme)
        DataLoader.new(site).load_theme_data
      end
    end

    def self.include_theme_files(site)
      if site.theme.is_a?(Jekyll::RemoteTheme::Theme) || site.theme.is_a?(Jekyll::RemoteTheme::LocalTheme)
        FileIncluder.new(site).include_theme_files
      end
    end

    def self.cleanup_theme_files(site)
      if site.theme.is_a?(Jekyll::RemoteTheme::Theme) || site.theme.is_a?(Jekyll::RemoteTheme::LocalTheme)
        FileIncluder.new(site).cleanup_copied_files
      end
    end
  end
end

Jekyll::Hooks.register :site, :after_reset do |site|
  Jekyll::RemoteTheme.init(site)
end

# Load theme data before the site's data is read
Jekyll::Hooks.register :site, :pre_read do |site|
  Jekyll::RemoteTheme.load_theme_data(site)
end

# Include specified files from the theme if they are missing locally
Jekyll::Hooks.register :site, :post_read do |site|
  Jekyll::RemoteTheme.include_theme_files(site)
end

# Clean up any remotely added files after build
Jekyll::Hooks.register :site, :post_write do |site|
  Jekyll::RemoteTheme.cleanup_theme_files(site)
end
