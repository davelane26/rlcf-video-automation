import time
from faster_whisper import WhisperModel

print("Loading model...", flush=True)
model = WhisperModel("tiny.en", device="cpu", compute_type="int8")

print("Transcribing August 9 meeting (first 40 mins)...", flush=True)
segments, _ = model.transcribe(
    r"C:\Users\djtwo\.gemini\antigravity\scratch\aug9_audio.wav",
    beam_size=1,
    language="en",
    vad_filter=True
)

with open(r"C:\Users\djtwo\.gemini\antigravity\scratch\aug9_transcript.txt", "w", encoding="utf-8") as f:
    for s in segments:
        m, sec = divmod(int(s.start), 60)
        h, m = divmod(m, 60)
        m_e, sec_e = divmod(int(s.end), 60)
        h_e, m_e = divmod(m_e, 60)
        line = f"[{h:02d}:{m:02d}:{sec:02d} -> {h_e:02d}:{m_e:02d}:{sec_e:02d}] {s.text.strip()}"
        f.write(line + "\n")
        f.flush()
        print(line, flush=True)

print("Finished transcription of August 9 audio.", flush=True)
