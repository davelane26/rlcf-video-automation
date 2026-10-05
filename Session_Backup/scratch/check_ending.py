import sys
import time
from faster_whisper import WhisperModel

def run():
    print("Loading tiny.en model on CPU...", flush=True)
    model = WhisperModel("tiny.en", device="cpu", compute_type="int8")

    audio_path = r"C:\Users\djtwo\.gemini\antigravity\scratch\audio_16k.wav"
    out_file = r"C:\Users\djtwo\.gemini\antigravity\scratch\whisper_ending.txt"

    print("Transcribing from 1h 40m to end...", flush=True)
    
    # We can pass an audio slice or transcribe starting from 6000s (1h40m)
    # With faster-whisper we can pass a wav file or ffmpeg segment
