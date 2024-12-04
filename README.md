# Jekyll Remote Theme *(redone)*

Jekyll plugin for building Jekyll sites with any public GitHub-hosted theme.

Applies fixes to Jekyll Remote Theme by Ben Balter after the apparent dormancy of the original repo.

**:warning: NB:** This does not replace the GitHub Pages instance of `jekyll-remote-theme` ... unfortunately the you're stuck with the OG if you host on gh-pages.

[![Gem Version](https://badge.fury.io/rb/jekyll-remote-theme.svg)](https://badge.fury.io/rb/jekyll-remote-theme)


## Usage

1. Add the following to your Gemfile

  ```ruby
  gem "jekyll-remote-theme"
  ```

  and run `bundle install` to install the plugin

2. Add the following to your site's `_config.yml` to activate the plugin

  ```yml
  plugins:
    - jekyll-remote-theme
  ```
  Note: If you are using a Jekyll version less than 3.5.0, use the `gems` key instead of `plugins`.

3. Add the following to your site's `_config.yml` to choose your theme

  ```yml
  remote_theme: owner/theme
  ```
or <sup>1</sup>
  ```yml
  remote_theme: http[s]://github.<Enterprise>.com/owner/theme
  ```
or <sup>2</sup>
  ```yml
  local_theme: _themes/my_theme_1
  ```


* <sup>1</sup> The code load subdomain needs to be available on your github enterprise instance for this to work.

* <sup>2</sup> See [Local Themes](#local-themes) below

### Proxy Settings

If you're buildind behind a Proxy you may need to validate with your proxy server.  To do this:

* Configure Proxy Settings in _config.yml

  Add a proxy section to your site's _config.yml file:

  ```yaml
  proxy:
    address: 'proxy.example.com'
    port: 8080
    username: 'your_username' # Optional
    password: 'your_password' # Optional
  ```

* Parameters:
    - `address`: The proxy server address (required for proxy usage).
    - `port`: The proxy server port (optional, default depends on proxy type).
    - `username`: Your proxy username (optional). Please first read  about [Sensitive Information](./docs/KNOWN_SECURITY_CONCERNS.md#sensitive-information)!
    - `password`: Your proxy password (optional).

### Including additional files

You can also specify additional files in `_config.yml`.

1. Add the `include` key to your `_config.yml`:

    ```yml
    remote_theme: owner/theme

    include:
      - 404.html
      - anotherfolder/js/custom.js
    ```

2. Structure of File Paths

  - Paths are relative to the site's source directory.
  - You can include files from subdirectories (e.g., assets/js/custom.js).

3. Build Your Site

  When you build your site with `jekyll build` or `jekyll serve`, the plugin will include the specified files from the remote theme <ins>if</ins> they are not present locally.

### Local Themes

This plugin also supports sourcing themes from a local folder specified via a new `local_theme` configuration key in your `_config.yml`. The `remote_theme` key still takes precedence if both are specified.

1. To configure with a local theme (not residing in the root, since that is the default behaviour of Jekyll).

    In your site's `_config.yml`, specify the `local_theme` key with the relative path to your local theme directory:

    ```yaml
    local_theme: _themes/my_theme_1
    ```

    or, with the absolute path to your theme directory:

    ```yaml
    local_theme: /Users/username/projects/jekyll-site/_themes/my_theme_1
    ```

    If both `remote_theme` and `local_theme` are specified then the plugin will use the `remote_theme` (`owner/theme`) and ignore `local_theme` (`_themes/my_theme_1`).

2. Organize Your Local Theme

    Place your local theme files in the specified directory.

    The directory structure should match a standard Jekyll theme.

    - Include directories like `_layouts`, `_includes`, `_sass`, `assets`, etc.


## Declaring your theme

Remote themes are specified by the `remote_theme` key in the site's config.

For public GitHub, remote themes must be in the form of `OWNER/REPOSITORY`, and must represent a <ins>public</ins> GitHub-hosted Jekyll theme. See [the Jekyll documentation](https://jekyllrb.com/docs/themes/) for more information on authoring a theme. Note that you do not need to upload the gem to RubyGems or include a `.gemspec` file.

You may also optionally specify a branch, tag, or commit to use by appending an `@` and the Git ref (e.g., `benbalter/retlab@v1.0.0` or `benbalter/retlab@develop`). If you don't specify a Git ref, the `HEAD` ref will be used.

For Enterprise GitHub, remote themes must be in the form of `http[s]://GITHUBHOST.com/OWNER/REPOSITORY`, and must represent a public (non-private repository) GitHub-hosted Jekyll theme. Other than requiring the fully qualified domain name of the enterprise GitHub instance, this works exactly the same as the public usage.

## Debugging

Adding `--verbose` to the `build` or `serve` command may provide additional information.
