class Iph < Formula
  desc "Drive a real iPhone over Wi-Fi from the command-line"
  homepage "https://github.com/akleizor/iphone-pilot"
  url "https://github.com/akleizor/iphone-pilot/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "229fe48ff6d44b78eeef980fc71def731c2239bc567424f23defdc0346703d2e"
  license "Apache-2.0"

  depends_on "go" => :build
  depends_on arch: :arm64
  depends_on :macos

  def install
    # iph reads scripts/ and runner/ beside its own bin/ and keeps its state in ~/.cache/iphone-ops.
    cd "iph" do
      system "go", "build", *std_go_args(ldflags: "-s -w", output: libexec/"bin/iph")
      # built after iph: iph rebuilds a helper older than itself (into its state dir)
      # the sandbox forbids swiftc's default module cache in the user's temp dir
      system "swiftc", "-O", "-module-cache-path", buildpath/"module-cache", "-o", libexec/"bin/iph-ocr", "ocr.swift"
    end
    libexec.install "scripts", "runner"
    bin.install_symlink libexec/"bin/iph"
  end

  def caveats
    <<~EOS
      Needs Xcode with an Apple ID (Settings > Accounts) and an iPhone in Developer Mode.
      Set up the phone and its on-device runner with:
        iph setup
    EOS
  end

  test do
    assert_match "iPhone over Wi-Fi", shell_output("#{bin}/iph --help")
    # one unreadable frame in, an empty result out: the Vision helper runs
    assert_equal "[]", pipe_output(libexec/"bin/iph-ocr", "\x00\x00\x00\x03abc").strip
  end
end
