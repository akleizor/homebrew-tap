class Ccmorph < Formula
  desc "Every Claude Code account, API key and gateway behind one command"
  homepage "https://github.com/akleizor/ccmorph"
  url "https://github.com/akleizor/ccmorph/archive/refs/tags/v0.5.26.tar.gz"
  sha256 "53514349e8a68fa1f3627d8758143984d12bce94e48ba7367e4f69b623c62ea3"
  license "MIT"

  bottle do
    root_url "https://github.com/akleizor/homebrew-tap/releases/download/ccmorph-0.5.25"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "a1a10ce321966b0ac849783ad998059b007b696ed9776d29bdb140ac861aa66a"
    sha256 cellar: :any,                 x86_64_linux: "96d20973112006a6a07c95c21afbd6d743262b9581bba903cb04a89ab4f26cf6"
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
