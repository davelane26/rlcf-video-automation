import numpy as np
import scipy.io.wavfile as wavfile
from faster_whisper import WhisperModel
import json

audio_path = r"C:\Users\djtwo\.gemini\antigravity\scratch\july19_16k.wav"
sr, data = wavfile.read(audio_path)
total_duration = len(data) / sr

data = data.astype(np.float32) / 32768.0

print(f"Total duration: {total_duration:.1f}s ({total_duration/60:.2f} mins)", flush=True)

model = WhisperModel("tiny.en", device="cpu", compute_type="int8")

# Transcribe full audio in 5-minute chunks to get high accuracy
chunk_sec = 300
all_segments = []

for start_sec in range(0, int(total_duration), chunk_sec):
    end_sec = min(start_sec + chunk_sec, int(total_duration))
    print(f"\n--- Transcribing {start_sec//60}m:{start_sec%60:02d} to {end_sec//60}m:{end_sec%60:02d} ---", flush=True)
    chunk_data = data[int(start_sec * sr):int(end_sec * sr)]
    segments, _ = model.transcribe(chunk_data, beam_size=2, vad_filter=True, language="en")
    
    for s in segments:
        abs_start = start_sec + s.start
        abs_end = start_sec + s.end
        m0, s0 = divmod(int(abs_start), 60)
        m1, s1 = divmod(int(abs_end), 60)
        line = f"[{m0:02d}:{s0:02d} -> {m1:02d}:{s1:02d}] {s.text.strip()}"
        print(line, flush=True)
        all_segments.append({
            "start": abs_start,
            "end": abs_end,
            "text": s.text.strip()
        })

output_file = r"C:\Users\djtwo\.gemini\antigravity\brain\56930dde-d49e-4d64-b3a0-ddf3ad4cb3e8\scratch\july19_full_transcript.json"
with open(output_file, "w", encoding="utf-8") as f:
    json.dump(all_segments, f, indent=2)

print(f"\nSaved {len(all_segments)} segments to {output_file}", flush=True)
