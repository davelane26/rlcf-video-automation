import sys
import time
from faster_whisper import WhisperModel

def run():
    print("Loading faster-whisper base.en model...", flush=True)
    t0 = time.time()
    # compute_type="int8" runs on CPU with minimal RAM and high speed
    model = WhisperModel("base.en", device="cpu", compute_type="int8")
    print(f"Model loaded in {time.time() - t0:.2f}s", flush=True)

    audio_path = r"C:\Users\djtwo\.gemini\antigravity\scratch\audio_16k.wav"
    print(f"Transcribing {audio_path}...", flush=True)
    
    # We transcribe with word timestamps and VAD filter enabled
    segments, info = model.transcribe(
        audio_path,
        beam_size=1,
        language="en",
        vad_filter=True,
        vad_parameters=dict(min_silence_duration_ms=500)
    )

    print(f"Detected language: {info.language} with probability {info.language_probability:.2f}")
    print("Segments:")

    with open(r"C:\Users\djtwo\.gemini\antigravity\scratch\transcript_segments.txt", "w", encoding="utf-8") as f:
        for segment in segments:
            m_s, s_s = divmod(int(segment.start), 60)
            h_s, m_s = divmod(m_s, 60)
            m_e, s_e = divmod(int(segment.end), 60)
            h_e, m_e = divmod(m_e, 60)
            line = f"[{h_s:02d}:{m_s:02d}:{s_s:02d} -> {h_e:02d}:{m_e:02d}:{s_e:02d}] {segment.text}"
            print(line, flush=True)
            f.write(line + "\n")

if __name__ == "__main__":
    run()
