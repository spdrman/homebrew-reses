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
      url "https://github.com/spdrman/reses/releases/download/v0.2.9/reses-v0.2.9-aarch64-apple-darwin.tar.gz"
      sha256 "a9a8f46739e0942344c23d2edd0f1c3e880c7e9caa37abaf6ccef2958c4dd412"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/spdrman/reses/releases/download/v0.2.9/reses-v0.2.9-aarch64-unknown-linux-musl.tar.gz"
      sha256 "78ad1e00becd1d4cd801c68fc383ed93065d29ab48856b0cd683904e94de2d1c"
    end
    on_intel do
      url "https://github.com/spdrman/reses/releases/download/v0.2.9/reses-v0.2.9-x86_64-unknown-linux-musl.tar.gz"
      sha256 "a12a151c4f150412d89fdbadcd765440494b88ca2535989a836feb1f8e206a06"
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
