import numpy as np
import scipy.io.wavfile as wavfile
from faster_whisper import WhisperModel

audio_path = r"C:\Users\djtwo\.gemini\antigravity\scratch\july19_16k.wav"
sr, data = wavfile.read(audio_path)
data = data.astype(np.float32) / 32768.0

# 20:30 to 25:10
sub = data[int(20.5*60*sr):int(25.2*60*sr)]
model = WhisperModel("base.en", device="cpu", compute_type="int8")
segments, _ = model.transcribe(sub, beam_size=3, vad_filter=True, language="en")

for s in segments:
    t0 = 20.5*60 + s.start
    t1 = 20.5*60 + s.end
    m0, s0 = divmod(int(t0), 60)
    m1, s1 = divmod(int(t1), 60)
    print(f"[{m0:02d}:{s0:02d} -> {m1:02d}:{s1:02d}] {s.text.strip()}")
