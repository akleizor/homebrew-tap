class Mac < Formula
  desc "Operate macOS apps through Accessibility from the command-line"
  homepage "https://github.com/akleizor/mac-pilot"
  url "https://github.com/akleizor/mac-pilot/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "9b1bb570d792f23f2ef84b8340f9af580d72340b49acd090ac6d43f1f456065c"
  license "Apache-2.0"

  depends_on :macos
  depends_on "node"

  def install
    # bin/mac runs ../lib/mac.mjs; the Swift driver builds into ~/.cache/mac on first use.
    libexec.install "bin", "lib"
    (bin/"mac").write_env_script libexec/"bin/mac", PATH: "#{formula_opt_bin("node")}:$PATH"
  end

  def caveats
    <<~EOS
      mac needs the Accessibility permission for the app you run it from. Grant it with:
        mac setup
    EOS
  end

  test do
    assert_match "usage: mac", shell_output("#{bin}/mac 2>&1", 2)
    # the driver mac builds on first use compiles and answers without any permission
    system "swiftc", "-O", "-module-cache-path", testpath/"module-cache", libexec/"lib/ax.swift", "-o", testpath/"mac-ax"
    assert_match "granted", shell_output("#{testpath}/mac-ax trusted")
  end
end
