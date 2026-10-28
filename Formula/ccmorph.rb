class Ccmorph < Formula
  desc "Every Claude Code account, API key and gateway behind one command"
  homepage "https://github.com/akleizor/ccmorph"
  url "https://github.com/akleizor/ccmorph/archive/refs/tags/v0.2.0-rc1.tar.gz"
  sha256 "09b3c28144fd0be4b9b0d019887238bf26c01f6aed4d96ba70f81cc7d1e6c635"
  license "MIT"

  depends_on "go" => :build
  uses_from_macos "python"
  uses_from_macos "zsh"

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w", output: buildpath/"libexec/gateway-shim"),
           "./cmd/gateway-shim"
    # ccmorph finds lib/, libexec/ and share/ beside each other; state stays in ~/.config/ccmorph.
    libexec.install "bin", "lib", "libexec", "share"
    bin.install_symlink libexec/"bin/ccmorph"
  end

  def caveats
    <<~EOS
      Profiles live in ~/.config/ccmorph. Add one with:
        ccmorph add <name>
      Requires the claude CLI: https://docs.anthropic.com/en/docs/claude-code/setup
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/ccmorph --version")
    # The shim exits on its own once its --parent-pid (a short sleep) is gone.
    assert_match "gateway-shim :",
                 shell_output("sleep 2 & #{libexec}/libexec/gateway-shim 0 http://127.0.0.1:9 --parent-pid=$!")
  end
end
