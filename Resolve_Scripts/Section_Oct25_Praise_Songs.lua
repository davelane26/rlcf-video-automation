-- DaVinci Resolve Script: Section_Oct25_Praise_Songs.lua
-- Slices and sections RLCF Praise (October 25, 2026) with official titles, markers, and color coding.

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

-- 6 Songs and in-between speaking sections (excluding pre-service holding screen and post-worship announcements)
local sections = {
    { start_s = 699.5,  end_s = 933.5,  name = "Opening Scripture (Psalm 103) & Prayer", is_song = false },
    { start_s = 933.5,  end_s = 1077.5, name = "1. Blessed Be the Lord God Almighty", is_song = true },
    { start_s = 1077.5, end_s = 1280.5, name = "2. My Worth Is Not in What I Own", is_song = true },
    { start_s = 1280.5, end_s = 1363.5, name = "Sharing: Abiding in the Vine (John 15 & 1 John 3)", is_song = false },
    { start_s = 1363.5, end_s = 1528.5, name = "3. Abide With Me", is_song = true },
    { start_s = 1528.5, end_s = 1719.5, name = "4. Abiding in the Lord (Confiding in His Word)", is_song = true },
    { start_s = 1719.5, end_s = 1759.0, name = "Sharing: Reading the Hymn Lyrics", is_song = false },
    { start_s = 1759.0, end_s = 1931.0, name = "5. How Firm a Foundation", is_song = true },
    { start_s = 1931.0, end_s = 2041.5, name = "Prayer & Exhortation: Seated at the Lord's Table", is_song = false },
    { start_s = 2041.5, end_s = 2309.5, name = "6. Yet Not I But Through Christ in Me", is_song = true }
}

local clipInfos = {}
for i, sec in ipairs(sections) do
    local s_frame = math.floor(baseFrame + sec.start_s * clipFps + 0.5)
    local e_frame = math.floor(baseFrame + sec.end_s * clipFps + 0.5)
    table.insert(clipInfos, {
        mediaPoolItem = targetClip,
        startFrame = s_frame,
        endFrame = e_frame
    })
end

local timelineName = "RLCF Oct 25 - Praise Set (Sectioned)"
local timeline = mediaPool:CreateEmptyTimeline(timelineName)
if not timeline then
    timelineName = "RLCF Oct 25 - Praise Set " .. os.time()
    timeline = mediaPool:CreateEmptyTimeline(timelineName)
end

if timeline then
    project:SetCurrentTimeline(timeline)
    local timelineItems = mediaPool:AppendToTimeline(clipInfos)

    local currentFrameOffset = 0
    for i, sec in ipairs(sections) do
        local durFrames = math.floor((sec.end_s - sec.start_s) * clipFps + 0.5)
        
        if sec.is_song then
            timeline:AddMarker(currentFrameOffset, "Cyan", sec.name, "", durFrames, "")
        end

        if timelineItems and timelineItems[i] then
            pcall(function()
                if sec.is_song then
                    timelineItems[i]:SetClipColor("Teal")
                else
                    timelineItems[i]:SetClipColor("Orange")
                end
            end)
        end

        currentFrameOffset = currentFrameOffset + durFrames
    end
    print("SUCCESS: Created '" .. timelineName .. "' with 6 songs sectioned & color coded!")
end
