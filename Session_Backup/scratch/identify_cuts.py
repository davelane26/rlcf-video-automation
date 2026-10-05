import json

def parse_time(sec):
    m, s = divmod(int(sec), 60)
    h, m = divmod(m, 60)
    return f"{h:02d}:{m:02d}:{s:02d}"

with open(r"C:\Users\djtwo\.gemini\antigravity\scratch\whisper_worship.json", "r", encoding="utf-8") as f:
    segments = json.load(f)

print(f"Total segments: {len(segments)}")

# Let's inspect intervals with gaps or distinct phrases
for i, s in enumerate(segments):
    t_start = s["start"]
    t_end = s["end"]
    txt = s["text"]
    # print sample lines every 15-20s or where big pauses occur
    if i > 0:
        prev_end = segments[i-1]["end"]
        gap = t_start - prev_end
        if gap > 8.0: # gap of silence or music without lyrics
            print(f"--- GAP of {gap:.1f}s between {parse_time(prev_end)} and {parse_time(t_start)} ---")
    
    # Print key lines
    print(f"[{parse_time(t_start)} - {parse_time(t_end)}] {txt[:60]}")
