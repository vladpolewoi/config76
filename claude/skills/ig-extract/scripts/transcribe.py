# Local Whisper for Instagram video audio — writes <file>.transcript.txt next to each input.
# Usage: uv run -q --python 3.12 --with faster-whisper python -I transcribe.py <file>...
# Recipe from graph76-new/tools/sweep/transcribe.py: decode with system ffmpeg (PyAV breaks
# on Arch's ffmpeg); VAD on so music-only reels come back empty instead of hallucinated.
import os, sys, subprocess, numpy as np
from faster_whisper import WhisperModel
m = WhisperModel("large-v3-turbo", device="cpu", compute_type="int8", cpu_threads=16)
for p in sys.argv[1:]:
    raw = subprocess.run(["ffmpeg","-v","quiet","-i",p,"-vn","-f","s16le","-ac","1","-ar","16000","-"],capture_output=True).stdout
    out = os.path.splitext(p)[0] + ".transcript.txt"
    if not raw:  # video without an audio track
        open(out, "w").write("(no audio track)\n"); continue
    a = np.frombuffer(raw, np.int16).astype(np.float32)/32768
    segs, info = m.transcribe(a, beam_size=5, vad_filter=True)
    lines = [f"{s.start:5.1f}s {s.text.strip()}" for s in segs]
    head = f"[{info.language} {info.language_probability:.2f}]"
    open(out, "w").write(head + "\n" + ("\n".join(lines) if lines else "(no speech — music only? check frames/)") + "\n")
    print(f"  {os.path.basename(p)} {head} {sum(len(l.split())-1 for l in lines)} words", file=sys.stderr)
