-- DaVinci Resolve Script: Section_Nov15_Praise_Songs.lua
-- Complete Automated Timeline Assembly for RLCF Praise (November 15, 2026)
-- 1. Video Track 1: RLCF_Intro4k.mp4 -> 12 Worship Sections (7 songs + sharings/prayers) -> RLCF_Outro4k.mp4
-- 2. Video Track 2: RLCF Logo Watermark overlay (RLCFLogo_VIdeos_Overlay.mov) stretched across the entire main praise video
--    with Zoom 0.250 and Position (1450, 470)
-- 3. Cyan markers on all 7 songs, Blue markers on Intro/Outro, Teal clip color for songs, Orange for speaking

local projectManager = resolve:GetProjectManager()
local project = projectManager:GetCurrentProject()
if not project then
    print("Error: No project open in DaVinci Resolve!")
    return
end

local mediaPool = project:GetMediaPool()
local rootFolder = mediaPool:GetRootFolder()

-- Helper function for substring match (used for the main praise recording)
local function findClipInFolder(folder, matchPatterns)
    local clips = folder:GetClipList()
    for _, pat in ipairs(matchPatterns) do
        for _, clip in ipairs(clips) do
            local name = clip:GetName()
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

-- Helper function for EXACT filename match (respects target priority order)
local function findExactClipInFolder(folder, exactNames)
    local clips = folder:GetClipList()
    for _, target in ipairs(exactNames) do
        for _, clip in ipairs(clips) do
            local name = string.lower(clip:GetName())
            if name == string.lower(target) then
                return clip
            end
        end
    end
    local subfolders = folder:GetSubFolderList()
    if subfolders then
        for _, sub in ipairs(subfolders) do
            local found = findExactClipInFolder(sub, exactNames)
            if found then return found end
        end
    end
    return nil
end

-- 1. Locate Target Worship Video
local targetClip = findClipInFolder(rootFolder, {"2026-11-15", "11-15", "November 15", "Praise"})
if not targetClip then
    pcall(function()
        mediaPool:ImportMedia({"C:\\Users\\djtwo\\Downloads\\2026-11-15 Praise.mkv"})
    end)
    targetClip = findClipInFolder(rootFolder, {"2026-11-15", "11-15", "November 15", "Praise"})
end

if not targetClip then
    print("Error: No praise recording found in Media Pool. Please import '2026-11-15 Praise.mkv'.")
    return
end

-- 2. Locate or Auto-Import EXACT Intro (RLCF_Intro4k.mp4), Outro (RLCF_Outro4k.mp4), and Full-Length Logo Overlay
local introClip = findExactClipInFolder(rootFolder, {"RLCF_Intro4k.mp4", "RLCF_Intro4k"})
if not introClip then
    pcall(function()
        mediaPool:ImportMedia({"C:\\Users\\djtwo\\OneDrive\\Desktop\\Intro Outro Logo\\RLCF_Intro4k.mp4"})
    end)
    introClip = findExactClipInFolder(rootFolder, {"RLCF_Intro4k.mp4", "RLCF_Intro4k"})
end

local outroClip = findExactClipInFolder(rootFolder, {"RLCF_Outro4k.mp4", "RLCF_Outro4k"})
if not outroClip then
    pcall(function()
        mediaPool:ImportMedia({"C:\\Users\\djtwo\\OneDrive\\Desktop\\Intro Outro Logo\\RLCF_Outro4k.mp4"})
    end)
    outroClip = findExactClipInFolder(rootFolder, {"RLCF_Outro4k.mp4", "RLCF_Outro4k"})
end

-- Always use RLCFLogo_VIdeos_Overlay.mov (33.5-min lossless transparent MOV) so Resolve stretches it across the entire 30m41.5s main video
local logoClip = findExactClipInFolder(rootFolder, {"RLCFLogo_VIdeos_Overlay.mov", "RLCFLogo_VIdeos_Overlay"})
if not logoClip then
    pcall(function()
        mediaPool:ImportMedia({"C:\\Users\\djtwo\\OneDrive\\Desktop\\Intro Outro Logo\\RLCFLogo_VIdeos_Overlay.mov"})
    end)
    logoClip = findExactClipInFolder(rootFolder, {"RLCFLogo_VIdeos_Overlay.mov", "RLCFLogo_VIdeos_Overlay"})
end

-- 3. Calculate Framerate and Base Timecode of Target Worship Clip
local clipFps = 30.0
local fpsProp = targetClip:GetClipProperty("FPS")
if fpsProp and tonumber(fpsProp) then
    clipFps = tonumber(fpsProp)
end

pcall(function()
    project:SetSetting("timelineFrameRate", tostring(clipFps))
    project:SetSetting("timelineResolutionWidth", "1920")
    project:SetSetting("timelineResolutionHeight", "1080")
end)

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
if introClip then
    table.insert(v1Clips, {
        mediaPoolItem = introClip
    })
end

local totalPraiseSeconds = 0.0
for i, sec in ipairs(sections) do
    local s_frame = math.floor(baseFrame + sec.start_s * clipFps + 0.5)
    local e_frame = math.floor(baseFrame + sec.end_s * clipFps + 0.5)
    totalPraiseSeconds = totalPraiseSeconds + (sec.end_s - sec.start_s)
    table.insert(v1Clips, {
        mediaPoolItem = targetClip,
        startFrame = s_frame,
        endFrame = e_frame
    })
end

if outroClip then
    table.insert(v1Clips, {
        mediaPoolItem = outroClip
    })
end

-- 6. Create Timeline
local timelineName = "RLCF Nov 15 - Praise Set (Full Master " .. os.date("%H%M%S") .. ")"
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
local timelineStartFrame = timeline:GetStartFrame()

-- 8. Add Markers & Clip Colors on Track 1 using exact TimelineItem positions
if introClip and timelineItems and timelineItems[1] then
    local introItem = timelineItems[1]
    local introOffset = introItem:GetStart() - timelineStartFrame
    local introDur = introItem:GetDuration()
    timeline:AddMarker(introOffset, "Blue", "RLCF Intro", "RLCF_Intro4k.mp4", introDur, "")
    pcall(function() introItem:SetClipColor("Navy") end)
end

local sectionStartIndex = introClip and 2 or 1
for i, sec in ipairs(sections) do
    local itemIndex = sectionStartIndex + i - 1
    local item = timelineItems and timelineItems[itemIndex]
    if item then
        local itemOffset = item:GetStart() - timelineStartFrame
        local itemDur = item:GetDuration()

        if sec.is_song then
            timeline:AddMarker(itemOffset, "Cyan", sec.name, "", itemDur, "")
        end

        pcall(function()
            if sec.is_song then
                item:SetClipColor("Teal")
            else
                item:SetClipColor("Orange")
            end
        end)
    end
end

if outroClip and timelineItems then
    local outroIndex = sectionStartIndex + #sections
    local outroItem = timelineItems[outroIndex]
    if outroItem then
        local outroOffset = outroItem:GetStart() - timelineStartFrame
        local outroDur = outroItem:GetDuration()
        timeline:AddMarker(outroOffset, "Blue", "RLCF Outro", "RLCF_Outro4k.mp4", outroDur, "")
        pcall(function() outroItem:SetClipColor("Navy") end)
    end
end

-- 9. Setup Video Track 2 (V2) & Stretch Logo Overlay Across Entire Main Praise Video
if logoClip and timelineItems then
    local vTrackCount = timeline:GetTrackCount("video")
    if vTrackCount < 2 then
        timeline:AddTrack("video")
    end

    -- Exact timeline frame where the main praise video begins (immediately after RLCF_Intro4k.mp4)
    local firstPraiseItem = timelineItems[sectionStartIndex]
    local praiseRecordFrame = firstPraiseItem and firstPraiseItem:GetStart() or timelineStartFrame

    -- Source frames at 30fps for the entire 30m 41.5s main praise video (55,245 frames)
    local logoSourceFrames = math.floor(totalPraiseSeconds * 30.0 + 0.5)

    local logoClipInfo = {
        mediaPoolItem = logoClip,
        trackIndex = 2,
        mediaType = 1,
        recordFrame = praiseRecordFrame,
        startFrame = 0,
        endFrame = logoSourceFrames
    }
    mediaPool:AppendToTimeline({ logoClipInfo })

    -- Apply exact Inspector Transform settings to Video Track 2 items
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
            pcall(function() item:SetProperty("Yaw", 0.0) end)
        end
    end
    print("SUCCESS: Stretched Logo overlay across the entire main video on Video Track 2 (Zoom: 0.250, Position: 1450, 470)!")
end

print("SUCCESS: Created full timeline '" .. timelineName .. "' with RLCF_Intro4k, RLCF_Outro4k, 7 Songs, and full-length Watermark Logo!")
