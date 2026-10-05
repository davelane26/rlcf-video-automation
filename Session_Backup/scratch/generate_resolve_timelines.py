import os
import xml.sax.saxutils as saxutils
import xml.etree.ElementTree as ET
import urllib.parse

fps = 30
video_file = r"C:\Users\djtwo\Downloads\RLCF Sunday Meeting Livestreaming - September 13, 2026.mp4"
video_filename = os.path.basename(video_file)

# Segments to KEEP (Start sec, End sec, Description)
keep_segments = [
    (280.0, 378.0, "Opening Welcome and Prayer"),
    (527.0, 563.0, "Sharing 1 Power of Christ Risen"),
    (760.0, 1431.0, "Prayer and Sharing 2 Intercession"),
    (1665.0, 1688.0, "Sharing 3 Life of Christ"),
    (1799.0, 1810.0, "Sharing 4 Christ in Saints"),
    (1940.0, 2002.0, "Sharing 5 Forgiveness and Pit"),
    (2172.0, 7125.0, "Welcome Announcements Sermon"),
]

def sec_to_frames(sec, frame_rate=30):
    return int(round(sec * frame_rate))

def sec_to_tc(sec, frame_rate=30):
    total_frames = int(round(sec * frame_rate))
    f = total_frames % frame_rate
    tot_s = total_frames // frame_rate
    s = tot_s % 60
    tot_m = tot_s // 60
    m = tot_m % 60
    h = tot_m // 60
    return f"{h:02d}:{m:02d}:{s:02d}:{f:02d}"

total_timeline_frames = sum(sec_to_frames(end - start, fps) for start, end, _ in keep_segments)
safe_video_filename = saxutils.escape(video_filename)
file_url = "file://localhost/" + urllib.parse.quote(video_file.replace("\\", "/"))

# 1. Update EDL with 00:00:00:00 timeline start
edl_path = r"C:\Users\djtwo\Downloads\RLCF_Sunday_No_Singing.edl"
with open(edl_path, "w", encoding="ascii") as f:
    f.write("TITLE: RLCF Sunday No Singing\n")
    f.write("FCM: NON-DROP FRAME\n\n")
    
    timeline_frame = 0
    timeline_start_sec = 0 # 00:00:00:00
    
    for idx, (src_start, src_end, desc) in enumerate(keep_segments, 1):
        dur = src_end - src_start
        src_in_tc = sec_to_tc(src_start, fps)
        src_out_tc = sec_to_tc(src_end, fps)
        
        rec_in_tc = sec_to_tc(timeline_start_sec + timeline_frame / fps, fps)
        timeline_frame += int(round(dur * fps))
        rec_out_tc = sec_to_tc(timeline_start_sec + timeline_frame / fps, fps)
        
        f.write(f"{idx:03d}  AX       AA/V  C        {src_in_tc} {src_out_tc} {rec_in_tc} {rec_out_tc}\n")
        f.write(f"* FROM CLIP NAME: {video_filename}\n")
        f.write(f"* COMMENT: {desc}\n\n")

print(f"Updated EDL: {edl_path}")

# 2. Update XML with explicit 00:00:00:00 timecode on both file and sequence
xml_path = r"C:\Users\djtwo\Downloads\RLCF_Sunday_No_Singing.xml"

xml_content = f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xmeml>
<xmeml version="5">
  <project>
    <name>RLCF Sunday No Singing</name>
    <children>
      <clip id="masterclip-1">
        <name>{safe_video_filename}</name>
        <duration>{sec_to_frames(7125.88, fps)}</duration>
        <rate>
          <timebase>{fps}</timebase>
          <ntsc>FALSE</ntsc>
        </rate>
        <media>
          <video>
            <track>
              <clipitem id="clipitem-media-1">
                <name>{safe_video_filename}</name>
                <duration>{sec_to_frames(7125.88, fps)}</duration>
                <rate>
                  <timebase>{fps}</timebase>
                  <ntsc>FALSE</ntsc>
                </rate>
                <file id="file-1">
                  <name>{safe_video_filename}</name>
                  <pathurl>{file_url}</pathurl>
                  <rate>
                    <timebase>{fps}</timebase>
                    <ntsc>FALSE</ntsc>
                  </rate>
                  <duration>{sec_to_frames(7125.88, fps)}</duration>
                  <timecode>
                    <rate>
                      <timebase>{fps}</timebase>
                      <ntsc>FALSE</ntsc>
                    </rate>
                    <string>00:00:00:00</string>
                    <frame>0</frame>
                    <displayformat>NDF</displayformat>
                  </timecode>
                  <media>
                    <video>
                      <samplecharacteristics>
                        <width>1280</width>
                        <height>720</height>
                      </samplecharacteristics>
                    </video>
                    <audio>
                      <samplecharacteristics>
                        <samplerate>44100</samplerate>
                        <depth>16</depth>
                      </samplecharacteristics>
                      <channelcount>2</channelcount>
                    </audio>
                  </media>
                </file>
              </clipitem>
            </track>
          </video>
        </media>
      </clip>
      <sequence id="sequence-1">
        <name>RLCF Sunday - Singing Removed</name>
        <duration>{total_timeline_frames}</duration>
        <rate>
          <timebase>{fps}</timebase>
          <ntsc>FALSE</ntsc>
        </rate>
        <timecode>
          <rate>
            <timebase>{fps}</timebase>
            <ntsc>FALSE</ntsc>
          </rate>
          <string>00:00:00:00</string>
          <frame>0</frame>
          <displayformat>NDF</displayformat>
        </timecode>
        <media>
          <video>
            <format>
              <samplecharacteristics>
                <width>1280</width>
                <height>720</height>
                <rate>
                  <timebase>{fps}</timebase>
                  <ntsc>FALSE</ntsc>
                </rate>
              </samplecharacteristics>
            </format>
            <track>
"""

curr_timeline_frame = 0
for i, (src_start, src_end, desc) in enumerate(keep_segments, 1):
    in_f = sec_to_frames(src_start, fps)
    out_f = sec_to_frames(src_end, fps)
    dur_f = out_f - in_f
    start_f = curr_timeline_frame
    end_f = curr_timeline_frame + dur_f
    curr_timeline_frame = end_f
    
    xml_content += f"""              <clipitem id="video-clip-{i}">
                <name>{safe_video_filename}</name>
                <duration>{sec_to_frames(7125.88, fps)}</duration>
                <rate>
                  <timebase>{fps}</timebase>
                  <ntsc>FALSE</ntsc>
                </rate>
                <start>{start_f}</start>
                <end>{end_f}</end>
                <in>{in_f}</in>
                <out>{out_f}</out>
                <file id="file-1"/>
              </clipitem>
"""

xml_content += """            </track>
          </video>
          <audio>
            <track>
"""

curr_timeline_frame = 0
for i, (src_start, src_end, desc) in enumerate(keep_segments, 1):
    in_f = sec_to_frames(src_start, fps)
    out_f = sec_to_frames(src_end, fps)
    dur_f = out_f - in_f
    start_f = curr_timeline_frame
    end_f = curr_timeline_frame + dur_f
    curr_timeline_frame = end_f
    
    xml_content += f"""              <clipitem id="audio-1-clip-{i}">
                <name>{safe_video_filename}</name>
                <duration>{sec_to_frames(7125.88, fps)}</duration>
                <rate>
                  <timebase>{fps}</timebase>
                  <ntsc>FALSE</ntsc>
                </rate>
                <start>{start_f}</start>
                <end>{end_f}</end>
                <in>{in_f}</in>
                <out>{out_f}</out>
                <file id="file-1"/>
                <sourcetrack>
                  <mediatype>audio</mediatype>
                  <trackindex>1</trackindex>
                </sourcetrack>
              </clipitem>
"""

xml_content += """            </track>
            <track>
"""

curr_timeline_frame = 0
for i, (src_start, src_end, desc) in enumerate(keep_segments, 1):
    in_f = sec_to_frames(src_start, fps)
    out_f = sec_to_frames(src_end, fps)
    dur_f = out_f - in_f
    start_f = curr_timeline_frame
    end_f = curr_timeline_frame + dur_f
    curr_timeline_frame = end_f
    
    xml_content += f"""              <clipitem id="audio-2-clip-{i}">
                <name>{safe_video_filename}</name>
                <duration>{sec_to_frames(7125.88, fps)}</duration>
                <rate>
                  <timebase>{fps}</timebase>
                  <ntsc>FALSE</ntsc>
                </rate>
                <start>{start_f}</start>
                <end>{end_f}</end>
                <in>{in_f}</in>
                <out>{out_f}</out>
                <file id="file-1"/>
                <sourcetrack>
                  <mediatype>audio</mediatype>
                  <trackindex>2</trackindex>
                </sourcetrack>
              </clipitem>
"""

xml_content += """            </track>
          </audio>
        </media>
      </sequence>
    </children>
  </project>
</xmeml>
"""

with open(xml_path, "w", encoding="utf-8") as f:
    f.write(xml_content)

print(f"Updated XML: {xml_path}")
ET.parse(xml_path)
print("XML validation OK!")
