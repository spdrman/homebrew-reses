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
      url "https://github.com/spdrman/reses/releases/download/v0.2.8/reses-v0.2.8-aarch64-apple-darwin.tar.gz"
      sha256 "ad1316de01e4eaec45201ac2490a1fe1ae62d54b5e11833c1e38d630375369f4"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/spdrman/reses/releases/download/v0.2.8/reses-v0.2.8-aarch64-unknown-linux-musl.tar.gz"
      sha256 "36534c7933978145151ff0f0ae6fbea0b15cb5a222632b77055fd9b33f41d809"
    end
    on_intel do
      url "https://github.com/spdrman/reses/releases/download/v0.2.8/reses-v0.2.8-x86_64-unknown-linux-musl.tar.gz"
      sha256 "42574739b013f054b8bfeef3279c9ccfc12742ef90816f8b3e38ab4e9630258e"
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
