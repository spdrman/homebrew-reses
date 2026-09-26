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
      url "https://github.com/spdrman/reses/releases/download/v0.2.0/reses-v0.2.0-aarch64-apple-darwin.tar.gz"
      sha256 "f93357f69e7a63a3ae893aad823dcf840b3229a884b95112380d8feda2dd88b3"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/spdrman/reses/releases/download/v0.2.0/reses-v0.2.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "6fdd8282a8dd7247742b3621d36cba16698efa6bba661089c102904b9c9019fe"
    end
    on_intel do
      url "https://github.com/spdrman/reses/releases/download/v0.2.0/reses-v0.2.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "d0370c278c5297d6a4425c5518e1b9085b17043d5f2e217987d67e0183c7f7b7"
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
