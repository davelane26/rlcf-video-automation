-- DaVinci Resolve Script: Create_Singing_Timeline.lua
-- This script creates a timeline containing the EXACT singing section:
-- Starts when singing begins (00:06:18), ends when singing stops (00:36:13),
-- keeping everything in between (songs + talking between songs).
-- Cuts out the pre-stream at the start and the sermon/service at the end.

local projectManager = resolve:GetProjectManager()
local project = projectManager:GetCurrentProject()
if not project then
    print("No project open!")
    return
end

local mediaPool = project:GetMediaPool()
local rootFolder = mediaPool:GetRootFolder()
local clips = rootFolder:GetClipList()

-- Find the video clip in the Media Pool
local targetClip = nil
for i, clip in ipairs(clips) do
    local name = clip:GetName()
    if string.find(name, "RLCF") or string.find(name, "September 13") or string.find(name, ".mp4") then
        targetClip = clip
        print("Found matching clip: " .. name)
        break
    end
end

if not targetClip and #clips > 0 then
    targetClip = clips[1]
end

if not targetClip then
    print("Error: No clip found in Media Pool.")
    return
end

local clipFps = 30.0
local fpsProp = targetClip:GetClipProperty("FPS")
if fpsProp and tonumber(fpsProp) then
    clipFps = tonumber(fpsProp)
end

local startTC = targetClip:GetClipProperty("Start TC")
local baseFrame = 0
if startTC and startTC ~= "" then
    local h, m, s, f = string.match(startTC, "(%d+):(%d+):(%d+):(%d+)")
    if h and m and s and f then
        baseFrame = tonumber(h) * 3600 * clipFps + tonumber(m) * 60 * clipFps + tonumber(s) * clipFps + tonumber(f)
    end
end

-- EXACT BOUNDARIES:
-- Singing starts: 00:06:18 (378.0s)
-- Singing ends:   00:36:13 (2173.0s)
-- Everything in between is KEPT intact as one continuous clip!
local start_s = 378.0
local end_s = 2173.0

local s_frame = math.floor(baseFrame + start_s * clipFps + 0.5)
local e_frame = math.floor(baseFrame + end_s * clipFps + 0.5)

local clipInfo = {
    {
        mediaPoolItem = targetClip,
        startFrame = s_frame,
        endFrame = e_frame
    }
}

local timelineName = "RLCF Sunday - Singing and In-Between"
local newTimeline = mediaPool:CreateEmptyTimeline(timelineName)
if not newTimeline then
    timelineName = "RLCF Sunday - Singing and In-Between " .. os.time()
    newTimeline = mediaPool:CreateEmptyTimeline(timelineName)
end

if newTimeline then
    project:SetCurrentTimeline(newTimeline)
    mediaPool:AppendToTimeline(clipInfo)
    print("SUCCESS! Created timeline: " .. timelineName)
else
    newTimeline = mediaPool:CreateTimelineFromClips(timelineName, clipInfo)
    if newTimeline then
        print("SUCCESS! Created timeline: " .. timelineName)
    end
end
