#!/usr/bin/env bash
# usage: DROPBOX_FOLDER_URL=... sync-dropbox-photos.sh <destination dir>
set -euo pipefail

dest="$1"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# With dl=1 Dropbox returns the whole shared folder as a zip archive
url="${DROPBOX_FOLDER_URL/dl=0/dl=1}"
[[ "$url" == *dl=1* ]] || url="$url$([[ "$url" == *\?* ]] && echo '&' || echo '?')dl=1"

curl --fail --silent --show-error --location --retry 3 -o "$tmp/photos.zip" "$url"
# Dropbox archives contain a "/" entry that unzip cannot extract
unzip -q -o "$tmp/photos.zip" -d "$tmp/photos" -x /

mkdir -p "$dest"
count=0
while IFS= read -r -d '' photo; do
  name=$(basename "$photo")
  cp "$photo" "$dest/dropbox-${name//[^A-Za-z0-9._-]/-}"
  count=$((count + 1))
done < <(find "$tmp/photos" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -print0)

echo "Imported $count photos from Dropbox into $dest"
