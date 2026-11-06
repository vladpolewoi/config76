#!/usr/bin/env python3
# fetch-ig.py <outdir> <instagram-url>...
# Per post writes <outdir>/<code>/: post.md (caption + media list + transcripts),
# media/NN.jpg|mp4, frames/NN-MM.jpg (video stills for on-screen text).
# No login: yt-dlp does the anonymous page fetch (--write-pages), we parse the
# media JSON out of the dump. yt-dlp alone drops image slides ("No video formats").
# Run with: python3 -I fetch-ig.py ...  (transcription shells out to uv + faster-whisper)
import json, os, re, shutil, subprocess, sys, time, glob, datetime, urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
UA = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0 Safari/537.36"


def shortcode(url):
    m = re.search(r"instagram\.com/(?:[^/]+/)?(?:p|reels?|tv)/([A-Za-z0-9_-]+)", url)
    return m.group(1) if m else None


def find_media(o, code):
    if isinstance(o, dict):
        if o.get("code") == code and ("image_versions2" in o or "carousel_media" in o or "video_versions" in o):
            return o
        o = list(o.values())
    if isinstance(o, list):
        for v in o:
            r = find_media(v, code)
            if r:
                return r
    return None


def biggest(cands):
    return max(cands, key=lambda c: (c.get("width") or 0) * (c.get("height") or 0))["url"]


def download(url, path):
    req = urllib.request.Request(url, headers={"User-Agent": UA, "Referer": "https://www.instagram.com/"})
    with urllib.request.urlopen(req, timeout=60) as r, open(path, "wb") as f:
        f.write(r.read())


def fetch(url, outdir):
    code = shortcode(url)
    if not code:
        return None, f"not an Instagram post/reel URL: {url}"
    d = os.path.join(outdir, code)
    pages = os.path.join(d, ".pages")
    os.makedirs(pages, exist_ok=True)
    subprocess.run(["yt-dlp", "-q", "--no-warnings", "--skip-download", "--ignore-errors", "--write-pages",
                    f"https://www.instagram.com/p/{code}/"], cwd=pages, capture_output=True, timeout=120)
    media = None
    for dump in glob.glob(os.path.join(pages, "*.dump")):
        s = open(dump, encoding="utf-8", errors="replace").read()
        for blob in re.findall(r'<script type="application/json"[^>]*>(.*?)</script>', s, re.S):
            if code not in blob:
                continue
            try:
                media = find_media(json.loads(blob), code)
            except json.JSONDecodeError:
                continue
            if media:
                break
        if media:
            break
    if not media:
        return None, f"{code}: no media in page (private, deleted, login wall or rate limit)"

    items = []
    os.makedirs(os.path.join(d, "media"), exist_ok=True)
    for n, it in enumerate(media.get("carousel_media") or [media], 1):
        vv = it.get("video_versions")
        kind = "video" if vv else "image"
        src = biggest(vv) if vv else biggest(it["image_versions2"]["candidates"])
        path = os.path.join(d, "media", f"{n:02d}.{'mp4' if vv else 'jpg'}")
        if not os.path.exists(path):
            download(src, path)
        alt = it.get("accessibility_caption") or ""
        item = {"n": n, "kind": kind, "path": path, "alt": alt if "May be" in alt else None}  # bare "Photo by X" is noise
        if vv:
            dur = it.get("video_duration") or float(subprocess.run(
                ["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", path],
                capture_output=True, text=True).stdout.strip() or 0)
            item["duration"] = dur
            fdir = os.path.join(d, "frames")
            os.makedirs(fdir, exist_ok=True)
            fps = min(1 / 3, 15 / dur) if dur else 1 / 3  # every 3 s, or 15 stills spread over long videos
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", path, "-vf", f"fps={fps:.4f},scale=720:-2",
                            "-frames:v", "15", os.path.join(fdir, f"{n:02d}-%02d.jpg")], check=False)
            # one 5x3 contact sheet = the whole video's on-screen text in a single image read
            subprocess.run(["ffmpeg", "-v", "error", "-y", "-i", os.path.join(fdir, f"{n:02d}-%02d.jpg"),
                            "-vf", "scale=360:-2,tile=5x3", "-frames:v", "1",
                            os.path.join(fdir, f"{n:02d}-sheet.jpg")], check=False)
        items.append(item)
    shutil.rmtree(pages, ignore_errors=True)

    user = media.get("user") or {}
    post = {
        "code": code, "url": f"https://www.instagram.com/p/{code}/", "dir": d, "items": items,
        "username": user.get("username"), "full_name": user.get("full_name"),
        "caption": ((media.get("caption") or {}).get("text") or "").strip(),
        "taken_at": media.get("taken_at"), "likes": media.get("like_count"),
        "comments": media.get("comment_count"), "product_type": media.get("product_type"),
    }
    return post, None


def kind_label(p):
    imgs = sum(i["kind"] == "image" for i in p["items"])
    vids = len(p["items"]) - imgs
    if len(p["items"]) > 1:
        return f"carousel ({imgs} images, {vids} videos)"
    return "reel" if p["product_type"] == "clips" else ("video" if vids else "image")


def write_post(p):
    rel = lambda x: os.path.relpath(x, p["dir"])
    date = datetime.date.fromtimestamp(p["taken_at"]).isoformat() if p["taken_at"] else "?"
    L = [f"# {p['code']} — @{p['username']} ({p['full_name']})", "",
         f"- URL: {p['url']}", f"- Type: {kind_label(p)}",
         f"- Posted: {date} · {p['likes']} likes · {p['comments']} comments",
         f"- Fetched: {datetime.date.today().isoformat()}", "", "## Caption", "", p["caption"] or "(none)", "",
         "## Media", ""]
    for i in p["items"]:
        if i["kind"] == "image":
            L.append(f"- {i['n']:02d} image → {rel(i['path'])}" + (f" · alt: {i['alt']}" if i["alt"] else ""))
        else:
            dur = f" {i['duration']:.0f} s" if i.get("duration") else ""
            L.append(f"- {i['n']:02d} video{dur} → {rel(i['path'])} · contact sheet frames/{i['n']:02d}-sheet.jpg"
                     f" (single stills frames/{i['n']:02d}-NN.jpg)")
    for i in p["items"]:
        t = os.path.splitext(i["path"])[0] + ".transcript.txt"
        if i["kind"] == "video" and os.path.exists(t):
            L += ["", f"## Transcript — item {i['n']:02d}", "", open(t).read().strip()]
    open(os.path.join(p["dir"], "post.md"), "w").write("\n".join(L) + "\n")
    words = sum(len(l.split()) - 1 for l in "\n".join(L).splitlines() if re.match(r"\s*\d+\.\ds ", l))
    print(f"{p['code']}: {kind_label(p)}, caption {len(p['caption'].split())} words, "
          f"speech {words} words -> {p['dir']}/post.md")


def main():
    if len(sys.argv) < 3:
        sys.exit("usage: fetch-ig.py <outdir> <instagram-url>...")
    outdir, urls = sys.argv[1], sys.argv[2:]
    posts = []
    for k, url in enumerate(urls):
        if k:
            time.sleep(5)  # anonymous fetches: stay gentle
        try:
            post, err = fetch(url, outdir)
        except Exception as e:
            post, err = None, f"{url}: {e}"
        if err:
            print("ERROR:", err, file=sys.stderr)
        else:
            posts.append(post)
    vids = [i["path"] for p in posts for i in p["items"] if i["kind"] == "video"
            and not os.path.exists(os.path.splitext(i["path"])[0] + ".transcript.txt")]
    if vids:  # one Whisper load for the whole batch
        subprocess.run(["uv", "run", "-q", "--python", "3.12", "--with", "faster-whisper",
                        "python", "-I", os.path.join(HERE, "transcribe.py"), *vids], check=False)
    for p in posts:
        write_post(p)
    sys.exit(0 if len(posts) == len(urls) else 1)


main()
