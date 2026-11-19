class Cliproxyapi < Formula
  desc "Proxy API with Gemini reasoning_details and parallel tool call fixes"
  homepage "https://github.com/akleizor/CLIProxyAPI"
  # Prebuilt: Homebrew's sandboxed Go build hangs on this machine (akleizor/ccmorph#646).
  url "https://github.com/akleizor/CLIProxyAPI/releases/download/v8.0.76-akleizor.6/cliproxyapi-8.0.76-akleizor.6-darwin-arm64.tar.gz"
  version "8.0.76-akleizor.6"
  sha256 "67757a59dfe8ca83bd7d99437d1b97868fce64fb3ede6d1e3fa6b99366e2ec4b"
  license "MIT"

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
