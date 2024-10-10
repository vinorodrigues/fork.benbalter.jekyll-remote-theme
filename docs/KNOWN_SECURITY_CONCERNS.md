## Potential Security Vulnerabilities

### 1. Arbitrary Code Execution via Malicious Themes

- **Issue:** The plugin allows users to specify any GitHub repository as a theme. If the repository contains malicious code (e.g., custom Ruby plugins), this code could be executed during the site build process.

- **Explanation:** The `Munger` class replaces the local theme with the remote theme specified in the _config.yml file under the remote_theme key. It then configures the site to use this theme without restricting the code that can be executed.

- **Risk:** An attacker could create a malicious theme that, when used, executes arbitrary code on the system where Jekyll builds the site.

- **Mitigation:** *None. (See [Recommendations for Mitigation](#recommendations-for-mitigation) )*


  *As Jekyll is a one-shot runtime and an assumption is made that the site developer is in control of the build environment.*

### 2. Directory Traversal in Zip Extraction

- **Issue:** The Downloader class unzips the downloaded theme without adequately sanitizing file paths, potentially allowing for directory traversal attacks.

- **Explanation:** In the unzip method, file paths within the zip are processed with path_without_name_and_ref, which removes the top-level directory but may not prevent paths like ../../evil.rb.

- **Risk:** Malicious zip files could overwrite critical files on the host system by exploiting path traversal, leading to system compromise.

- **Mitigation**: Resolved with the `safe_extract` method in `downloader.rb`.

### 3. Lack of Integrity Verification

- Issue: The plugin does not verify the integrity or authenticity of the downloaded theme (e.g., via checksums or digital signatures).

- **Explanation:** The theme is downloaded over HTTPS, but if the GitHub repository is compromised, or if DNS/HTTP spoofing occurs, a malicious theme could be served.

- **Risk:** Users might unknowingly use tampered themes that introduce vulnerabilities or backdoors.

- **Mitigation:** *Won't fix*

  *The solution is to implement checksum verification or use signed commits/tags to ensure the theme's integrity.  This is overly complex for the limited use case of this plugin.*

### 4. No Restriction on Allowed Themes

- **Issue:** There's no whitelist or approval process for themes, allowing any GitHub repository to be used.

- **Explanation:** The valid? method in the Theme class only checks that the host is a valid GitHub domain but doesn't restrict which repositories can be used.

- **Risk:** Users might include untrusted or malicious themes, increasing the attack surface.

- **Mitigation:** *None.  (See [Recommendations for Mitigation](#recommendations-for-mitigation) )*

---

## Recommendations for Mitigation

### 1. Sandbox Theme Execution

- **Solution:** Prevent execution of arbitrary code from themes by disabling custom plugins in themes or running the build process in a sandboxed environment.

- **Implementation:** Configure Jekyll to ignore plugins from the theme by setting `safe: true` in the `_config.yml` or modifying the plugin loading mechanism. *(This is done automatically in Github Pages.)*

---

Other Security Considerations

### Sensitive Information:

The new Proxy feature allows you to add username and passwords in the `_config.yml`.

**Avoid Hardcoding Credentials:** Do not hardcode proxy credentials in version-controlled files. Consider using environment variables or a separate configuration file that's ignored by version control.

- Example Using Environment Variables:

  ```yaml
  proxy:
    address: 'proxy.example.com'
    port: 8080
    username: '<%= ENV["PROXY_USERNAME"] %>'
    password: '<%= ENV["PROXY_PASSWORD"] %>'
  ```

  Set the environment variables PROXY_USERNAME and PROXY_PASSWORD in your shell or deployment environment.

---
