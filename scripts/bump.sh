#!/usr/bin/env bash
# Point Formula/reses.rb at the latest spdrman/reses release.
#
# I read the latest release's tag and its SHA256SUMS asset, then rewrite every download URL and
# sha256 in the formula. It prints the new version when it changed something and nothing when
# the formula was already current, so the workflow can decide whether to commit. It refuses to
# write anything unless the tag is a plain version, all three targets have a valid checksum,
# and exactly three URL and sha256 pairs were rewritten, so a half-published or odd release can
# never produce a broken or mixed formula.
set -euo pipefail
cd "$(dirname "$0")/.."
formula=Formula/reses.rb
targets=(aarch64-apple-darwin aarch64-unknown-linux-musl x86_64-unknown-linux-musl)

tag=$(gh api repos/spdrman/reses/releases/latest --jq .tag_name)
[[ "$tag" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.]+)?$ ]] || { echo "refusing an unexpected tag: '$tag'" >&2; exit 1; }
version=${tag#v}
current=$(sed -nE 's|.*releases/download/v([^/]+)/.*|\1|p' "$formula" | sort -u)
[ -n "$current" ] || { echo "couldn't read the formula's current version" >&2; exit 1; }
[ "$version" = "$current" ] && exit 0

sums=$(gh release download "$tag" -R spdrman/reses -p SHA256SUMS -O -)
tmp=$(mktemp)
trap 'rm -f "$tmp" "$tmp.new"' EXIT
cp "$formula" "$tmp"
for target in "${targets[@]}"; do
  file="reses-$tag-$target.tar.gz"
  sha=$(awk -v f="$file" '$2 == f {print $1}' <<<"$sums")
  [[ "$sha" =~ ^[0-9a-f]{64}$ ]] || { echo "no valid checksum for $file in $tag's SHA256SUMS" >&2; exit 1; }
  # The sha256 line always follows its url line, so replace the pair together.
  awk -v t="$target" -v url="https://github.com/spdrman/reses/releases/download/$tag/$file" -v sha="$sha" '
    $0 ~ "releases/download/.*-" t "\\.tar\\.gz\"" { sub(/url "[^"]+"/, "url \"" url "\""); print; fix=1; next }
    fix && /sha256 "/ { sub(/sha256 "[^"]+"/, "sha256 \"" sha "\""); fix=0 }
    { print }' "$tmp" > "$tmp.new"
  mv "$tmp.new" "$tmp"
done
# Every URL must now be on the new tag, and there must be exactly one per target.
urls=$(grep -c 'url "https://github.com/spdrman/reses/releases/download/' "$tmp" || true)
new=$(grep -c "releases/download/$tag/" "$tmp" || true)
[ "$urls" = 3 ] && [ "$new" = 3 ] || { echo "expected 3 rewritten URLs, found $new of $urls" >&2; exit 1; }
mv "$tmp" "$formula"
echo "$version"
