# homebrew-reses

The Homebrew tap for [re:SES](https://github.com/spdrman/reses), a terminal inbox for the raw email Amazon SES stores in S3.

```
brew install spdrman/reses/reses
```

That taps this repo and installs the latest release. `brew upgrade` keeps it current.

It works on macOS (Apple Silicon) and Linux (x86_64 and arm64). The formula installs the prebuilt, tested release binary for your platform, pinned by checksum.

## How it stays current

`Formula/reses.rb` pins one release's archives by URL and sha256, the way Homebrew expects. Every six hours the Bump workflow runs `scripts/bump.sh`. When there's a newer reses release, it rewrites those lines from that release's `SHA256SUMS`, audits the formula, installs and tests it, and only then commits. The Tests workflow audits, installs and tests the formula on macOS and Linux for every push.
