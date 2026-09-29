-- DaVinci Resolve Script: Section_July19_Praise_Songs.lua
-- Slices and sections RLCF Praise Live (July 19, 2026) with official titles, markers, and color coding.

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

-- 5 Songs and in-between speaking sections
local sections = {
    { start_s = 0.0,    end_s = 131.0,   name = "Opening Prayer", is_song = false },
    { start_s = 131.0,  end_s = 319.1,   name = "1. What a Faithful God Have I", is_song = true },
    { start_s = 319.1,  end_s = 374.5,   name = "Sharing: Encourage Yourself in the Lord", is_song = false },
    { start_s = 374.5,  end_s = 489.5,   name = "2. Why So Downcast, O My Soul", is_song = true },
    { start_s = 489.5,  end_s = 1248.0,  name = "Prayer & Consecration at the Altar", is_song = false },
    { start_s = 1248.0, end_s = 1496.0,  name = "3. Burn, Fire of God!", is_song = true },
    { start_s = 1496.0, end_s = 1603.5,  name = "Sharing: Christ Our True Treasure", is_song = false },
    { start_s = 1603.5, end_s = 1837.5,  name = "4. Christ Is Mine Forevermore", is_song = true },
    { start_s = 1837.5, end_s = 2126.34, name = "5. Footprints of Jesus", is_song = true }
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

local timelineName = "RLCF July 19 - Praise Set (Sectioned)"
local timeline = mediaPool:CreateEmptyTimeline(timelineName)
if not timeline then
    timelineName = "RLCF July 19 - Praise Set " .. os.time()
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
    print("SUCCESS: Created '" .. timelineName .. "' with 5 songs sectioned & color coded!")
end
