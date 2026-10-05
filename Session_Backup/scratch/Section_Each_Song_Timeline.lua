-- DaVinci Resolve Script: Section_Each_Song_Timeline.lua
-- Slices and labels the 5 songs with their official titles and markers

local projectManager = resolve:GetProjectManager()
local project = projectManager:GetCurrentProject()
if not project then
    print("No project open!")
    return
end

local mediaPool = project:GetMediaPool()
local rootFolder = mediaPool:GetRootFolder()
local clips = rootFolder:GetClipList()

local targetClip = nil
for i, clip in ipairs(clips) do
    local name = clip:GetName()
    if string.find(name, "RLCF") or string.find(name, "September 13") or string.find(name, ".mp4") then
        targetClip = clip
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

-- 5 Official Songs and in-between speaking
local sections = {
    { start_s = 378.0,  end_s = 527.0,  name = "1. Come, Be Enthroned in Our Praise", is_song = true },
    { start_s = 527.0,  end_s = 563.0,  name = "Sharing: Power of Christ Risen", is_song = false },
    { start_s = 563.0,  end_s = 760.0,  name = "2. See, What a Morning", is_song = true },
    { start_s = 760.0,  end_s = 1431.0, name = "Prayer & Intercession", is_song = false },
    { start_s = 1431.0, end_s = 1665.0, name = "3. Jesus, My Savior, Thy Greatness I See", is_song = true },
    { start_s = 1665.0, end_s = 1688.0, name = "Sharing: Life of Christ", is_song = false },
    { start_s = 1688.0, end_s = 1940.0, name = "4. God In Heaven Hath a Treasure", is_song = true },
    { start_s = 1940.0, end_s = 2002.0, name = "Sharing: Forgiveness & The Pit", is_song = false },
    { start_s = 2002.0, end_s = 2173.0, name = "5. I Will Not Forget", is_song = true }
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

local timelineName = "RLCF Sunday - 5 Worship Songs"
local timeline = mediaPool:CreateEmptyTimeline(timelineName)
if not timeline then
    timelineName = "RLCF Sunday - 5 Worship Songs " .. os.time()
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
    print("SUCCESS: Created 'RLCF Sunday - 5 Worship Songs' with official titles!")
end
