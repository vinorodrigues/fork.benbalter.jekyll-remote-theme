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
    autoload :FileIncluder,  "jekyll-remote-theme/file_includer"
    autoload :DataLoader,    "jekyll-remote-theme/data_loader"
    autoload :VERSION,       "jekyll-remote-theme/version"

    CONFIG_KEY           = "remote_theme"
    LOCAL_THEME_KEY      = "local_theme"
    INCLUDE_FILES_KEY    = "include"  # Shares setting from https://jekyllrb.com/docs/configuration/options/
    LOG_KEY              = "Remote Theme:"
    TEMP_PREFIX          = "jekyll-remote-theme-"

    def self.init(site)
      Munger.new(site).munge!
    end

    def self.include_theme_files(site)
      if site.theme.is_a?(Jekyll::RemoteTheme::Theme) || site.theme.is_a?(Jekyll::RemoteTheme::LocalTheme)
        FileIncluder.new(site).include_theme_files
      end
    end

    def self.load_theme_data(site)
      if site.theme.is_a?(Jekyll::RemoteTheme::Theme) || site.theme.is_a?(Jekyll::RemoteTheme::LocalTheme)
        DataLoader.new(site).load_theme_data
      end
    end
  end
end

# Initialise the plugin just after the site resets during regeneration
Jekyll::Hooks.register :site, :after_reset do |site|
  # Start 'er up
  Jekyll::RemoteTheme.init(site)
  # Include specified files from the theme if they are missing locally
  Jekyll::RemoteTheme.include_theme_files(site)
end

# Load theme data after the site's data is read
Jekyll::Hooks.register :site, :post_read do |site|
  Jekyll::RemoteTheme.load_theme_data(site)
end
