@echo off
echo ===================================================
echo   RLCF Video Automation - New PC Restore Script
echo ===================================================
echo.

set RESOLVE_DIR=%APPDATA%\Blackmagic Design\DaVinci Resolve\Support\Fusion\Scripts\Edit
set SKILL_DIR=%USERPROFILE%\.gemini\config\skills\rlcf-video-editing

echo [1/3] Creating DaVinci Resolve Scripts directories...
if not exist "%RESOLVE_DIR%" mkdir "%RESOLVE_DIR%"

echo [2/3] Installing DaVinci Resolve Lua Scripts...
copy /Y "%~dp0Resolve_Scripts\*.lua" "%RESOLVE_DIR%\"

echo [3/4] Installing Antigravity Custom Skill...
if not exist "%SKILL_DIR%" mkdir "%SKILL_DIR%"
copy /Y "%~dp0Antigravity_Skill\SKILL.md" "%SKILL_DIR%\"

echo [4/4] Restoring Antigravity Chat Session & Transcripts...
set BRAIN_DIR=%USERPROFILE%\.gemini\antigravity\brain\56930dde-d49e-4d64-b3a0-ddf3ad4cb3e8
if not exist "%BRAIN_DIR%" mkdir "%BRAIN_DIR%"
xcopy /E /I /Y "%~dp0Session_Backup\*" "%BRAIN_DIR%\" >nul

echo.
echo ===================================================
echo   RESTORE COMPLETE!
echo   All scripts, skills, and session files are installed!
echo ===================================================
pause
