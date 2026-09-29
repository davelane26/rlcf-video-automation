-- DaVinci Resolve Script: Create_July19_Songs_Only.lua
-- Stitches ONLY the 5 worship songs from July 19 Praise Live back-to-back (removes speaking/prayers).

local projectManager = resolve:GetProjectManager()
local project = projectManager:GetCurrentProject()
if not project then
    print("Error: No project open in DaVinci Resolve!")
    return
end

local mediaPool = project:GetMediaPool()
local rootFolder = mediaPool:GetRootFolder()
local clips = rootFolder:GetClipList()

local targetClip = nil
for i, clip in ipairs(clips) do
    local name = clip:GetName()
    if string.find(name, "July 19") or string.find(name, "July") or string.find(name, "Praise") or string.find(name, ".mp4") then
        targetClip = clip
        break
    end
end

if not targetClip and #clips > 0 then
    targetClip = clips[1]
end

if not targetClip then
    print("Error: No clip found in Media Pool. Please import 'RLCF Praise Live — July 19, 2026.mp4' into the Media Pool first.")
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

-- 5 Songs Only
local songs = {
    { start_s = 131.0,  end_s = 319.1,   name = "1. What a Faithful God Have I" },
    { start_s = 374.5,  end_s = 489.5,   name = "2. Why So Downcast, O My Soul" },
    { start_s = 1248.0, end_s = 1496.0,  name = "3. Burn, Fire of God!" },
    { start_s = 1603.5, end_s = 1837.5,  name = "4. Christ Is Mine Forevermore" },
    { start_s = 1837.5, end_s = 2126.34, name = "5. Footprints of Jesus" }
}

local clipInfos = {}
for i, song in ipairs(songs) do
    local s_frame = math.floor(baseFrame + song.start_s * clipFps + 0.5)
    local e_frame = math.floor(baseFrame + song.end_s * clipFps + 0.5)
    table.insert(clipInfos, {
        mediaPoolItem = targetClip,
        startFrame = s_frame,
        endFrame = e_frame
    })
end

local timelineName = "RLCF July 19 - Songs Only"
local timeline = mediaPool:CreateEmptyTimeline(timelineName)
if not timeline then
    timelineName = "RLCF July 19 - Songs Only " .. os.time()
    timeline = mediaPool:CreateEmptyTimeline(timelineName)
end

if timeline then
    project:SetCurrentTimeline(timeline)
    local timelineItems = mediaPool:AppendToTimeline(clipInfos)

    local currentFrameOffset = 0
    for i, song in ipairs(songs) do
        local durFrames = math.floor((song.end_s - song.start_s) * clipFps + 0.5)
        
        timeline:AddMarker(currentFrameOffset, "Cyan", song.name, "", durFrames, "")

        if timelineItems and timelineItems[i] then
            pcall(function()
                timelineItems[i]:SetClipColor("Teal")
            end)
        end

        currentFrameOffset = currentFrameOffset + durFrames
    end
    print("SUCCESS: Created '" .. timelineName .. "' with 5 worship songs only!")
end
