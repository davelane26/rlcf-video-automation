---
name: rlcf-video-editing
description: Automates processing and editing of RLCF Sunday meeting livestream recordings in DaVinci Resolve. Use when the user wants to process Sunday livestream videos, extract the worship/singing section, section off individual songs, remove singing, or generate YouTube chapter timestamps.
---

# RLCF Sunday Livestream Video Editing Workflow

This skill documents the automated workflow for processing weekly River of Life Christian Fellowship (RLCF) Sunday meeting livestream recordings in DaVinci Resolve.

## 1. System Environment & File Locations
- **OS**: Windows
- **User Downloads Folder**: `C:\Users\djtwo\Downloads`
- **Video Filename Pattern**: `RLCF Sunday Meeting Livestreaming - <Month> <Day>, <Year>.mp4`
- **FFmpeg Path**: `C:\Program Files\Presenter\resources\ffmpeg\ffmpeg.exe`
- **Python**: Python 3.14 with `faster-whisper`, `numpy`, `scipy` installed.
- **DaVinci Resolve Scripts Directory**:
  `C:\Users\djtwo\AppData\Roaming\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Edit\`

## 2. Standard Service Structure
Every RLCF Sunday Livestream generally follows this structure:
1. **00:00:00 to ~00:04:30**: Pre-stream holding slide / silence.
2. **~00:04:30 to ~00:06:15**: Opening spoken greeting & welcome prayer.
3. **~00:06:15 to ~00:36:15**: **Praise & Worship Set**
   - 5 or 6 worship songs / hymns accompanied by instruments.
   - Spoken prayers, scripture reading, and encouragements between the songs.
4. **~00:36:15**: Worship concludes; silence gap as speaker approaches the pulpit.
5. **~00:36:30 onwards**: Announcements, Sunday school memory verses, main sermon, testimonies, and closing prayer.

## 3. Workflow Procedures

### Step A: Rapid Audio Extraction & Whisper Transcription
Extract 16kHz mono audio from the video:
```powershell
& "C:\Program Files\Presenter\resources\ffmpeg\ffmpeg.exe" -y -i "$videoPath" -vn -ac 1 -ar 16000 "$scratchDir\audio_16k.wav"
```
Run `faster-whisper` (`tiny.en` on CPU with `int8` or CUDA) over the first 40 minutes (0 to 2400 seconds) to obtain word-level timestamps and locate:
- Opening prayer end / Song 1 start (exact start of singing).
- Each song's start and end boundaries.
- The end of the worship set (exact end of singing, before announcements).

### Step B: DaVinci Resolve Automation (Lua Scripting)
Instead of relying on XML/EDL imports which can run into timecode extent mismatches with MP4s, generate and place a `.lua` script in:
`C:\Users\djtwo\AppData\Roaming\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Edit\`

The script uses Resolve's native scripting API:
1. Grabs the imported video clip from the Media Pool.
2. Determines the clip's `Start TC` offset and `FPS`.
3. Creates the requested timeline (`CreateEmptyTimeline`).
4. Uses `mediaPool:AppendToTimeline(clipInfos)` with exact `startFrame` and `endFrame` ranges.
5. Applies timeline markers with song titles (`timeline:AddMarker`) and color codes clips (Teal for songs, Orange for speaking).

The user runs the script with one click from:
**Workspace -> Scripts -> Edit -> [Script Name]**

### Step C: YouTube Chapters Generation
Whenever generating a timeline for YouTube, calculate relative timestamps starting at `00:00`:
- Format: `MM:SS Song Title`
- First timestamp must start at `00:00`.
- At least 3 timestamps in ascending order.
Provide both:
- Option A: Songs Only (e.g. `00:00 Song 1...`)
- Option B: Full Detail (Songs + Spoken Sharings)

### Step D: Automatic Standalone Praise / Worship Video Rendering
Always generate the ready-to-upload complete praise & worship video directly in the user's Downloads folder:
- **File Name Pattern:** `C:\Users\djtwo\Downloads\<Date> Praise - Songs Only.mp4`
- **Scope:** The entire worship session from start to finish, including all songs, speaking, scripture sharings, and prayers (from the opening greeting/prayer through the final song's decay). Trims out only the pre-stream prelude screen at the beginning and the pulpit sermon/announcements at the end.
- **Method:** Use FFmpeg (`libx264`, `-preset veryfast`, `-crf 18`, `-c:a aac -b:a 192k`, `-movflags +faststart`).
- **Result:** Provides an immediate 1080p Full HD video ready for YouTube upload without requiring manual export from DaVinci Resolve.
