class Ccmorph < Formula
  desc "Every Claude Code account, API key and gateway behind one command"
  homepage "https://github.com/akleizor/ccmorph"
  url "https://github.com/akleizor/ccmorph/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "cc2abbef306b276f202429d753f5f2beba90e5ef41329dd01f1937bbf7bcb460"
  license "MIT"

  depends_on "go" => :build
  uses_from_macos "zsh"

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w", output: buildpath/"libexec/gateway-shim"),
           "./cmd/gateway-shim"
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
    assert_match "gateway-shim :",
                 shell_output("sleep 2 & #{libexec}/libexec/gateway-shim 0 http://127.0.0.1:9 --parent-pid=$!")
    # Launch runs ccmorph-core; doctor exercises it and the zsh library together.
    assert_predicate libexec/"libexec/ccmorph-core", :executable?
    system bin/"ccmorph", "doctor"
  end
end
