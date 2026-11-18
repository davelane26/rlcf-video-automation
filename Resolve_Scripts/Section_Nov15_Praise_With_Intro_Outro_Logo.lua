-- DaVinci Resolve Script: Section_Nov15_Praise_With_Intro_Outro_Logo.lua
-- Complete Automated Timeline Assembly for RLCF Praise (November 15, 2026)
-- 1. Video Track 1: RLCF Intro (4K) -> 12 Worship Sections (7 songs + sharings/prayers) -> RLCF Outro (4K)
-- 2. Video Track 2: RLCF Logo Watermark overlay (RLCFLogo_VIdeos.png) positioned at Zoom 0.250, Position (1450, 470)
-- 3. Cyan markers on all 7 songs, Blue markers on Intro/Outro, Teal clip color for songs, Orange for speaking

local projectManager = resolve:GetProjectManager()
local project = projectManager:GetCurrentProject()
if not project then
    print("Error: No project open in DaVinci Resolve!")
    return
end

local mediaPool = project:GetMediaPool()
local rootFolder = mediaPool:GetRootFolder()

-- Helper function to search clips in a folder and its subfolders
local function findClipInFolder(folder, matchPatterns)
    local clips = folder:GetClipList()
    for _, clip in ipairs(clips) do
        local name = clip:GetName()
        for _, pat in ipairs(matchPatterns) do
            if string.find(string.lower(name), string.lower(pat)) then
                return clip
            end
        end
    end
    local subfolders = folder:GetSubFolderList()
    if subfolders then
        for _, sub in ipairs(subfolders) do
            local found = findClipInFolder(sub, matchPatterns)
            if found then return found end
        end
    end
    return nil
end

-- 1. Locate Target Worship Video
local targetClip = findClipInFolder(rootFolder, {"2026-11-15", "11-15", "November 15", "Praise"})
if not targetClip then
    -- Try to import from Downloads
    pcall(function()
        mediaPool:ImportMedia({"C:\\Users\\djtwo\\Downloads\\2026-11-15 Praise.mkv"})
    end)
    targetClip = findClipInFolder(rootFolder, {"2026-11-15", "11-15", "November 15", "Praise"})
end

if not targetClip then
    local allClips = rootFolder:GetClipList()
    if #allClips > 0 then
        targetClip = allClips[1]
    end
end

if not targetClip then
    print("Error: No praise recording found in Media Pool. Please import '2026-11-15 Praise.mkv'.")
    return
end

-- 2. Locate or Auto-Import Intro, Outro, and Logo Assets
local introClip = findClipInFolder(rootFolder, {"RLCF_Intro4k", "RLCF_Intro"})
if not introClip then
    pcall(function()
        mediaPool:ImportMedia({
            "C:\\Users\\djtwo\\OneDrive\\Desktop\\Intro Outro Logo\\RLCF_Intro4k.mp4",
            "C:\\Users\\djtwo\\OneDrive\\Desktop\\Intro Outro Logo\\RLCF_Intro4k_with_CR.mp4"
        })
    end)
    introClip = findClipInFolder(rootFolder, {"RLCF_Intro4k", "RLCF_Intro"})
end

local outroClip = findClipInFolder(rootFolder, {"RLCF_Outro4k", "RLCF_Outro"})
if not outroClip then
    pcall(function()
        mediaPool:ImportMedia({
            "C:\\Users\\djtwo\\OneDrive\\Desktop\\Intro Outro Logo\\RLCF_Outro4k.mp4",
            "C:\\Users\\djtwo\\OneDrive\\Desktop\\Intro Outro Logo\\RLCF_Outro4k_with_CR.mp4"
        })
    end)
    outroClip = findClipInFolder(rootFolder, {"RLCF_Outro4k", "RLCF_Outro"})
end

local logoClip = findClipInFolder(rootFolder, {"RLCFLogo_VIdeos", "RLCFLogo_Videos", "RLCFLogo", "RLCF_Logo"})
if not logoClip then
    pcall(function()
        mediaPool:ImportMedia({"C:\\Users\\djtwo\\OneDrive\\Desktop\\Intro Outro Logo\\RLCFLogo_VIdeos.png"})
    end)
    logoClip = findClipInFolder(rootFolder, {"RLCFLogo_VIdeos", "RLCFLogo_Videos", "RLCFLogo", "RLCF_Logo"})
end

-- 3. Calculate Framerate and Base Timecode
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

-- 4. Worship Sections Definition (Accurate boundary offsets)
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

-- 5. Prepare Track 1 Clips List
local v1Clips = {}
local introFrames = 0
if introClip then
    local introDur = introClip:GetClipProperty("Frames")
    if introDur and tonumber(introDur) and tonumber(introDur) > 0 then
        introFrames = tonumber(introDur)
    else
        introFrames = math.floor(7.058866 * clipFps + 0.5)
    end
    table.insert(v1Clips, {
        mediaPoolItem = introClip
    })
end

for i, sec in ipairs(sections) do
    local s_frame = math.floor(baseFrame + sec.start_s * clipFps + 0.5)
    local e_frame = math.floor(baseFrame + sec.end_s * clipFps + 0.5)
    table.insert(v1Clips, {
        mediaPoolItem = targetClip,
        startFrame = s_frame,
        endFrame = e_frame
    })
end

local outroFrames = 0
if outroClip then
    local outroDur = outroClip:GetClipProperty("Frames")
    if outroDur and tonumber(outroDur) and tonumber(outroDur) > 0 then
        outroFrames = tonumber(outroDur)
    else
        outroFrames = math.floor(9.079 * clipFps + 0.5)
    end
    table.insert(v1Clips, {
        mediaPoolItem = outroClip
    })
end

-- 6. Create Timeline
local timelineName = "RLCF Nov 15 - Praise Set (Full Master)"
local timeline = mediaPool:CreateEmptyTimeline(timelineName)
if not timeline then
    timelineName = "RLCF Nov 15 - Praise Set " .. os.time()
    timeline = mediaPool:CreateEmptyTimeline(timelineName)
end

if not timeline then
    print("Error: Could not create timeline.")
    return
end

project:SetCurrentTimeline(timeline)

-- 7. Append Track 1 Clips
local timelineItems = mediaPool:AppendToTimeline(v1Clips)

-- 8. Add Markers & Clip Colors on Track 1
local currentTimelineFrame = 0

if introClip then
    timeline:AddMarker(0, "Blue", "RLCF Intro", "RLCF Intro 4K", introFrames, "")
    if timelineItems and timelineItems[1] then
        pcall(function() timelineItems[1]:SetClipColor("Navy") end)
    end
    currentTimelineFrame = introFrames
end

local sectionStartIndex = introClip and 2 or 1
for i, sec in ipairs(sections) do
    local durFrames = math.floor((sec.end_s - sec.start_s) * clipFps + 0.5)
    local itemIndex = sectionStartIndex + i - 1

    if sec.is_song then
        timeline:AddMarker(currentTimelineFrame, "Cyan", sec.name, "", durFrames, "")
    end

    if timelineItems and timelineItems[itemIndex] then
        pcall(function()
            if sec.is_song then
                timelineItems[itemIndex]:SetClipColor("Teal")
            else
                timelineItems[itemIndex]:SetClipColor("Orange")
            end
        end)
    end

    currentTimelineFrame = currentTimelineFrame + durFrames
end

if outroClip then
    local outroStartIndex = sectionStartIndex + #sections
    timeline:AddMarker(currentTimelineFrame, "Blue", "RLCF Outro", "RLCF Outro 4K", outroFrames, "")
    if timelineItems and timelineItems[outroStartIndex] then
        pcall(function() timelineItems[outroStartIndex]:SetClipColor("Navy") end)
    end
end

-- 9. Setup Video Track 2 (V2) & Position Logo Overlay
if logoClip then
    local vTrackCount = timeline:GetTrackCount("video")
    if vTrackCount < 2 then
        timeline:AddTrack("video")
    end

    local praiseTotalDurFrames = 0
    for _, sec in ipairs(sections) do
        praiseTotalDurFrames = praiseTotalDurFrames + math.floor((sec.end_s - sec.start_s) * clipFps + 0.5)
    end

    local logoClipInfo = {
        mediaPoolItem = logoClip,
        trackIndex = 2,
        mediaType = 1,
        recordFrame = introFrames,
        startFrame = 0,
        endFrame = praiseTotalDurFrames
    }
    mediaPool:AppendToTimeline({ logoClipInfo })

    -- Apply transform to all items on Video Track 2 (Inspector Transform settings)
    local v2Items = timeline:GetItemListInTrack("video", 2)
    if v2Items then
        for _, item in ipairs(v2Items) do
            pcall(function() item:SetProperty("ZoomX", 0.250) end)
            pcall(function() item:SetProperty("ZoomY", 0.250) end)
            pcall(function() item:SetProperty("ZoomGang", true) end)
            pcall(function() item:SetProperty("Pan", 1450.0) end)
            pcall(function() item:SetProperty("Tilt", 470.0) end)
            pcall(function() item:SetProperty("RotationAngle", 0.0) end)
            pcall(function() item:SetProperty("AnchorPointX", 0.0) end)
            pcall(function() item:SetProperty("AnchorPointY", 0.0) end)
            pcall(function() item:SetProperty("Pitch", 0.0) end)
            pcall(function() item:SetProperty("Yaw", 1.225) end)
        end
    end
    print("SUCCESS: Logo overlay configured on Video Track 2 (Zoom: 0.250, Position: 1450, 470)!")
end

print("SUCCESS: Created full timeline '" .. timelineName .. "' with Intro, Outro, Songs, Markers, and Watermark Logo!")
