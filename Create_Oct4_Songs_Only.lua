-- DaVinci Resolve Script: Create_Oct4_Songs_Only.lua
-- Stitches ONLY the 6 worship songs from October 4 Praise back-to-back (removes speaking/prayers).

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
    if string.find(name, "2026-10-04") or string.find(name, "10-04") or string.find(name, "October 4") or string.find(name, "Praise") then
        targetClip = clip
        break
    end
end

if not targetClip and #clips > 0 then
    targetClip = clips[1]
end

if not targetClip then
    print("Error: No clip found in Media Pool. Please import '2026-10-04 Praise.mkv' into the Media Pool first.")
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
    { start_s = 577.0,  end_s = 754.5,  name = "1. I Praise You for Your Faithfulness" },
    { start_s = 899.0,  end_s = 1071.5, name = "2. What a Faithful God Have I" },
    { start_s = 1244.0, end_s = 1495.5, name = "3. Himself (Once It Was the Blessing)" },
    { start_s = 1495.5, end_s = 1692.0, name = "4. Knowing You (All I Once Held Dear)" },
    { start_s = 1692.0, end_s = 1909.5, name = "5. Christ Is Mine Forevermore" },
    { start_s = 2028.0, end_s = 2234.0, name = "6. I Surrender All" }
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

local timelineName = "RLCF Oct 4 - Songs Only"
local timeline = mediaPool:CreateEmptyTimeline(timelineName)
if not timeline then
    timelineName = "RLCF Oct 4 - Songs Only " .. os.time()
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
