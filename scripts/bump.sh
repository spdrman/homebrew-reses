#!/usr/bin/env bash
# Point Formula/reses.rb at the latest spdrman/reses release.
#
# I read the latest release's tag and its SHA256SUMS asset, then rewrite the formula's version,
# every download URL and every sha256 in place. It prints the new version when it changed
# something and nothing when the formula was already current, so the workflow can decide
# whether to commit. It refuses to write a formula with a missing or malformed checksum, so a
# half-published release can never produce a broken formula.
set -euo pipefail
cd "$(dirname "$0")/.."
formula=Formula/reses.rb

tag=$(gh api repos/spdrman/reses/releases/latest --jq .tag_name)
version=${tag#v}
current=$(sed -nE 's|.*releases/download/v([^/]+)/.*|\1|p' "$formula" | sort -u)
[ -n "$version" ] && [ -n "$current" ] || { echo "couldn't read the versions" >&2; exit 1; }
[ "$version" = "$current" ] && exit 0

sums=$(gh release download "$tag" -R spdrman/reses -p SHA256SUMS -O -)
tmp=$(mktemp)
cp "$formula" "$tmp"
for target in aarch64-apple-darwin aarch64-unknown-linux-musl x86_64-unknown-linux-musl; do
  file="reses-$tag-$target.tar.gz"
  sha=$(awk -v f="$file" '$2==f {print $1}' <<<"$sums")
  [[ "$sha" =~ ^[0-9a-f]{64}$ ]] || { echo "no valid checksum for $file in $tag's SHA256SUMS" >&2; exit 1; }
  # The sha256 line always follows its url line, so replace the pair together.
  awk -v t="$target" -v url="https://github.com/spdrman/reses/releases/download/$tag/$file" -v sha="$sha" '
    $0 ~ "releases/download/.*-" t "\\.tar\\.gz\"" { sub(/url "[^"]+"/, "url \"" url "\""); print; fix=1; next }
    fix && /sha256 "/ { sub(/sha256 "[^"]+"/, "sha256 \"" sha "\""); fix=0 }
    { print }' "$tmp" > "$tmp.new" && mv "$tmp.new" "$tmp"
done
grep -q "releases/download/$tag/" "$tmp" || { echo "the rewrite didn't take" >&2; exit 1; }
mv "$tmp" "$formula"
echo "$version"
