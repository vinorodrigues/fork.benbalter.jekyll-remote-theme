# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    class DataLoader
      attr_reader :site

      def initialize(site)
        @site = site
      end

      def load_theme_data
        data_dir = site.config["data_dir"] || "_data"
        theme_data_dir = File.join(site.theme.root, data_dir)
        unless Dir.exist?(theme_data_dir)
          Jekyll.logger.debug LOG_KEY, "No _data directory found in theme"
          return
        end

        Jekyll.logger.debug LOG_KEY, "Loading data from theme _data directory"

        data_reader = Jekyll::DataReader.new(site) # support both Jekyll 3.x and 4.x
        theme_data = read_theme_data(data_reader, theme_data_dir)

        # Merge theme data into site.data, merging individual data files
        theme_data.each do |key, theme_value|
          if site.data.key?(key)
            site_value = site.data[key]
            merged_value = deep_merge_data(theme_value, site_value)
            site.data[key] = merged_value
          else
            site.data[key] = theme_value
          end
        end
      end

      private

      def read_theme_data(data_reader, data_dir)
        data = {}
        entries = Dir.chdir(data_dir) { Dir["**/*.*"] }
        entries.each do |entry|
          path = File.join(data_dir, entry)
          next if File.directory?(path)

          ext = File.extname(entry).downcase
          key = entry[0..-ext.length - 1].tr('/', '_').downcase

          Jekyll.logger.debug LOG_KEY, "Reading data file #{path}"
          result = data_reader.read_data_file(path)
          data[key] = result unless result.nil? || result == false
        end
        data
      end

      def deep_merge_data(theme_value, site_value)
        if site_value.nil? || site_value == false
          # Site data is empty or false, use theme data
          theme_value
        elsif theme_value.is_a?(Hash) && site_value.is_a?(Hash)
          Jekyll::Utils.deep_merge_hashes(theme_value, site_value)
        elsif theme_value.is_a?(Array) && site_value.is_a?(Array)
          theme_value + site_value
        else
          # For scalar values or mismatched types, site data takes precedence
          site_value
        end
      end
    end
  end
end
