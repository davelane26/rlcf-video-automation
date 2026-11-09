# Universal AI Agent Guide: RLCF Sunday Worship Video & DaVinci Resolve Workflow

> **How to use this file with ANY AI Agent (Claude Code, Cursor, Windsurf, ChatGPT/Codex, GitHub Copilot, Cline, etc.):**
> Give this file to your AI agent (or paste it into the chat / add it to `.cursorrules`, `CLAUDE.md`, or `AGENTS.md`) and say:
> *"Follow this workflow guide whenever I ask you to process a Sunday praise/livestream video."*

---

## 1. Prerequisites (One-Time Setup)
Ensure the computer has:
1. **FFmpeg** installed and available in PATH (or via Winget: `winget install Gyan.FFmpeg`).
2. **Python 3.10+** with the following packages installed:
   ```bash
   pip install faster-whisper numpy
   ```
3. **DaVinci Resolve** (Free or Studio).
   - **Windows Resolve Edit Scripts Path:** `%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Edit\`
   - **macOS Resolve Edit Scripts Path:** `~/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Edit/`

---

## 2. Standard Deliverables Every Week
Whenever the user provides a Sunday livestream or praise recording (`.mkv`, `.mp4`, `.mov`, etc.), the AI agent must produce **4 deliverables**:

1. **Exact Song & Segment Identification**: Identify all worship songs (usually 5–6 songs/hymns) and all speaking/prayer/scripture segments with sub-second accuracy (`0.25s` precision).
2. **DaVinci Resolve 1-Click Lua Scripts**:
   - `Section_<Date>_Praise_Songs.lua`: Slices the full worship set into individual songs (colored **Teal** with **Cyan** markers) and speaking/prayer clips (colored **Orange**).
   - `Create_<Date>_Songs_Only.lua`: Stitches **only** the worship songs back-to-back.
3. **Standalone Continuous Worship Video (`.mp4` in `Downloads`)**:
   - Render the **entire continuous worship session from start to finish** (including the songs, talking, scripture readings, and prayers in between), trimming out only the pre-service holding screen at the beginning and the post-worship announcements/memory verses/sermon at the end.
   - Output path: `~/Downloads/<YYYY-MM-DD> Praise - Songs Only.mp4`.
4. **Ready-to-Paste YouTube Chapter Timestamps**:
   - Relative to `00:00` of the exported video.
   - Provide **Option 1 (Song Titles Only)** and **Option 2 (Full Chapters including Speaking/Prayers)**.

---

## 3. Step-by-Step Technical Procedure for the AI Agent

### Step 1: Extract 16kHz Mono WAV Audio
Extract a lightweight 16kHz mono WAV file so transcription and RMS energy analysis run fast:
```bash
ffmpeg -y -i "<INPUT_VIDEO_PATH>" -vn -ac 1 -ar 16000 -c:a pcm_s16le "audio_16k.wav"
```

### Step 2: Two-Pass Transcription & RMS Energy Analysis
> **CRITICAL MEMORY RULE:** Never pass a full 50-minute WAV array into `faster-whisper` all at once (it can trigger a NumPy `ArrayMemoryError` allocating >1 GiB for STFT). Always slice the audio into **300-second (5-minute) chunks**.

Run this Python script to get:
1. The **5-second RMS energy profile** (singing with instruments has high RMS `~0.12–0.22`; speaking/prayer has low RMS `~0.02–0.06`; silence is `<0.005`).
2. Full transcription (`vad_filter=False` on music windows so Whisper doesn't skip singing).

```python
import wave
import numpy as np
from faster_whisper import WhisperModel

wav_path = "audio_16k.wav"
with wave.open(wav_path, "rb") as wf:
    sr = wf.getframerate()
    raw = wf.readframes(wf.getnframes())
    audio = np.frombuffer(raw, dtype=np.int16).astype(np.float32) / 32768.0

duration_s = len(audio) / sr
print(f"Loaded {duration_s:.1f}s ({duration_s/60:.2f} mins)")

# 1. Print 5-second RMS profile to visually spot high-energy singing blocks vs low-energy speaking
print("=== RMS Energy Profile ===")
for t in range(0, int(duration_s), 5):
    chunk = audio[t*sr:(t+5)*sr]
    rms = np.sqrt(np.mean(chunk**2)) if len(chunk) > 0 else 0
    m, s = divmod(t, 60)
    bar = "#" * int(rms * 300)
    print(f"{m:02d}:{s:02d} ({t:4d}s) | RMS: {rms:.4f} | {bar}")

# 2. Transcribe in 300s (5-min) chunks with vad_filter=False so singing lyrics are captured
model = WhisperModel("tiny.en", device="cpu", compute_type="int8")
chunk_len = 300
for start_s in range(0, int(duration_s), chunk_len):
    end_s = min(int(duration_s), start_s + chunk_len)
    print(f"\n--- Transcribing {start_s//60}m:{start_s%60:02d} to {end_s//60}m:{end_s%60:02d} ---")
    sub = audio[start_s*sr:end_s*sr]
    segments, _ = model.transcribe(sub, beam_size=5, vad_filter=False, condition_on_previous_text=False)
    for seg in segments:
        abs_s = start_s + seg.start
        abs_e = start_s + seg.end
        m1, s1 = divmod(abs_s, 60)
        m2, s2 = divmod(abs_e, 60)
        print(f"[{int(m1):02d}:{s1:05.2f} -> {int(m2):02d}:{s2:05.2f}] ({abs_s:.2f}s -> {abs_e:.2f}s) {seg.text.strip()}")
```

### Step 3: Pinpoint Exact 0.25-Second Boundaries
Once you identify the rough transition windows between speaking and singing (from the RMS jump and lyrics), run a `0.25s` fine-grained RMS check over each 15-second transition window:
```python
step = 0.25
for title, s_sec, e_sec in transitions:
    print(f"\n=== {title} ===")
    t = float(s_sec)
    while t < e_sec:
        chunk = audio[int(t*sr):int((t+step)*sr)]
        rms = np.sqrt(np.mean(chunk**2)) if len(chunk) > 0 else 0
        m, s = divmod(t, 60)
        print(f"{int(m):02d}:{s:05.2f} ({t:7.2f}s) | {rms:.4f} | {'#' * int(rms * 250)}")
        t += step
```
- **Song Start Boundary**: Pick `0.5s` before the first guitar/piano intro chord strikes (`RMS` jumps from `<0.01` to `>0.04`).
- **Song End Boundary**: Pick `0.5s–1.0s` after the final chord decays, right before the speaker starts talking (`RMS` drops before speech resumes).

---

### Step 4: Generate DaVinci Resolve 1-Click Lua Scripts
Save both `.lua` scripts into the DaVinci Resolve `Edit` scripts directory (`%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Edit\`).

#### Template A: `Section_<Date>_Praise_Songs.lua` (Full Sectioned Worship Timeline)
```lua
-- DaVinci Resolve Script: Section_<Date>_Praise_Songs.lua
local projectManager = resolve:GetProjectManager()
local project = projectManager:GetCurrentProject()
if not project then
    print("Error: No project open in DaVinci Resolve!")
    return
end

local mediaPool = project:GetMediaPool()
local rootFolder = mediaPool:GetRootFolder()
local clips = rootFolder:GetClipList()

local targetClip = nil
for i, clip in ipairs(clips) do
    local name = clip:GetName()
    if string.find(name, "Praise") or string.find(name, "2026") then
        targetClip = clip
        break
    end
end
if not targetClip and #clips > 0 then targetClip = clips[1] end
if not targetClip then
    print("Error: No clip found in Media Pool. Please import the video into the Media Pool first.")
    return
end

local clipFps = tonumber(targetClip:GetClipProperty("FPS")) or 30.0
local startTC = targetClip:GetClipProperty("Start TC")
local baseFrame = 0
if startTC and startTC ~= "" then
    local h, m, s, f = string.match(startTC, "(%d+):(%d+):(%d+):(%d+)")
    if h and m and s and f then
        baseFrame = tonumber(h) * 3600 * clipFps + tonumber(m) * 60 * clipFps + tonumber(s) * clipFps + tonumber(f)
    end
end

-- Replace with the exact sub-second timestamps for this Sunday:
local sections = {
    { start_s = 699.5,  end_s = 933.5,  name = "Opening Scripture & Prayer", is_song = false },
    { start_s = 933.5,  end_s = 1077.5, name = "1. Song Title One", is_song = true },
    { start_s = 1077.5, end_s = 1280.5, name = "2. Song Title Two", is_song = true },
    { start_s = 1280.5, end_s = 1363.5, name = "Sharing & Prayer", is_song = false },
    -- Add remaining songs and speaking segments...
}

local clipInfos = {}
for i, sec in ipairs(sections) do
    table.insert(clipInfos, {
        mediaPoolItem = targetClip,
        startFrame = math.floor(baseFrame + sec.start_s * clipFps + 0.5),
        endFrame   = math.floor(baseFrame + sec.end_s * clipFps + 0.5)
    })
end

local timelineName = "RLCF Praise Set (Sectioned)"
local timeline = mediaPool:CreateEmptyTimeline(timelineName) or mediaPool:CreateEmptyTimeline(timelineName .. " " .. os.time())

if timeline then
    project:SetCurrentTimeline(timeline)
    local timelineItems = mediaPool:AppendToTimeline(clipInfos)
    local currentFrameOffset = 0
    for i, sec in ipairs(sections) do
        local durFrames = math.floor((sec.end_s - sec.start_s) * clipFps + 0.5)
        if sec.is_song then
            timeline:AddMarker(currentFrameOffset, "Cyan", sec.name, "", durFrames, "")
        end
        if timelineItems and timelineItems[i] then
            pcall(function()
                timelineItems[i]:SetClipColor(sec.is_song and "Teal" or "Orange")
            end)
        end
        currentFrameOffset = currentFrameOffset + durFrames
    end
    print("SUCCESS: Created '" .. timelineName .. "'!")
end
```

---

### Step 5: Render Standalone Continuous Worship MP4 (or Individual Song MP4s)
Use FFmpeg with `libx264 -preset veryfast -crf 18` to render the continuous worship block (from start of worship to end of the final song, including all talking/praying in between):
```bash
ffmpeg -y -ss <WORSHIP_START_SEC> -to <WORSHIP_END_SEC> -i "<INPUT_VIDEO_PATH>" -c:v libx264 -preset veryfast -crf 18 -c:a aac -b:a 192k -movflags +faststart "<DOWNLOADS_DIR>/<YYYY-MM-DD> Praise - Songs Only.mp4"
```
*(If the user asks for a single standalone song video, e.g., `"give me How Firm a Foundation"`, run the exact same command using that song's `start_s` and `end_s`!)*

---

### Step 6: Recalculating YouTube Timestamps for a User-Exported Video
If the user exports their own custom edit from DaVinci Resolve (e.g., `20261025-RLCFPraiseLive.mp4`) and says *"redo the timestamps for this file"*:
1. Extract 16kHz mono WAV from the user's exported `.mp4`.
2. Cross-correlate `50ms` RMS envelopes from the user's export against the original recording's WAV (`audio_16k.wav`) to find the exact time offset (and check if any middle sections were trimmed).
3. Subtract the offset from each song's original timestamp (clamping the first chapter to `00:00`) and output the new YouTube chapters.
