#!/usr/bin/env bash
# Runs sync-dropbox-photos.sh against a local fake Dropbox link and checks the result.
set -euo pipefail

dir=$(cd "$(dirname "$0")" && pwd)
tmp=$(mktemp -d)
trap 'kill $server 2>/dev/null; rm -rf "$tmp"' EXIT

cat > "$tmp/server.py" <<'PY'
import io, zipfile
from http.server import BaseHTTPRequestHandler, HTTPServer

archive = io.BytesIO()
with zipfile.ZipFile(archive, "w") as z:
    z.writestr("/", "")
    z.writestr("IMG_0001.jpg", "photo 1")
    z.writestr("Gita al mare.PNG", "photo 2")
    z.writestr("2026/laboratorio.webp", "photo 3")
    z.writestr("note.txt", "not a photo")
    z.writestr("IMG_0002.heic", "not supported")

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path != "/scl/fo/abc/photos?rlkey=xyz&dl=1":
            self.send_response(404); self.end_headers(); return
        self.send_response(200); self.end_headers(); self.wfile.write(archive.getvalue())

    def log_message(self, *args):
        pass

server = HTTPServer(("127.0.0.1", 0), Handler)
print(server.server_port, flush=True)
server.serve_forever()
PY

python3 "$tmp/server.py" > "$tmp/port" & server=$!
until [ -s "$tmp/port" ]; do sleep 0.1; done
base="http://127.0.0.1:$(cat "$tmp/port")/scl/fo/abc/photos?rlkey=xyz"

DROPBOX_FOLDER_URL="$base&dl=0" "$dir/sync-dropbox-photos.sh" "$tmp/gallery"

expected="dropbox-Gita-al-mare.PNG
dropbox-IMG_0001.jpg
dropbox-laboratorio.webp"
[ "$(ls "$tmp/gallery")" = "$expected" ] || { echo "FAIL: unexpected files:"; ls "$tmp/gallery"; exit 1; }
[ "$(cat "$tmp/gallery/dropbox-IMG_0001.jpg")" = "photo 1" ] || { echo "FAIL: wrong content"; exit 1; }

DROPBOX_FOLDER_URL="$base" "$dir/sync-dropbox-photos.sh" "$tmp/no-dl-param"
[ "$(ls "$tmp/no-dl-param")" = "$expected" ] || { echo "FAIL: link without dl parameter"; exit 1; }

if DROPBOX_FOLDER_URL="${base/abc/missing}" "$dir/sync-dropbox-photos.sh" "$tmp/other" 2>/dev/null; then
  echo "FAIL: a broken link must make the sync fail"; exit 1
fi

echo "OK"
