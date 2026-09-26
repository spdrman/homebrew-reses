# Homebrew formula for re:SES, a terminal inbox for the raw email Amazon SES stores in S3.
#
# I ship the prebuilt release binaries rather than building from source, because the release
# workflow in spdrman/reses already builds and tests each one natively (static musl on Linux,
# native arm64 on macOS). Each platform pins its archive's URL and sha256, the way Homebrew
# expects, and scripts/bump.sh rewrites those lines when a new release comes out, so the
# formula always tracks the latest release.
class Reses < Formula
  desc "Terminal inbox for raw SES email stored in S3"
  homepage "https://github.com/spdrman/reses"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    # The macOS release is Apple Silicon only, so an Intel Mac gets a clear refusal.
    depends_on arch: :arm64
    on_arm do
      url "https://github.com/spdrman/reses/releases/download/v0.2.1/reses-v0.2.1-aarch64-apple-darwin.tar.gz"
      sha256 "43c6a1c68c561718bc3138de716080e91dcc9328bb2445b1723289ccd16fdf42"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/spdrman/reses/releases/download/v0.2.1/reses-v0.2.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "459a8eb71ff29da44740e92b61c0d6fc21ba68e70c5263b84d2075c49cae56d3"
    end
    on_intel do
      url "https://github.com/spdrman/reses/releases/download/v0.2.1/reses-v0.2.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "99d08a9372bbb3e24a9f99363d5f88d479250f89000e7293f1709f3961ffd776"
    end
  end

  def install
    bin.install "reses"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/reses --version")

    # A tiny stored message decodes to the readable form, which proves the binary really runs
    # rather than only printing its version.
    (testpath/"hello.eml").write <<~EML
      From: Alice <alice@example.com>
      To: bob@example.org
      Subject: Hello from Homebrew

      It works.
    EML
    output = shell_output("#{bin}/reses #{testpath}/hello.eml")
    assert_match "Subject: Hello from Homebrew", output
    assert_match "It works.", output
  end
end
