import sys
from faster_whisper import WhisperModel
import json

audio_path = r"C:\Users\djtwo\.gemini\antigravity\scratch\praise_aug23_16k.wav"
print("Loading model...", flush=True)
model = WhisperModel("tiny.en", device="cpu", compute_type="int8")

print("Transcribing...", flush=True)
segments, info = model.transcribe(audio_path, beam_size=1, word_timestamps=True)

results = []
count = 0
for segment in segments:
    t0 = segment.start
    t1 = segment.end
    text = segment.text.strip()
    m0, s0 = int(t0 // 60), int(t0 % 60)
    m1, s1 = int(t1 // 60), int(t1 % 60)
    line = f"[{m0:02d}:{s0:02d} - {m1:02d}:{s1:02d}] {text}"
    print(line, flush=True)
    results.append({
        "start": t0,
        "end": t1,
        "text": text,
        "words": [{"word": w.word, "start": w.start, "end": w.end} for w in segment.words] if segment.words else []
    })
    count += 1
    if t0 > 2800: # 46+ minutes
        break

with open(r"C:\Users\djtwo\.gemini\antigravity\brain\56930dde-d49e-4d64-b3a0-ddf3ad4cb3e8\scratch\praise_aug23_transcript.json", "w", encoding="utf-8") as f:
    json.dump(results, f, indent=2)

print("Done! Transcribed segments:", count, flush=True)
