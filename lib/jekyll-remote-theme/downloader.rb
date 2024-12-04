# frozen_string_literal: true

require 'uri' # Needed to handle proxy URIs

module Jekyll
  module RemoteTheme
    class Downloader
      PROJECT_URL = "https://github.com/vinorodrigues/jekyll-remote-theme"
      USER_AGENT = "Jekyll Remote Theme/#{VERSION} (+#{PROJECT_URL})"
      MAX_FILE_SIZE = 1 * (1024 * 1024 * 1024) # Size in bytes (1 GB)
      NET_HTTP_ERRORS = [
        Timeout::Error, Errno::EINVAL, Errno::ECONNRESET, EOFError, Net::OpenTimeout,
        Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError, Net::ProtocolError,
      ].freeze

      def initialize(theme, site_config = {})
        @theme = theme
        @site_config = site_config # Store site configuration
      end

      def run
        if downloaded?
          Jekyll.logger.debug LOG_KEY, "Using existing #{theme.name_with_owner}"
          return
        end

        download
        unzip
      end

      def downloaded?
        @downloaded ||= theme_dir_exists? && !theme_dir_empty?
      end

      private

      attr_reader :theme, :site_config

      def zip_file
        @zip_file ||= Tempfile.new([TEMP_PREFIX, ".zip"], :binmode => true)
      end

      def download
        Jekyll.logger.debug LOG_KEY, "Downloading #{zip_url} to #{zip_file.path}"

        # Setup proxy if configured
        proxy_uri = proxy_uri()

        Net::HTTP.start(zip_url.host, zip_url.port,
                        proxy_uri.host, proxy_uri.port, proxy_uri.user, proxy_uri.password,
                        :use_ssl => true) do |http|
          http.request(request) do |response|
            raise_unless_success(response)
            enforce_max_file_size(response.content_length)
            response.read_body do |chunk|
              zip_file.write chunk
            end
          end
        end
        @downloaded = true
      rescue *NET_HTTP_ERRORS => e
        raise DownloadError, e.message
      end

      def request
        return @request if defined? @request

        @request = Net::HTTP::Get.new zip_url.request_uri
        @request["User-Agent"] = USER_AGENT
        @request
      end

      def raise_unless_success(response)
        return if response.is_a?(Net::HTTPSuccess)

        raise DownloadError, "#{response.code} - #{response.message} - Loading URL: #{zip_url}"
      end

      def enforce_max_file_size(size)
        return unless size && size > MAX_FILE_SIZE

        raise DownloadError, "Maximum file size of #{MAX_FILE_SIZE} bytes exceeded"
      end

      # Codeload generated zip files contain a top level folder in the form of
      # THEME_NAME-GIT_REF/. While requests for Git repos are case insensitive,
      # the zip subfolder will respect the case in the repository's name, thus
      # making it impossible to predict the true path to the theme. In case we're
      # on a case-sensitive file system, strip the parent folder from all paths.

      def unzip
        Jekyll.logger.debug LOG_KEY, "Unzipping #{zip_file.path} to #{theme.root}"

        zip_file.rewind

        # Extract all entries to a temporary directory first
        Dir.mktmpdir(TEMP_PREFIX) do |tmp_dir|
          Zip::File.open(zip_file) do |archive|
            archive.each do |entry|
              # Construct the full path where the entry will be extracted
              entry_path = File.join(tmp_dir, entry.name)
              # Ensure the directory exists
              FileUtils.mkdir_p(File.dirname(entry_path))
              # Extract the entry
              entry.extract(entry_path) { true }
            end
          end

          # Analyze the top-level structure
          top_level_entries = Dir.entries(tmp_dir) - %w[. ..]

          # Determine if we should remove the top-level directory
          if top_level_entries.size == 1 && File.directory?(File.join(tmp_dir, top_level_entries.first))
            # Only one top-level directory exists, remove it
            source_dir = File.join(tmp_dir, top_level_entries.first)
            Jekyll.logger.debug LOG_KEY, "Removing top-level directory #{top_level_entries.first}"
          else
            # Multiple top-level entries exist, keep them as is
            source_dir = tmp_dir
          end

          # Copy the extracted files to theme.root
          FileUtils.mkdir_p(theme.root)
          FileUtils.cp_r(Dir.glob("#{source_dir}/*"), theme.root)
        end
      ensure
        zip_file.close
        zip_file.unlink
      end

      # Full URL to codeload zip download endpoint for the given theme
      def zip_url
        @zip_url ||= Addressable::URI.new(
          :scheme => theme.scheme,
          :host   => "codeload.#{theme.host}",
          :path   => [theme.owner, theme.name, "zip", theme.git_ref].join("/")
        ).normalize
      end

      def theme_dir_exists?
        theme.root && Dir.exist?(theme.root)
      end

      def theme_dir_empty?
        Dir["#{theme.root}/*"].empty?
      end

      def proxy_uri
        proxy_config = site_config['proxy'] || {}
        proxy_address = proxy_config['address']
        proxy_port = proxy_config['port']
        proxy_user = proxy_config['username']
        proxy_pass = proxy_config['password']

        if proxy_address
          URI::HTTP.build(
            host: proxy_address,
            port: proxy_port,
            userinfo: [proxy_user, proxy_pass].compact.join(':')
          )
        else
          # Returns a URI with host: nil, indicating no proxy.
          URI::HTTP.build(host: nil)
        end
      end

    end
  end
end
