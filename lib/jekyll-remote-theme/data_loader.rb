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
          Jekyll.logger.info LOG_KEY, "No _data directory found in theme"
          return
        end

        Jekyll.logger.info LOG_KEY, "Loading data from theme _data directory"

        theme_data = Jekyll::DataReader.new(site, theme_data_dir).read_data_files

        # Merge theme data into site.data, allowing local data to override
        site.data = Jekyll::Utils.deep_merge_hashes(theme_data, site.data)
      end
    end
  end
end
