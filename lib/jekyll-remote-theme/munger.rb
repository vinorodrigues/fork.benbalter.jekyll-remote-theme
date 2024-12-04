# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    class Munger
      extend Forwardable
      def_delegator :site, :config
      attr_reader :site

      def initialize(site)
        @site = site
      end

      def munge!
        return unless raw_theme

        unless theme.valid?
          Jekyll.logger.error LOG_KEY, "#{raw_theme.inspect} is not a valid theme"
          return
        end

        Jekyll.logger.info LOG_KEY, "Using theme #{theme.name_with_owner || theme.name}"
        unless munged?
          downloader.run if downloader
          configure_theme
        end
        enqueue_theme_cleanup if theme.is_a?(Jekyll::RemoteTheme::Theme)

        theme
      end

      private

      def munged?
        site.theme&.is_a?(Jekyll::RemoteTheme::Theme) || site.theme&.is_a?(Jekyll::RemoteTheme::LocalTheme)
      end

      def theme
        @theme ||= if config[CONFIG_KEY]
                     Theme.new(raw_theme)
                   elsif config[LOCAL_THEME_KEY]
                     LocalTheme.new(raw_theme, site)
                   end
      end

      def raw_theme
        @raw_theme ||= if config[CONFIG_KEY]
                         config[CONFIG_KEY]
                       elsif config[LOCAL_THEME_KEY]
                         config[LOCAL_THEME_KEY]
                       end
      end

      def downloader
        return unless theme.is_a?(Jekyll::RemoteTheme::Theme)
        @downloader ||= Downloader.new(theme, site.config)
      end

      def configure_theme
        return unless theme

        site.config["theme"] = theme.name
        site.theme = theme
        site.theme.configure_sass if site.theme.respond_to?(:configure_sass)
        site.send(:configure_include_paths)
        site.plugin_manager.require_theme_deps
      end

      def enqueue_theme_cleanup
        at_exit do
          Jekyll.logger.debug LOG_KEY, "Cleaning up #{theme.root}"
          FileUtils.rm_rf theme.root
        end
      end
    end
  end
end
