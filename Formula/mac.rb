class Mac < Formula
  desc "Operate macOS apps through Accessibility from the command-line"
  homepage "https://github.com/akleizor/mac-pilot"
  url "https://github.com/akleizor/mac-pilot/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "54f2d07caac35efd696a7e0389c9fecab4e7b676165c01d124c005647503f597"
  license "Apache-2.0"

  bottle do
    root_url "https://github.com/akleizor/homebrew-tap/releases/download/mac-0.4.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "f2c31e7b74d1a1994f7763b1cc6b53e71b3e50ef9aa51b07ffde06a3ff2978a4"
  end

  depends_on :macos
  depends_on "node"

  def install
    # Built here, not on first use: endpoint security kills binaries compiled at runtime in ~/.cache.
    system "swiftc", "-O", "-module-cache-path", buildpath/"module-cache",
           "lib/ax.swift", "-o", "lib/mac-ax"
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
    # the prebuilt driver answers without any permission
    assert_match "granted", shell_output("#{libexec}/lib/mac-ax trusted")
  end
end
