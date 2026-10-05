import numpy as np
import scipy.io.wavfile as wavfile

def format_tc(sec, fps=30):
    total_frames = int(round(sec * fps))
    f = total_frames % fps
    total_s = total_frames // fps
    s = total_s % 60
    total_m = total_s // 60
    m = total_m % 60
    h = total_m // 60
    return f"{h:02d}:{m:02d}:{s:02d}:{f:02d}"

sr, data = wavfile.read(r"C:\Users\djtwo\.gemini\antigravity\scratch\july19_16k.wav")
data = data.astype(np.float32) / 32768.0

transitions = [
    ("1. Prayer End / Song 1 Intro", 128, 134),
    ("2. Song 1 End / Speaking 1 Start", 320, 325),
    ("3. Speaking 1 End / Song 2 Intro", 374, 379),
    ("4. Song 2 End / Speaking 2 Start", 484, 490),
    ("5. Speaking 2 End / Song 3 Intro", 1246, 1252),
    ("6. Song 3 End / Speaking 3 Start", 1490, 1496),
]

for name, t0, t1 in transitions:
    sub = data[int(t0*sr):int(t1*sr)]
    win = int(0.1*sr)
    step = int(0.2*sr)
    times = [t0 + i/sr for i in range(0, len(sub)-win, step)]
    dbs = [20*np.log10(np.sqrt(np.mean(sub[i:i+win]**2)) + 1e-6) for i in range(0, len(sub)-win, step)]
    print(f"\n--- {name} ---")
    for t, db in zip(times, dbs):
        print(f"  {t:.2f}s ({format_tc(t)}): {db:5.1f} dB")
