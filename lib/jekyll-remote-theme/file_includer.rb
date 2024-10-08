# frozen_string_literal: true

module Jekyll
  module RemoteTheme
    class FileIncluder
      attr_reader :site

      def initialize(site)
        @site = site
        @copied_files = site.instance_variable_get(:@remote_theme_copied_files) || []
        site.instance_variable_set(:@remote_theme_copied_files, @copied_files)
      end

      def include_theme_files
        include_files = site.config[INCLUDE_FILES_KEY] || []
        return if include_files.empty?

        include_files.each do |file_path|
          local_file = File.join(site.source, file_path)
          next if File.exist?(local_file)

          theme_file = File.join(site.theme.root, file_path)
          if File.exist?(theme_file)
            Jekyll.logger.debug LOG_KEY, "Including #{file_path} from theme"
            copy_file(theme_file, local_file)
            add_to_static_files(local_file)
          else
            Jekyll.logger.warn LOG_KEY, "File #{file_path} not found in theme"
          end
        end
      end

      def cleanup_copied_files
        @copied_files.each do |file|
          if File.exist?(file)
            Jekyll.logger.debug LOG_KEY, "Cleaning up copied file #{file}"
            FileUtils.rm_f(file)
            # Remove empty directories if possible
            remove_empty_directories(File.dirname(file))
          end
        end
        @copied_files.clear
      end

      private

      def copy_file(source, destination)
        FileUtils.mkdir_p(File.dirname(destination))
        FileUtils.cp(source, destination)
        @copied_files << destination
      end

      def add_to_static_files(file)
        relative_path = Jekyll.sanitized_path(site.source, file).sub(site.source, "")
        relative_path = relative_path.sub(%r!^/!, "")
        static_file = Jekyll::StaticFile.new(site, site.source, File.dirname(relative_path), File.basename(relative_path))
        site.static_files << static_file
      end

      def remove_empty_directories(dir)
        return if dir == site.source || dir.length < site.source.length

        if Dir.empty?(dir)
          FileUtils.rmdir(dir)
          remove_empty_directories(File.dirname(dir))
        end
      end
    end
  end
end
