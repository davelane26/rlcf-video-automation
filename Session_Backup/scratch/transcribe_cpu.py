import sys
import time
import json
from faster_whisper import WhisperModel

def run():
    print("Loading tiny.en model on CPU...", flush=True)
    t0 = time.time()
    model = WhisperModel("tiny.en", device="cpu", compute_type="int8")
    print(f"Model loaded in {time.time() - t0:.2f}s", flush=True)

    audio_path = r"C:\Users\djtwo\.gemini\antigravity\scratch\audio_16k.wav"
    out_file = r"C:\Users\djtwo\.gemini\antigravity\scratch\whisper_worship.txt"
    out_json = r"C:\Users\djtwo\.gemini\antigravity\scratch\whisper_worship.json"

    print("Transcribing first 45 minutes (worship & transitions)...", flush=True)
    t_start = time.time()
    
    # transcribe the first 2700 seconds (45 mins)
    segments, info = model.transcribe(
        audio_path,
        beam_size=1,
        language="en",
        vad_filter=True,
        vad_parameters=dict(min_silence_duration_ms=400)
    )

    all_segments = []
    with open(out_file, "w", encoding="utf-8") as f:
        for seg in segments:
            if seg.start > 2700: # past 45 mins
                break
            s_data = {
                "start": round(seg.start, 2),
                "end": round(seg.end, 2),
                "text": seg.text.strip()
            }
            all_segments.append(s_data)
            
            m_s, s_s = divmod(int(seg.start), 60)
            h_s, m_s = divmod(m_s, 60)
            m_e, s_e = divmod(int(seg.end), 60)
            h_e, m_e = divmod(m_e, 60)
            line = f"[{h_s:02d}:{m_s:02d}:{s_s:02d} -> {h_e:02d}:{m_e:02d}:{s_e:02d}] {seg.text.strip()}"
            print(line, flush=True)
            f.write(line + "\n")
            f.flush()

    with open(out_json, "w", encoding="utf-8") as fj:
        json.dump(all_segments, fj, indent=2)

    print(f"\nDone in {time.time() - t_start:.1f}s. Segments count: {len(all_segments)}", flush=True)

if __name__ == "__main__":
    run()
