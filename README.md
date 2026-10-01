# homebrew-reses

The Homebrew tap for [re:SES](https://github.com/spdrman/reses), a terminal inbox for the raw email Amazon SES stores in S3.

```
brew install spdrman/reses/reses
```

That taps this repo and installs the latest release. `brew upgrade` keeps it current.

It works on macOS (Apple Silicon) and Linux (x86_64 and arm64). The formula installs the prebuilt, tested release binary for your platform, pinned by checksum.

## How it stays current

`Formula/reses.rb` pins one release's archives by URL and sha256, the way Homebrew expects. After a release is published, the reses release workflow dispatches this tap's guarded bump workflow. It updates the formula from that release's `SHA256SUMS`, audits, installs and tests it, then commits only after macOS and Linux tests pass. A six-hour schedule is the fallback if dispatch is unavailable. `brew install spdrman/reses/reses` and `brew upgrade` use the latest version committed to this formula; the tap does not currently provide versioned `reses@…` formulas for selecting an older release.
