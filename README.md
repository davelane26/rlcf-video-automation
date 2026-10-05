# RLCF Sunday Livestream Video Automation

Automated video analysis, timeline generation, and YouTube chapter creation for River of Life Christian Fellowship (RLCF) Sunday livestream recordings in **DaVinci Resolve**.

---

## Features
- **Singing & Worship Detection**: Automatically identifies the worship portion of the meeting, cuts out pre-service holding screens and sermons, and preserves all songs and interstitial prayers.
- **Section by Song**: Slices the worship block into individual clips for each song and speaking segment.
- **Color-Coded & Marked**: Color-codes song clips in **Teal** and speaking in **Orange**, and drops **Cyan** markers with the official hymn names.
- **YouTube Chapters**: Generates clickable YouTube video description chapter timestamps.
- **1-Click DaVinci Resolve Integration**: Native Lua scripts placed directly in Resolve's `Workspace -> Scripts -> Edit` menu.

---

## 1-Click Restore on a New PC
If you switch to a new computer or reinstall Windows:
1. Clone this repository (or download the ZIP).
2. Double-click `Install_On_New_PC.bat`.
3. Open DaVinci Resolve and your scripts will be ready under `Workspace -> Scripts -> Edit`!

---

## Included Scripts
- `Resolve_Scripts/Section_July19_Praise_Songs.lua`: Sections July 19 Praise Live into 5 individual songs and speaking segments with markers and colors.
- `Resolve_Scripts/Create_July19_Songs_Only.lua`: Creates a songs-only timeline of July 19 (removes speaking/prayers).
- `Resolve_Scripts/Section_Each_Song_Timeline.lua`: Creates timeline sectioned into each individual song for September 13 with markers and color tags.
- `Resolve_Scripts/Create_Singing_Timeline.lua`: Creates a single continuous timeline of the full singing session.
- `Resolve_Scripts/Create_No_Singing_Timeline.lua`: Cuts out singing and keeps only the sermon and spoken portions.
- `Antigravity_Skill/SKILL.md`: The AI workflow memory and rules for Antigravity.
