# RLCF Sunday Meeting Automation Suite

Automated tools for River of Life Christian Fellowship (RLCF) Sunday meetings:
1. **Sunday Worship Playlist Sync**: Matches songs against the 575+ livestream recording catalog, clears old songs, and updates YouTube playlists via official Google APIs.
2. **DaVinci Resolve Video Editing**: Automatic audio transcription, singing/worship detection, timeline generation, and YouTube chapters.

---

## 1-Click Restore on Any PC
If you get a new computer, laptop, or reinstall Windows:
1. Make sure OneDrive is synced.
2. Double-click **`Install_On_New_PC.bat`**.
3. **Done!**
   - Your YouTube credentials and 575-song catalog are restored.
   - Antigravity's **`sunday-playlist-sync`** and **`rlcf-video-editing`** skills are instantly enabled.
   - All DaVinci Resolve scripts are placed into Resolve's script menu.

---

## What's Backed Up Here:
- `Playlist_Sync/`: YouTube OAuth token (`token.json`), client secrets, master song catalog, and sync engine.
- `Antigravity_Skill_Playlist/`: Antigravity skill definition for Sunday playlist synchronization.
- `Antigravity_Skill/`: Antigravity skill definition for livestream video editing.
- `Resolve_Scripts/`: DaVinci Resolve Lua scripts for sectioning praise songs and timelines.
