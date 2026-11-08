class Ccmorph < Formula
  desc "Every Claude Code account, API key and gateway behind one command"
  homepage "https://github.com/akleizor/ccmorph"
  url "https://github.com/akleizor/ccmorph/archive/refs/tags/v0.5.7.tar.gz"
  sha256 "c5f445a13bc55217c8dbde13b6cc417caeb742f816aca41fb06c49624c3420cf"
  license "MIT"

  bottle do
    root_url "https://github.com/akleizor/homebrew-tap/releases/download/ccmorph-0.5.6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "51c187eecc909d50feb00a169ec90b30f3f93bf69adf47a9910ddc92bc4419b8"
    sha256 cellar: :any,                 x86_64_linux: "0ddfd092b3e2da0ef8715e14d3f8113e1d1c66b9e0e3528c0e79a4dd17585337"
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
