-- DaVinci Resolve Script: Create_Oct25_Songs_Only.lua
-- Stitches ONLY the 6 worship songs from October 25 Praise back-to-back (removes speaking/prayers).

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
    if string.find(name, "2026-10-25") or string.find(name, "10-25") or string.find(name, "October 25") or string.find(name, "Praise") then
        targetClip = clip
        break
    end
end

if not targetClip and #clips > 0 then
    targetClip = clips[1]
end

if not targetClip then
    print("Error: No clip found in Media Pool. Please import '2026-10-25 10-18-23 - Praise.mkv' into the Media Pool first.")
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

-- 6 Songs Only
local songs = {
    { start_s = 933.5,  end_s = 1077.5, name = "1. Blessed Be the Lord God Almighty" },
    { start_s = 1077.5, end_s = 1280.5, name = "2. My Worth Is Not in What I Own" },
    { start_s = 1363.5, end_s = 1528.5, name = "3. Abide With Me" },
    { start_s = 1528.5, end_s = 1719.5, name = "4. Abiding in the Lord (Confiding in His Word)" },
    { start_s = 1759.0, end_s = 1931.0, name = "5. How Firm a Foundation" },
    { start_s = 2041.5, end_s = 2309.5, name = "6. Yet Not I But Through Christ in Me" }
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

local timelineName = "RLCF Oct 25 - Songs Only"
local timeline = mediaPool:CreateEmptyTimeline(timelineName)
if not timeline then
    timelineName = "RLCF Oct 25 - Songs Only " .. os.time()
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
    print("SUCCESS: Created '" .. timelineName .. "' with 6 worship songs only!")
end
