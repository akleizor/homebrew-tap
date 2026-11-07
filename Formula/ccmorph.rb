class Ccmorph < Formula
  desc "Every Claude Code account, API key and gateway behind one command"
  homepage "https://github.com/akleizor/ccmorph"
  url "https://github.com/akleizor/ccmorph/archive/refs/tags/v0.5.4.tar.gz"
  sha256 "8598843531f44f7543dfb37c6f44c246b113d720020c67d23bd5e93826c00848"
  license "MIT"

  bottle do
    root_url "https://github.com/akleizor/homebrew-tap/releases/download/ccmorph-0.5.4"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "03f649bb92e8ea527f0ed92e25207f6d447d0b19db445510532e7a34c9494ddf"
    sha256 cellar: :any,                 x86_64_linux: "b823cc31bb67110eb03236ae089f6e7281bd3b0d7caec2967033ba5a26ab6899"
  end

  depends_on "go" => :build
  uses_from_macos "zsh"

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w", output: buildpath/"libexec/ccmorph-core"),
           "./cmd/ccmorph-core"
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
    assert_match "shim :",
                 shell_output("sleep 2 & #{libexec}/libexec/ccmorph-core shim 0 http://127.0.0.1:9 --parent-pid=$!")
    # Launch runs ccmorph-core; a missing or unrunnable binary fails here.
    assert_match "usage: ccmorph-core", shell_output("#{libexec}/libexec/ccmorph-core 2>&1", 2)
  end
end
