import time
from faster_whisper import WhisperModel

def run():
    model = WhisperModel("tiny.en", device="cpu", compute_type="int8")
    audio_path = r"C:\Users\djtwo\.gemini\antigravity\scratch\audio_ending.wav"
    
    segments, info = model.transcribe(
        audio_path,
        beam_size=1,
        language="en",
        vad_filter=True
    )
    
    # Base offset is 01:45:00 = 6300 seconds
    base_sec = 6300
    for seg in segments:
        t_s = base_sec + seg.start
        t_e = base_sec + seg.end
        m_s, s_s = divmod(int(t_s), 60)
        h_s, m_s = divmod(m_s, 60)
        m_e, s_e = divmod(int(t_e), 60)
        h_e, m_e = divmod(m_e, 60)
        print(f"[{h_s:02d}:{m_s:02d}:{s_s:02d} -> {h_e:02d}:{m_e:02d}:{s_e:02d}] {seg.text.strip()}", flush=True)

if __name__ == "__main__":
    run()
