# RLCF Sunday Meeting Automation Suite

Automated tools for River of Life Christian Fellowship (RLCF) Sunday meetings:
1. **DaVinci Resolve Video Editing & Standalone Worship MP4 Workflow**: Automatic audio transcription, singing/worship detection, sub-second boundary analysis, 1-click DaVinci Resolve timeline generation, standalone full-worship MP4 rendering, and YouTube chapters.
2. **Sunday Worship Playlist Sync**: Matches songs against the 575+ livestream recording catalog, clears old songs, and updates YouTube playlists via official Google APIs.

---

## Using This Workflow With ANY AI Agent (Claude Code, Cursor, Windsurf, ChatGPT/Codex, Copilot, Cline)
If you want to share this workflow with someone using a different AI agent:
- Have them clone or download this repo (or just download **[RLCF_Video_Workflow_For_Any_AI_Agent.md](RLCF_Video_Workflow_For_Any_AI_Agent.md)**).
- This repo also includes **`CLAUDE.md`** and **`AGENTS.md`** in the root folder so Claude Code, Cursor, Windsurf, and OpenAI Codex automatically pick up the instructions as soon as they open the folder!

---

## 1-Click Restore on Any PC (Antigravity)
If you get a new computer, laptop, or reinstall Windows:
1. Make sure OneDrive is synced (or clone this repo).
2. Double-click **`Install_On_New_PC.bat`**.
3. **Done!**
   - Your 575-song catalog and sync scripts are restored.
   - Antigravity's **`sunday-playlist-sync`** and **`rlcf-video-editing`** skills are instantly enabled.
   - All DaVinci Resolve scripts are placed into Resolve's script menu.

---

## What's Included in This Repository:
- **`RLCF_Video_Workflow_For_Any_AI_Agent.md`** (plus **`AGENTS.md`** and **`CLAUDE.md`**): Complete portable guide & code templates for any AI agent to run the entire Sunday video workflow from scratch.
- **`Antigravity_Skill/`**: Antigravity skill definition for livestream video editing.
- **`Antigravity_Skill_Playlist/`**: Antigravity skill definition for Sunday playlist synchronization.
- **`Resolve_Scripts/`**: DaVinci Resolve Lua scripts for sectioning praise songs and timelines.
- **`Playlist_Sync/`**: Master song catalog (`rlcf_master_catalog.json`) and YouTube playlist sync scripts.

---

# Full Universal AI Agent Workflow Guide

> **How to use this with ANY AI Agent:**
> Give this guide to your AI agent and say:
> *"Follow this workflow guide whenever I ask you to process a Sunday praise/livestream video."*

## 1. Prerequisites (One-Time Setup)
Ensure the computer has:
1. **FFmpeg** installed and available in PATH (`winget install Gyan.FFmpeg` on Windows or `brew install ffmpeg` on Mac).
2. **Python 3.10+** with the following packages installed:
   ```bash
   pip install faster-whisper numpy
   ```
3. **DaVinci Resolve** (Free or Studio).
   - **Windows Resolve Edit Scripts Path:** `%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Edit\`
   - **macOS Resolve Edit Scripts Path:** `~/Library/Application Support/Blackmagic Design/DaVinci Resolve/Fusion/Scripts/Edit/`

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

*(See [RLCF_Video_Workflow_For_Any_AI_Agent.md](RLCF_Video_Workflow_For_Any_AI_Agent.md) for the complete Python & Lua code templates.)*
