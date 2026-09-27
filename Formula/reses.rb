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
      url "https://github.com/spdrman/reses/releases/download/v0.2.3/reses-v0.2.3-aarch64-apple-darwin.tar.gz"
      sha256 "97f75f797ffff95c5370f338c0eb77af84ea3be0e1033e0abdfabd270769dc2c"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/spdrman/reses/releases/download/v0.2.3/reses-v0.2.3-aarch64-unknown-linux-musl.tar.gz"
      sha256 "03e9112250ada0e31b549c5ca1453f28aa0e2e8dd807609868cd4cba92de86f8"
    end
    on_intel do
      url "https://github.com/spdrman/reses/releases/download/v0.2.3/reses-v0.2.3-x86_64-unknown-linux-musl.tar.gz"
      sha256 "c89e37058e2c72f881201c6354433c65d0b14c88372344cdfcfaed6acb66c03e"
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
