import numpy as np
import scipy.io.wavfile as wavfile
from faster_whisper import WhisperModel
import json

audio_path = r"C:\Users\djtwo\.gemini\antigravity\scratch\praise_aug23_16k.wav"
print("Loading wav file...", flush=True)
sr, data = wavfile.read(audio_path)
total_duration = len(data) / sr
print(f"Loaded {total_duration:.1f} seconds of audio at {sr} Hz", flush=True)

# Convert to float32
data = data.astype(np.float32) / 32768.0

print("Loading Whisper model...", flush=True)
model = WhisperModel("tiny.en", device="cpu", compute_type="int8")

chunk_sec = 600 # 10 minutes per chunk
all_segments = []

# Process chunks up to 45 mins (2700s)
max_sec = min(int(total_duration), 2800)

for start_sec in range(0, max_sec, chunk_sec):
    end_sec = min(start_sec + chunk_sec, max_sec)
    print(f"\n--- Transcribing chunk {start_sec//60}m to {end_sec//60}m ---", flush=True)
    
    chunk_data = data[int(start_sec * sr):int(end_sec * sr)]
    segments, _ = model.transcribe(chunk_data, beam_size=1, vad_filter=True, language="en")
    
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

output_file = r"C:\Users\djtwo\.gemini\antigravity\brain\56930dde-d49e-4d64-b3a0-ddf3ad4cb3e8\scratch\praise_transcript.json"
with open(output_file, "w", encoding="utf-8") as f:
    json.dump(all_segments, f, indent=2)

print(f"\nCompleted transcription! {len(all_segments)} segments saved to {output_file}", flush=True)
