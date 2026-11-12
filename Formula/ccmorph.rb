class Ccmorph < Formula
  desc "Every Claude Code account, API key and gateway behind one command"
  homepage "https://github.com/akleizor/ccmorph"
  url "https://github.com/akleizor/ccmorph/archive/refs/tags/v0.5.12.tar.gz"
  sha256 "1a57e4b3753c766be3c6c0ea63e5166f07ae101bf5acc833c6d2e76587999e5d"
  license "MIT"

  bottle do
    root_url "https://github.com/akleizor/homebrew-tap/releases/download/ccmorph-0.5.11"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "82db93948efd32c5786bcc67cb74d465d21fa86c3fde58187ef6b115eb53d004"
    sha256 cellar: :any,                 x86_64_linux: "1e6594ad79291c291ac6c7c96cb650eba728b288a9d614c98780515a70300753"
  end

  depends_on "go" => :build
  uses_from_macos "zsh"

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w", output: buildpath/"libexec/ccmorph-core"),
           "./cmd/ccmorph-core"
    # ccmorph finds lib/, libexec/ and share/ beside each other; state stays in ~/.config/ccmorph.
    libexec.install "bin", "lib", "libexec", "share"
    bin.install_symlink libexec/"bin/ccmorph"
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
    # The shim exits on its own once its --parent-pid (a short sleep) is gone.
    assert_match "shim :",
                 shell_output("sleep 2 & #{libexec}/libexec/ccmorph-core shim 0 http://127.0.0.1:9 --parent-pid=$!")
    # Launch runs ccmorph-core; a missing or unrunnable binary fails here.
    assert_match "usage: ccmorph-core", shell_output("#{libexec}/libexec/ccmorph-core 2>&1", 2)
  end
end
