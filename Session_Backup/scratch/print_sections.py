import json

with open(r"C:\Users\djtwo\.gemini\antigravity\scratch\whisper_worship.json", "r", encoding="utf-8") as f:
    segs = json.load(f)

print(f"Total segments loaded: {len(segs)}")

for s in segs:
    t = s["start"]
    m = int(t) // 60
    s_rem = int(t) % 60
    if 22 <= m <= 38:
        print(f"[{m:02d}:{s_rem:02d}] {s.get('text', '')}")
