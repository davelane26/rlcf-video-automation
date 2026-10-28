---
name: sunday-playlist-sync
description: Automates updating and syncing the RLCF Sunday worship playlist on YouTube. Use whenever the user provides a list of Sunday songs or asks to update, sync, or replace the songs in Sunday's song list.
---

# Sunday Worship Playlist Sync

Automates the process of matching Sunday worship song lists against the RLCF 575+ master livestream recording catalog, clearing out the old set from YouTube, and adding the new songs via the official YouTube Data API v3.

## System Environment & Configuration
- **Auth Directory**: `C:\Users\djtwo\.gemini\config\youtube_auth\`
- **Saved OAuth Token**: `C:\Users\djtwo\.gemini\config\youtube_auth\token.json`
- **Catalog File**: `C:\Users\djtwo\.gemini\antigravity\brain\d7dd5206-254b-4e23-83b0-cb17bc0a5796\scratch\rlcf_master_catalog.json`
- **Sync Pipeline**: `C:\Users\djtwo\.gemini\config\youtube_auth\sync_pipeline.py`

## Target Playlists
1. **Dave Lane Channel Playlist (`@DL-ps5dt`)**: `PLd5XCKe7E24E`
2. **Collaborative Playlist**: `PLDzEX8mCMdiJaYKqE-EvKNZEVcpX42PsW`

## Standard Procedure
Whenever the user provides a new Sunday song list (or asks to update the playlist):
1. Extract the clean song titles.
2. Run the sync pipeline command via `run_command`:
   ```powershell
   python "C:\Users\djtwo\.gemini\config\youtube_auth\sync_pipeline.py" --songs "Song 1" "Song 2" "Song 3" ...
   ```
   - By default, it **automatically clears out old songs** before adding the new set.
   - By default, it **includes all recording dates and duplicate performances** for each song.
   - If the user explicitly asks for only 1 version per song, add `--no-duplicates`.
3. Report back the updated song list and direct links to the playlists.
