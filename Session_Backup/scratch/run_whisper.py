import sys
import os
import json
import time
from faster_whisper import WhisperModel

def main():
    wav_path = r"C:\Users\djtwo\.gemini\antigravity\scratch\audio_16k.wav"
    output_json = r"C:\Users\djtwo\.gemini\antigravity\scratch\whisper_segments.json"
    output_txt = r"C:\Users\djtwo\.gemini\antigravity\scratch\whisper_transcript.txt"

    print(f"Loading faster-whisper on CUDA (RTX 3050 Ti)...", flush=True)
    t0 = time.time()
    model = WhisperModel("base.en", device="cuda", compute_type="float16")
    print(f"Model loaded in {time.time() - t0:.2f}s", flush=True)

    print(f"Starting transcription of {wav_path}...", flush=True)
    t_start = time.time()
    segments_generator, info = model.transcribe(
        wav_path,
        beam_size=1,
        language="en",
        vad_filter=True,
        vad_parameters=dict(min_silence_duration_ms=500),
        word_timestamps=True
    )

    all_segments = []
    with open(output_txt, "w", encoding="utf-8") as ft:
        for seg in segments_generator:
            s_data = {
                "start": round(seg.start, 2),
                "end": round(seg.end, 2),
                "text": seg.text.strip(),
                "words": [{"word": w.word, "start": round(w.start, 2), "end": round(w.end, 2), "prob": round(w.probability, 2)} for w in (seg.words or [])]
            }
            all_segments.append(s_data)
            
            # Format timestamp
            m_s, s_s = divmod(int(seg.start), 60)
            h_s, m_s = divmod(m_s, 60)
            m_e, s_e = divmod(int(seg.end), 60)
            h_e, m_e = divmod(m_e, 60)
            line = f"[{h_s:02d}:{m_s:02d}:{s_s:02d} - {h_e:02d}:{m_e:02d}:{s_e:02d}] {seg.text.strip()}"
            ft.write(line + "\n")
            print(line, flush=True)

    with open(output_json, "w", encoding="utf-8") as fj:
        json.dump(all_segments, fj, indent=2)

    total_time = time.time() - t_start
    print(f"\nDone! Transcribed in {total_time:.1f}s ({total_time/60:.2f} mins). Total segments: {len(all_segments)}", flush=True)

if __name__ == "__main__":
    main()
