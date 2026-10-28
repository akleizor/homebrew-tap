class Ccmorph < Formula
  desc "Every Claude Code account, API key and gateway behind one command"
  homepage "https://github.com/akleizor/ccmorph"
  url "https://github.com/akleizor/ccmorph/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "de7ec4c5c5aed672f5070b2d0262a1bfb6d50099b9be6a338f38e34e7501220f"
  license "MIT"

  bottle do
    root_url "https://github.com/akleizor/homebrew-tap/releases/download/ccmorph-0.2.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "8dc2130add9d0219465e7217eb1e63bbed220579b5aa33b68eab6e8a0ff69cad"
    sha256 cellar: :any,                 x86_64_linux: "b788b8d247b0b0c9b458f35b0dc30a6aea651ec26cee2dde692035a4211b1ecf"
  end

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
