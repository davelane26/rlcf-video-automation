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

def get_rms_series(t_start, t_end, win_s=0.1, step_s=0.05):
    sub = data[int(t_start * sr):int(t_end * sr)]
    win = int(win_s * sr)
    step = int(step_s * sr)
    res = []
    for i in range(0, len(sub) - win, step):
        chunk = sub[i:i+win]
        rms = np.sqrt(np.mean(chunk**2))
        t = t_start + i / sr
        rms_db = 20 * np.log10(rms + 1e-6)
        res.append((t, rms_db))
    return res

# 1. Opening Prayer End / Song 1 Intro
print("=== Transition 1: Opening Prayer -> Song 1 Intro ===")
# Prayer finishes around 2:08 - 2:12 ("We ask in Jesus name, Amen"). Guitar intro starts.
for t, db in get_rms_series(127, 135, 0.1, 0.05):
    if db > -35:
        print(f"  {t:.2f}s ({format_tc(t)}): {db:.1f} dB")

# 2. Song 1 End -> Speaking 1
print("\n=== Transition 2: Song 1 End -> Speaking 1 ===")
# Song 1 singing ends ~5:18 - 5:24
for t, db in get_rms_series(318, 326, 0.1, 0.05):
    print(f"  {t:.2f}s ({format_tc(t)}): {db:.1f} dB")

# 3. Speaking 1 -> Song 2 Intro
print("\n=== Transition 3: Speaking 1 -> Song 2 Intro ===")
# Speaking 1 ends ~6:14 - 6:20 ("Let's clap and sing")
for t, db in get_rms_series(372, 380, 0.1, 0.05):
    print(f"  {t:.2f}s ({format_tc(t)}): {db:.1f} dB")

# 4. Song 2 End -> Speaking 2
print("\n=== Transition 4: Song 2 End -> Speaking 2 ===")
# Song 2 ends ~8:02 - 8:12
for t, db in get_rms_series(483, 492, 0.1, 0.05):
    print(f"  {t:.2f}s ({format_tc(t)}): {db:.1f} dB")

# 5. Speaking 2 -> Song 3 Intro
print("\n=== Transition 5: Speaking 2 -> Song 3 Intro ===")
# Speaking 2 ends ~20:44 - 20:52 ("outpouring of the Spirit... burn fire of God")
for t, db in get_rms_series(1244, 1254, 0.1, 0.05):
    print(f"  {t:.2f}s ({format_tc(t)}): {db:.1f} dB")

# 6. Song 3 End -> Speaking 3
print("\n=== Transition 6: Song 3 End -> Speaking 3 ===")
# Song 3 ends ~24:50 - 25:00
for t, db in get_rms_series(1488, 1498, 0.1, 0.05):
    print(f"  {t:.2f}s ({format_tc(t)}): {db:.1f} dB")

# 7. Speaking 3 -> Song 4 Intro
print("\n=== Transition 7: Speaking 3 -> Song 4 Intro ===")
# Speaking 3 ends ~26:40 - 26:50 ("If we have Christ we have everything we need")
for t, db in get_rms_series(1600, 1612, 0.1, 0.05):
    print(f"  {t:.2f}s ({format_tc(t)}): {db:.1f} dB")

# 8. Song 4 End -> Song 5 Intro
print("\n=== Transition 8: Song 4 End -> Song 5 Intro ===")
# Transition between Song 4 and Song 5 ~30:30 - 30:40
for t, db in get_rms_series(1830, 1842, 0.1, 0.05):
    print(f"  {t:.2f}s ({format_tc(t)}): {db:.1f} dB")

# 9. Song 5 End
print("\n=== Transition 9: Song 5 End / Outro ===")
for t, db in get_rms_series(2118, 2125, 0.1, 0.05):
    print(f"  {t:.2f}s ({format_tc(t)}): {db:.1f} dB")
