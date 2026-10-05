import json

with open(r"C:\Users\djtwo\.gemini\antigravity\brain\56930dde-d49e-4d64-b3a0-ddf3ad4cb3e8\scratch\july19_full_transcript.json", "r", encoding="utf-8") as f:
    segments = json.load(f)

print(f"Total segments: {len(segments)}")

# Filter segments around each transition
for s in segments:
    start = s["start"]
    end = s["end"]
    text = s["text"]
    m0, s0 = divmod(int(start), 60)
    m1, s1 = divmod(int(end), 60)
    # Check around 18:00 - 25:30 and 30:00 - 35:26
    if (18*60 <= start <= 26*60) or (30*60 <= start <= 35.5*60):
        print(f"[{m0:02d}:{s0:02d} -> {m1:02d}:{s1:02d}] {text}")
