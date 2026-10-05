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

ranges_to_inspect = [
    ("Opening Prayer -> Song 1 Intro", 125, 155),        # 02:05 - 02:35
    ("Song 1 Singing Start", 145, 160),                  # 02:25 - 02:40
    ("Song 1 End -> Speaking 1", 315, 335),              # 05:15 - 05:35
    ("Speaking 1 -> Song 2 Intro/Singing", 370, 390),     # 06:10 - 06:30
    ("Song 2 End -> Speaking 2", 480, 500),              # 08:00 - 08:20
    ("Speaking 2 -> Song 3 Intro/Singing", 1235, 1260),   # 20:35 - 21:00
    ("Song 3 End -> Speaking 3", 1485, 1505),            # 24:45 - 25:05
    ("Speaking 3 -> Song 4 Intro/Singing", 1595, 1615),   # 26:35 - 26:55
    ("Song 4 End -> Song 5 Intro/Singing", 1820, 1845),   # 30:20 - 30:45
    ("Song 5 End / Video End", 2115, 2126),              # 35:15 - 35:26
]

for name, start_s, end_s in ranges_to_inspect:
    sub = data[int(start_s * sr):int(end_s * sr)]
    win = int(0.2 * sr) # 200ms window
    step = int(0.1 * sr) # 100ms step
    energies = []
    times = []
    for i in range(0, len(sub) - win, step):
        chunk = sub[i:i+win]
        rms = np.sqrt(np.mean(chunk**2))
        t = start_s + i / sr
        energies.append(rms)
        times.append(t)
    
    print(f"\n=== {name} ===")
    # Print every 2nd or 3rd point or where energy shifts
    for t, e in zip(times[::2], energies[::2]):
        m, s = divmod(int(t), 60)
        ms = int((t % 1) * 100)
        rms_db = 20 * np.log10(e + 1e-6)
        print(f"  {m:02d}:{s:02d}.{ms:02d} (frame {int(round(t*30))}, tc {format_tc(t)}): {rms_db:5.1f} dB")
