class Ccmorph < Formula
  desc "Every Claude Code account, API key and gateway behind one command"
  homepage "https://github.com/akleizor/ccmorph"
  url "https://github.com/akleizor/ccmorph/archive/refs/tags/v0.5.30.tar.gz"
  sha256 "f9aaf32eeee2a7e639698b5a8d983217c1b7bc912e1891694a1928b072935c29"
  license "MIT"

  bottle do
    root_url "https://github.com/akleizor/homebrew-tap/releases/download/ccmorph-0.5.30"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "ef79b906f90cef66d97a60e3081cb4edfa7fd4d650379b581b7f4211ed2b93d7"
    sha256 cellar: :any,                 x86_64_linux: "1b1ccb3346cab61b34f495b1b9a662afd4bdc31cc9b3186f9929191a753d6961"
  end

  depends_on "go" => :build
  uses_from_macos "zsh"

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w", output: buildpath/"libexec/ccmorph-core"),
           "./cmd/ccmorph-core"
    # ccmorph finds lib/, libexec/ and share/ beside each other; state stays in ~/.config/ccmorph.
    libexec.install "bin", "lib", "libexec", "share"
    # A session exports CCMORPH_LIB_DIR to its children; the opt path survives an upgrade,
    # a Cellar version path does not, and every running session's ccmorph would then fail.
    (bin/"ccmorph").write_env_script opt_libexec/"bin/ccmorph", CCMORPH_LIB_DIR: opt_libexec/"lib"
    # zsh Tab completion (ccmorph #281); a release before it ships no _ccmorph.
    completion = libexec/"share/zsh/site-functions/_ccmorph"
    zsh_completion.install_symlink completion if completion.exist?
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
    # a session started before an upgrade still names the removed version's library
    assert_match version.to_s, shell_output("CCMORPH_LIB_DIR=/nonexistent/lib #{bin}/ccmorph --version")
    # The shim exits on its own once its --parent-pid (a short sleep) is gone.
    assert_match "shim :",
                 shell_output("sleep 2 & #{libexec}/libexec/ccmorph-core shim 0 http://127.0.0.1:9 --parent-pid=$!")
    # Launch runs ccmorph-core; a missing or unrunnable binary fails here.
    assert_match "usage: ccmorph-core", shell_output("#{libexec}/libexec/ccmorph-core 2>&1", 2)
  end
end
