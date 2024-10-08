# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    class LocalTheme < Jekyll::Theme
      attr_reader :site

      def initialize(theme_path, site)
        @site = site
        @root = absolute_theme_path(theme_path)
        unless File.directory?(@root)
          raise ArgumentError, "Local theme directory #{@root} does not exist."
        end
        @name = File.basename(@root)
        Jekyll.logger.debug LOG_KEY, "Initialized LocalTheme with path #{@root}"
        super(@name)
      end

      def root
        @root
      end

      def valid?
        File.directory?(root)
      end

      def name_with_owner
        nil # Not applicable for local themes
      end

      private

      def absolute_theme_path(theme_path)
        if Pathname.new(theme_path).absolute?
          theme_path
        else
          File.expand_path(theme_path, site.source)
        end
      end

      def gemspec
        @gemspec ||= MockGemspec.new(self)
      end
    end
  end
end
