class Cliproxyapi < Formula
  desc "Proxy API with Gemini reasoning_details and parallel tool call fixes"
  homepage "https://github.com/akleizor/CLIProxyAPI"
  # Prebuilt: Homebrew's sandboxed Go build hangs on this machine (akleizor/ccmorph#646).
  url "https://github.com/akleizor/CLIProxyAPI/releases/download/v8.0.76-akleizor.4/cliproxyapi-8.0.76-akleizor.4-darwin-arm64.tar.gz"
  version "8.0.76-akleizor.4"
  sha256 "be5e2fe9eed84bd9f0a650ce00c709e17351b1c78e0f4c9042af2d5c7b326fb4"
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
