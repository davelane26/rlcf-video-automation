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

echo [3/3] Installing Antigravity Custom Skill...
if not exist "%SKILL_DIR%" mkdir "%SKILL_DIR%"
copy /Y "%~dp0Antigravity_Skill\SKILL.md" "%SKILL_DIR%\"

echo.
echo ===================================================
echo   RESTORE COMPLETE!
echo   All scripts and skills are installed on this PC.
echo ===================================================
pause
