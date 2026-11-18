-- DaVinci Resolve Script: Section_Nov15_Praise_Songs.lua
-- Slices and sections RLCF Praise (November 15, 2026) with official titles, markers, and color coding.

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
    if string.find(name, "2026-11-15") or string.find(name, "11-15") or string.find(name, "November 15") or string.find(name, "Praise") then
        targetClip = clip
        break
    end
end

if not targetClip and #clips > 0 then
    targetClip = clips[1]
end

if not targetClip then
    print("Error: No clip found in Media Pool. Please import '2026-11-15 Praise.mkv' into the Media Pool first.")
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

-- 7 Songs and in-between speaking sections (excluding pre-service holding screen and post-worship announcements)
local sections = {
    { start_s = 413.5,  end_s = 584.5,  name = "Opening Scripture (Mark 7 & Joshua 23) & Prayer", is_song = false },
    { start_s = 584.5,  end_s = 741.5,  name = "1. Think About His Love", is_song = true },
    { start_s = 741.5,  end_s = 872.0,  name = "2. My Jesus Has Done All Things Well", is_song = true },
    { start_s = 872.0,  end_s = 948.5,  name = "Sharing: Gethsemane & Calvary", is_song = false },
    { start_s = 948.5,  end_s = 1162.5, name = "3. Lead Me to Calvary", is_song = true },
    { start_s = 1162.5, end_s = 1326.0, name = "4. Jesus Paid It All", is_song = true },
    { start_s = 1326.0, end_s = 1488.5, name = "Sharing & Prayer: Abiding in Him & Good Shepherd", is_song = false },
    { start_s = 1488.5, end_s = 1718.0, name = "5. The King of Love My Shepherd Is", is_song = true },
    { start_s = 1718.0, end_s = 1951.0, name = "6. God Leads Us Along", is_song = true },
    { start_s = 1951.0, end_s = 1994.5, name = "Exhortation & Prayer: Victory in Jesus", is_song = false },
    { start_s = 1994.5, end_s = 2243.5, name = "7. It Is Well With My Soul", is_song = true },
    { start_s = 2243.5, end_s = 2255.0, name = "Closing Prayer", is_song = false }
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

local timelineName = "RLCF Nov 15 - Praise Set (Sectioned)"
local timeline = mediaPool:CreateEmptyTimeline(timelineName)
if not timeline then
    timelineName = "RLCF Nov 15 - Praise Set " .. os.time()
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
    print("SUCCESS: Created '" .. timelineName .. "' with 7 songs sectioned & color coded!")
end
