import numpy as np
import scipy.io.wavfile as wavfile
from faster_whisper import WhisperModel

audio_path = r"C:\Users\djtwo\.gemini\antigravity\scratch\july19_16k.wav"
sr, data = wavfile.read(audio_path)
data = data.astype(np.float32) / 32768.0

model = WhisperModel("tiny.en", device="cpu", compute_type="int8")

windows = [
    ("T1: Prayer End -> Song 1", 125, 140),
    ("T2: Song 1 End -> Speaking 1", 318, 330),
    ("T3: Speaking 1 End -> Song 2", 370, 385),
    ("T4: Song 2 End -> Speaking 2", 480, 495),
    ("T5: Speaking 2 End -> Song 3", 1240, 1255),
    ("T6: Song 3 End -> Speaking 3", 1490, 1505),
    ("T7: Speaking 3 End -> Song 4", 1600, 1615),
    ("T8: Song 4 End -> Song 5", 1830, 1845),
    ("T9: Song 5 End", 2115, 2125),
]

for label, t0, t1 in windows:
    chunk = data[int(t0*sr):int(t1*sr)]
    segs, _ = model.transcribe(chunk, word_timestamps=True, vad_filter=False)
    print(f"\n=== {label} ({t0}s - {t1}s) ===")
    for s in segs:
        for w in s.words or []:
            abs_s = t0 + w.start
            abs_e = t0 + w.end
            print(f"  {abs_s:7.2f}s -> {abs_e:7.2f}s: {w.word}")
