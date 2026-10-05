import json
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

# Load audio
sr, data = wavfile.read(r"C:\Users\djtwo\.gemini\antigravity\scratch\audio_16k.wav")
data = data.astype(np.float32) / 32768.0

ranges_to_inspect = [
    ("Song 1 Start", 370, 385),   # 06:10 - 06:25
    ("Song 1 End", 515, 535),     # 08:35 - 08:55
    ("Song 2 Start", 555, 575),   # 09:15 - 09:35
    ("Song 2 End", 750, 770),     # 12:30 - 12:50
    ("Song 3 Start", 1420, 1440), # 23:40 - 24:00
    ("Song 3 End", 1655, 1675),   # 27:35 - 27:55
    ("Song 4 Start", 1680, 1700), # 28:00 - 28:20
    ("Song 4 End", 1790, 1810),   # 29:50 - 30:10
    ("Song 5 Start", 1805, 1820), # 30:05 - 30:20
    ("Song 5 End", 1935, 1955),   # 32:15 - 32:35
    ("Song 6 Start", 1995, 2015), # 33:15 - 33:35
    ("Song 6 End", 2160, 2185),   # 36:00 - 36:25
]

print("Refining boundaries...")
for name, start_s, end_s in ranges_to_inspect:
    sub = data[int(start_s*sr):int(end_s*sr)]
    # Look at 0.5s windows
    win = int(0.5 * sr)
    energies = []
    times = []
    for i in range(0, len(sub)-win, win//2):
        chunk = sub[i:i+win]
        rms = np.sqrt(np.mean(chunk**2))
        t = start_s + i / sr
        energies.append(rms)
        times.append(t)
    
    # Print profile
    print(f"\n=== {name} ({start_s}s - {end_s}s) ===")
    for t, e in zip(times[::2], energies[::2]):
        m, s = divmod(int(t), 60)
        rms_db = 20 * np.log10(e + 1e-6)
        print(f"  {m:02d}:{s:02d}.{int((t%1)*10):01d} (tc {format_tc(t)}): {rms_db:.1f} dB")
