class Cliproxyapi < Formula
  desc "Proxy API with Gemini reasoning_details and parallel tool call fixes"
  homepage "https://github.com/akleizor/CLIProxyAPI"
  # Prebuilt: Homebrew's sandboxed Go build hangs on this machine (akleizor/ccmorph#646).
  url "https://github.com/akleizor/CLIProxyAPI/releases/download/v8.0.76-akleizor.7/cliproxyapi-8.0.76-akleizor.7-darwin-arm64.tar.gz"
  version "8.0.76-akleizor.7"
  sha256 "f1cc61a32c07d253eddc5e2bc78a7975f94146561836bf760c2ea83f7a2b684c"
  license "MIT"

  bottle do
    root_url "https://github.com/akleizor/homebrew-tap/releases/download/cliproxyapi-8.0.76-akleizor.7"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "23b578749bd5887ad62d2124b910c1134e61cb31bea98f43ed38df72b9b67726"
  end

  depends_on arch: :arm64
  depends_on :macos

  def install
    bin.install "cliproxyapi"
    etc.install "config.example.yaml" => "cliproxyapi.conf"
  end

  service do
    run [opt_bin/"cliproxyapi"]
    keep_alive true
  end

  test do
    assert_path_exists bin/"cliproxyapi"
  end
end
