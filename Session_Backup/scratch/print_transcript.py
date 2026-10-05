import json

with open(r"C:\Users\djtwo\.gemini\antigravity\brain\56930dde-d49e-4d64-b3a0-ddf3ad4cb3e8\scratch\praise_transcript.json", "r", encoding="utf-8") as f:
    segments = json.load(f)

for s in segments:
    start = s["start"]
    end = s["end"]
    text = s["text"]
    if start < 2300: # First ~38 mins
        m0, s0 = divmod(int(start), 60)
        m1, s1 = divmod(int(end), 60)
        print(f"[{m0:02d}:{s0:02d} - {m1:02d}:{s1:02d}] {text}")
