class Mac < Formula
  desc "Operate macOS apps through Accessibility from the command-line"
  homepage "https://github.com/akleizor/mac-pilot"
  url "https://github.com/akleizor/mac-pilot/archive/refs/tags/v0.4.2.tar.gz"
  sha256 "fbb0b920a05e21552cc70838dca7f673610a8eb29f500ea32e06896bb3dd234d"
  license "Apache-2.0"

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
