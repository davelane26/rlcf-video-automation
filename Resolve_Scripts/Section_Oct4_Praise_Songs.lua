-- DaVinci Resolve Script: Section_Oct4_Praise_Songs.lua
-- Slices and sections RLCF Praise (October 4, 2026) with official titles, markers, and color coding.

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

-- 6 Songs and in-between speaking sections (excluding pre-service holding screen)
local sections = {
    { start_s = 488.0,  end_s = 577.0,  name = "Welcome & Opening Prayer", is_song = false },
    { start_s = 577.0,  end_s = 754.5,  name = "1. I Praise You for Your Faithfulness", is_song = true },
    { start_s = 754.5,  end_s = 899.0,  name = "Sharing: High Priest, Sacrifice & Advocate", is_song = false },
    { start_s = 899.0,  end_s = 1071.5, name = "2. What a Faithful God Have I", is_song = true },
    { start_s = 1071.5, end_s = 1244.0, name = "Sharing: Seeking the Pearl of Great Price", is_song = false },
    { start_s = 1244.0, end_s = 1495.5, name = "3. Himself (Once It Was the Blessing)", is_song = true },
    { start_s = 1495.5, end_s = 1692.0, name = "4. Knowing You (All I Once Held Dear)", is_song = true },
    { start_s = 1692.0, end_s = 1909.5, name = "5. Christ Is Mine Forevermore", is_song = true },
    { start_s = 1909.5, end_s = 2028.0, name = "Sharing: Surrendering All Daily", is_song = false },
    { start_s = 2028.0, end_s = 2234.0, name = "6. I Surrender All", is_song = true }
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

local timelineName = "RLCF Oct 4 - Praise Set (Sectioned)"
local timeline = mediaPool:CreateEmptyTimeline(timelineName)
if not timeline then
    timelineName = "RLCF Oct 4 - Praise Set " .. os.time()
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
