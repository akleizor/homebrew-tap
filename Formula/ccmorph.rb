class Ccmorph < Formula
  desc "Every Claude Code account, API key and gateway behind one command"
  homepage "https://github.com/akleizor/ccmorph"
  url "https://github.com/akleizor/ccmorph/archive/refs/tags/v0.5.5.tar.gz"
  sha256 "f241bbe453305ae1ed9df97c9f6ca1f96d0c726d0396cf1d0f5a7c0a46aa38b6"
  license "MIT"

  bottle do
    root_url "https://github.com/akleizor/homebrew-tap/releases/download/ccmorph-0.5.5"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "a541dacf7ff3739b28d9e1eed8f2cb379d102b52a7c0db53703c76b3b9a3d9c7"
    sha256 cellar: :any,                 x86_64_linux: "4eb99c2293ced1b06b1c8269ea504a53f9d9a6305de181d75a29b5fb3342ab8b"
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
