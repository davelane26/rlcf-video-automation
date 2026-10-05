-- DaVinci Resolve Script: Create_No_Singing_Timeline.lua
-- This script automatically finds your RLCF video in the Media Pool,
-- cuts out all 6 singing sections, and creates the edited timeline.

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
    print("Using first clip in Media Pool: " .. targetClip:GetName())
end

if not targetClip then
    print("Error: No clip found in Media Pool. Please import the video first.")
    return
end

-- Check clip FPS and Start Frame
local clipFps = 30.0
local fpsProp = targetClip:GetClipProperty("FPS")
if fpsProp and tonumber(fpsProp) then
    clipFps = tonumber(fpsProp)
end

-- Get Clip Start Frame from Start TC
local startTC = targetClip:GetClipProperty("Start TC")
print("Clip Start TC: " .. tostring(startTC))

local baseFrame = 0
if startTC and startTC ~= "" then
    local h, m, s, f = string.match(startTC, "(%d+):(%d+):(%d+):(%d+)")
    if h and m and s and f then
        baseFrame = tonumber(h) * 3600 * clipFps + tonumber(m) * 60 * clipFps + tonumber(s) * clipFps + tonumber(f)
    end
end
print("Base Frame Offset: " .. tostring(baseFrame))

-- Spoken segments to keep (in seconds from video start)
local keep_segments_sec = {
    { start_s = 280.0, end_s = 378.0, desc = "Opening Welcome and Prayer" },
    { start_s = 527.0, end_s = 563.0, desc = "Sharing 1 Power of Christ Risen" },
    { start_s = 760.0, end_s = 1431.0, desc = "Prayer and Sharing 2 Intercession" },
    { start_s = 1665.0, end_s = 1688.0, desc = "Sharing 3 Life of Christ" },
    { start_s = 1799.0, end_s = 1810.0, desc = "Sharing 4 Christ in Saints" },
    { start_s = 1940.0, end_s = 2002.0, desc = "Sharing 5 Forgiveness and Pit" },
    { start_s = 2172.0, end_s = 7125.0, desc = "Welcome Announcements Sermon" }
}

local clipInfos = {}
for i, seg in ipairs(keep_segments_sec) do
    local s_frame = math.floor(baseFrame + seg.start_s * clipFps + 0.5)
    local e_frame = math.floor(baseFrame + seg.end_s * clipFps + 0.5)
    table.insert(clipInfos, {
        mediaPoolItem = targetClip,
        startFrame = s_frame,
        endFrame = e_frame
    })
    print(string.format("Segment %d: %s [%d -> %d]", i, seg.desc, s_frame, e_frame))
end

-- Create Timeline
local timelineName = "RLCF Sunday - No Singing"
local newTimeline = mediaPool:CreateEmptyTimeline(timelineName)
if not newTimeline then
    timelineName = "RLCF Sunday - No Singing " .. os.time()
    newTimeline = mediaPool:CreateEmptyTimeline(timelineName)
end

if newTimeline then
    project:SetCurrentTimeline(newTimeline)
    mediaPool:AppendToTimeline(clipInfos)
    print("SUCCESS! Created timeline: " .. timelineName)
else
    print("Trying CreateTimelineFromClips...")
    newTimeline = mediaPool:CreateTimelineFromClips(timelineName, clipInfos)
    if newTimeline then
        print("SUCCESS! Created timeline: " .. timelineName)
    else
        print("Failed to create timeline.")
    end
end
