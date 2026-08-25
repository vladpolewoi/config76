#!/usr/bin/env python3
"""Catch screenshots pushed from the iPhone and drop straight into markup.

The phone POSTs raw image bytes to  http://<pc>:8076/shot/<token>  (an iOS
Shortcut on Back Tap does this in one gesture). We save the bytes and hand
the file to mark.sh, which opens Satty on the numbered-marker tool.

Started by Hyprland's exec-once so it inherits WAYLAND_DISPLAY.
"""

import os
import subprocess
from datetime import datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

PORT = 8076
MAX_BYTES = 40 * 1024 * 1024
HOME = Path.home()
TOKEN = (HOME / ".config/shot76/token").read_text().strip()
INBOX = HOME / "shots/inbox"
MARK = HOME / "config76/arch/scripts/mark.sh"

MAGIC = {b"\x89PNG": ".png", b"\xff\xd8\xff": ".jpg", b"RIFF": ".webp"}


def suffix(blob):
    for magic, ext in MAGIC.items():
        if blob.startswith(magic):
            return ext
    return ".png" if not blob.startswith(b"\x00\x00\x00") else ".heic"


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt, *a):
        print(f"{self.address_string()} {fmt % a}", flush=True)

    def reply(self, code, body=b"ok"):
        self.send_response(code)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        self.reply(200 if self.path == f"/ping/{TOKEN}" else 404,
                   b"shot76 up")

    def do_POST(self):
        if self.path.rstrip("/") != f"/shot/{TOKEN}":
            return self.reply(403, b"bad token")

        size = int(self.headers.get("Content-Length") or 0)
        if not 0 < size <= MAX_BYTES:
            return self.reply(413, b"bad size")

        blob = self.rfile.read(size)
        INBOX.mkdir(parents=True, exist_ok=True)
        path = INBOX / (datetime.now().strftime("%H%M%S") + suffix(blob))
        path.write_bytes(blob)
        self.reply(200, str(path).encode())

        subprocess.Popen(["bash", str(MARK), str(path)],
                         stdin=subprocess.DEVNULL,
                         start_new_session=True)


if __name__ == "__main__":
    os.chdir(HOME)
    print(f"shot76 listening on :{PORT}", flush=True)
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
