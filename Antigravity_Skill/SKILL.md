---
name: rlcf-video-editing
description: Automates processing and editing of RLCF Sunday meeting livestream recordings in DaVinci Resolve. Use when the user wants to process Sunday livestream videos, extract the worship/singing section, section off individual songs, remove singing, or generate YouTube chapter timestamps.
---

# RLCF Sunday Livestream Video Editing Workflow

This skill documents the automated workflow for processing weekly River of Life Christian Fellowship (RLCF) Sunday meeting livestream recordings in DaVinci Resolve.

## 1. System Environment & File Locations
- **OS**: Windows
- **User Downloads Folder**: `C:\Users\djtwo\Downloads`
- **Video Filename Pattern**: `RLCF Sunday Meeting Livestreaming - <Month> <Day>, <Year>.mp4` or `<YYYY-MM-DD> Praise.mkv`
- **Intro / Outro / Logo Asset Directory**:
  `C:\Users\djtwo\OneDrive\Desktop\Intro Outro Logo\`
  - Intro: `RLCF_Intro4k.mp4` (or `RLCF_Intro4k_with_CR.mp4`)
  - Outro: `RLCF_Outro4k.mp4` (or `RLCF_Outro4k_with_CR.mp4`)
  - Logo Watermark: `RLCFLogo_VIdeos.png` (2000x2000 transparent PNG)
- **FFmpeg Path**: `C:\Program Files\Presenter\resources\ffmpeg\ffmpeg.exe` or `ffmpeg`
- **Python**: Python 3.14 with `faster-whisper`, `numpy`, `scipy` installed.
- **DaVinci Resolve Scripts Directory**:
  `C:\Users\djtwo\AppData\Roaming\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Edit\`
- **GitHub Backup Repository**:
  `C:\Users\djtwo\OneDrive\RLCF-Video-Automation-Backup\`

## 2. Standard Service Structure
Every RLCF Sunday Livestream generally follows this structure:
1. **00:00:00 to ~00:04:30**: Pre-stream holding slide / silence.
2. **~00:04:30 to ~00:06:15**: Opening spoken greeting & welcome prayer.
3. **~00:06:15 to ~00:36:15**: **Praise & Worship Set**
   - 5 to 7 worship songs / hymns accompanied by instruments.
   - Spoken prayers, scripture reading, and encouragements between the songs.
4. **~00:36:15**: Worship concludes; silence gap as speaker approaches the pulpit.
5. **~00:36:30 onwards**: Announcements, Sunday school memory verses, main sermon, testimonies, and closing prayer.

## 3. Workflow Procedures

### Step A: Rapid Audio Extraction & Whisper Transcription
Extract 16kHz mono audio from the video:
```powershell
ffmpeg -y -i "$videoPath" -vn -ac 1 -ar 16000 "$scratchDir\audio_16k.wav"
```
Run `faster-whisper` (`tiny.en` on CPU with `int8` or CUDA) over the first 40 minutes (0 to 2400 seconds) to obtain word-level timestamps and locate:
- Opening prayer end / Song 1 start (exact start of singing).
- Each song's start and end boundaries.
- The end of the worship set (exact end of singing, before announcements).

### Step B: DaVinci Resolve Automation (Lua Scripting)
Instead of relying on XML/EDL imports which can run into timecode extent mismatches with MP4s, generate and place a `.lua` script in:
`C:\Users\djtwo\AppData\Roaming\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Edit\`

The script uses Resolve's native scripting API:
1. Grabs the imported video clip from the Media Pool (or auto-imports it).
2. Auto-imports and locates `RLCF_Intro4k.mp4`, `RLCF_Outro4k.mp4`, and `RLCFLogo_VIdeos.png` from `C:\Users\djtwo\OneDrive\Desktop\Intro Outro Logo\`.
3. Determines the clip's `Start TC` offset and `FPS`.
4. Creates the requested timeline (`CreateEmptyTimeline`).
5. Assembles **Video Track 1 (V1/A1)**:
   - `RLCF_Intro4k.mp4` (Navy clip color, Blue marker at 00:00)
   - 12 Worship Sections (Teal clip color for songs, Orange for speaking, Cyan markers for each song)
   - `RLCF_Outro4k.mp4` (Navy clip color, Blue marker at start of outro)
6. Assembles **Video Track 2 (V2)**:
   - Adds Video Track 2 via `timeline:AddTrack("video")`.
   - Appends `RLCFLogo_VIdeos.png` starting at the end of the Intro (`recordFrame = introFrames`).
   - Applies the exact Inspector transform properties via `item:SetProperty()`:
     - `ZoomX`: `0.250`
     - `ZoomY`: `0.250`
     - `ZoomGang`: `true`
     - `Pan`: `1450.000` (Position X)
     - `Tilt`: `470.000` (Position Y)
     - `RotationAngle`: `0.000`
     - `AnchorPointX`: `0.000`
     - `AnchorPointY`: `0.000`
     - `Pitch`: `0.000`
     - `Yaw`: `1.225`

The user runs the script with one click from:
**Workspace -> Scripts -> Edit -> [Script Name]**

### Step C: YouTube Chapters Generation
Whenever generating a timeline for YouTube, calculate relative timestamps starting at `00:00`:
- Format: `MM:SS Song Title`
- First timestamp must start at `00:00`.
- Provide variations:
  - Option A: With Intro (e.g. 7s or 12s intro included)
  - Option B: Full Detail with Sharings and Prayers
  - Option C: Without Intro (direct praise cut starting at 00:00)

### Step D: Standalone Praise / Worship Video Rendering
Always generate the ready-to-upload complete praise & worship video directly in the user's Downloads folder:
- **File Name Pattern:** `C:\Users\djtwo\Downloads\<Date> Praise - Songs Only.mp4`
- **Scope:** The entire worship session from start to finish, including all songs, speaking, scripture sharings, and prayers.
- **Method:** FFmpeg (`libx264`, `-preset veryfast`, `-crf 18`, `-c:a aac -b:a 192k`, `-movflags +faststart`).
