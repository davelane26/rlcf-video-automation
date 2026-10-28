@echo off
echo ===================================================
echo   RLCF Automation Suite - New PC Restore Script
echo ===================================================
echo.

set RESOLVE_DIR=%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Edit
set VIDEO_SKILL_DIR=%USERPROFILE%\.gemini\config\skills\rlcf-video-editing
set PLAYLIST_SKILL_DIR=%USERPROFILE%\.gemini\config\skills\sunday-playlist-sync
set YOUTUBE_AUTH_DIR=%USERPROFILE%\.gemini\config\youtube_auth

echo [1/5] Installing DaVinci Resolve Lua Scripts...
if not exist "%RESOLVE_DIR%" mkdir "%RESOLVE_DIR%"
copy /Y "%~dp0Resolve_Scripts\*.lua" "%RESOLVE_DIR%\" >nul

echo [2/5] Installing Antigravity Video Editing Skill...
if not exist "%VIDEO_SKILL_DIR%" mkdir "%VIDEO_SKILL_DIR%"
copy /Y "%~dp0Antigravity_Skill\SKILL.md" "%VIDEO_SKILL_DIR%\" >nul

echo [3/5] Installing Antigravity Sunday Playlist Sync Skill...
if not exist "%PLAYLIST_SKILL_DIR%" mkdir "%PLAYLIST_SKILL_DIR%"
copy /Y "%~dp0Antigravity_Skill_Playlist\SKILL.md" "%PLAYLIST_SKILL_DIR%\" >nul

echo [4/5] Restoring YouTube Authentication & Sync Engine...
if not exist "%YOUTUBE_AUTH_DIR%" mkdir "%YOUTUBE_AUTH_DIR%"
copy /Y "%~dp0Playlist_Sync\*" "%YOUTUBE_AUTH_DIR%\" >nul

echo [5/5] Checking Python Dependencies...
python -m pip install -q google-auth-oauthlib google-api-python-client yt-dlp

echo.
echo ===================================================
echo   RESTORE COMPLETE!
echo   - Video editing scripts installed in DaVinci Resolve
echo   - Sunday Playlist Sync installed in Antigravity
echo   - YouTube OAuth credentials restored
echo ===================================================
pause
