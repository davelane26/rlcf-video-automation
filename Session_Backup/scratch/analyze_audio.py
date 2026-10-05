import sys
import numpy as np
import scipy.io.wavfile as wavfile
from scipy.signal import welch

def analyze(wav_path):
    print("Reading WAV file...", flush=True)
    sr, data = wavfile.read(wav_path)
    if data.dtype != np.float32:
        data = data.astype(np.float32) / 32768.0

    duration = len(data) / sr
    print(f"Sample rate: {sr} Hz, Duration: {duration:.2f} s ({duration/60:.2f} mins)", flush=True)

    summary = []
    for sec_start in range(0, int(duration), 10): # 10-second blocks
        start_samp = sec_start * sr
        end_samp = min(len(data), (sec_start + 10) * sr)
        chunk = data[start_samp:end_samp]
        if len(chunk) < sr:
            continue
        
        rms = np.sqrt(np.mean(chunk**2) + 1e-12)
        
        # Power spectrum
        f, psd = welch(chunk, fs=sr, nperseg=1024, noverlap=512)
        psd += 1e-12
        # Spectral Flatness Measure (SFM): geom_mean / arith_mean
        log_psd = np.log(psd)
        sfm = np.exp(np.mean(log_psd)) / np.mean(psd)
        
        # Low frequency energy (50 - 400 Hz) vs mid (400 - 3000 Hz)
        low_idx = (f >= 50) & (f <= 400)
        mid_idx = (f > 400) & (f <= 3000)
        low_energy = np.sum(psd[low_idx])
        mid_energy = np.sum(psd[mid_idx])
        low_ratio = low_energy / (low_energy + mid_energy + 1e-12)
        
        m, s = divmod(sec_start, 60)
        h, m = divmod(m, 60)
        time_str = f"{h:02d}:{m:02d}:{s:02d}"
        
        summary.append((sec_start, time_str, rms, sfm, low_ratio))

    print(f"{'Time':<10} {'RMS (dB)':<10} {'Flatness':<12} {'BassRatio':<12}")
    print("-" * 46)
    for row in summary[::6]: # every 1 minute
        sec, t_str, rms, sfm, lr = row
        rms_db = 20 * np.log10(rms + 1e-6)
        print(f"{t_str:<10} {rms_db:<10.1f} {sfm:<12.4f} {lr:<12.4f}")

if __name__ == '__main__':
    wav_path = sys.argv[1] if len(sys.argv) > 1 else r"C:\Users\djtwo\.gemini\antigravity\scratch\audio_16k.wav"
    analyze(wav_path)
