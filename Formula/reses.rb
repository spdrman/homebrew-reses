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
      url "https://github.com/spdrman/reses/releases/download/v0.2.5/reses-v0.2.5-aarch64-apple-darwin.tar.gz"
      sha256 "a83ee320929fa8d661f8161996a228f1641b22563eabefd2b8ea8d4573bfe742"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/spdrman/reses/releases/download/v0.2.5/reses-v0.2.5-aarch64-unknown-linux-musl.tar.gz"
      sha256 "7a79f9564d6a48fd8849f24612f3937f686dc99eea69e7590e55fe775f5762e4"
    end
    on_intel do
      url "https://github.com/spdrman/reses/releases/download/v0.2.5/reses-v0.2.5-x86_64-unknown-linux-musl.tar.gz"
      sha256 "23d964c836ee08df304c50d3153b06eb57361985075da5139303ed3eeda132a7"
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
