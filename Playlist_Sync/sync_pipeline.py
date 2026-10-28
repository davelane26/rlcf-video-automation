import os
import sys
import json
import argparse
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from google.auth.transport.requests import Request

if sys.stdout.encoding.lower() != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8')

CONFIG_DIR = r"C:\Users\djtwo\.gemini\config\youtube_auth"
TOKEN_PATH = os.path.join(CONFIG_DIR, "token.json")
CATALOG_PATH = r"C:\Users\djtwo\.gemini\antigravity\brain\d7dd5206-254b-4e23-83b0-cb17bc0a5796\scratch\rlcf_master_catalog.json"

DEFAULT_PLAYLISTS = [
    "PLd5XCKe7E24E",                      # Sunday's song list (Dave Lane channel)
    "PLDzEX8mCMdiJaYKqE-EvKNZEVcpX42PsW"  # Sunday's Song list (Collaborative)
]

def get_youtube_client():
    if not os.path.exists(TOKEN_PATH):
        raise FileNotFoundError(f"OAuth token not found at {TOKEN_PATH}. Please run authentication first.")
    
    with open(TOKEN_PATH, "r", encoding="utf-8") as f:
        token_data = json.load(f)
    
    creds = Credentials.from_authorized_user_info(token_data)
    if creds.expired and creds.refresh_token:
        creds.refresh(Request())
        with open(TOKEN_PATH, "w", encoding="utf-8") as f:
            f.write(creds.to_json())
            
    return build("youtube", "v3", credentials=creds)

def load_catalog():
    if not os.path.exists(CATALOG_PATH):
        raise FileNotFoundError(f"Catalog file not found at {CATALOG_PATH}")
    with open(CATALOG_PATH, "r", encoding="utf-8") as f:
        return json.load(f)

def match_songs(song_queries, catalog, include_duplicates=True):
    matched_results = []
    
    for q in song_queries:
        clean_q = q.strip().lower()
        # Remove leading numbers like "1.", "1 - ", etc.
        import re
        clean_q = re.sub(r'^\d+[\.\-\s]+', '', clean_q).strip()
        
        matches = []
        for item in catalog:
            title_lower = item.get("title", "").lower()
            if clean_q in title_lower:
                matches.append(item)
            elif any(part.strip() in title_lower for part in clean_q.split("/") if len(part.strip()) > 3):
                matches.append(item)
                
        # Deduplicate identical video IDs within same query
        unique_matches = []
        seen = set()
        for m in matches:
            if m["id"] not in seen:
                seen.add(m["id"])
                unique_matches.append(m)
                
        if not include_duplicates and unique_matches:
            unique_matches = [unique_matches[0]]
            
        matched_results.append({
            "query": q,
            "clean_query": clean_q,
            "matches": unique_matches
        })
        
    return matched_results

def clear_playlist(youtube, playlist_id):
    deleted_count = 0
    while True:
        req = youtube.playlistItems().list(
            part="id,snippet",
            playlistId=playlist_id,
            maxResults=50
        )
        resp = req.execute()
        items = resp.get("items", [])
        if not items:
            break
            
        for item in items:
            item_id = item["id"]
            try:
                youtube.playlistItems().delete(id=item_id).execute()
                deleted_count += 1
            except Exception:
                pass
                
    return deleted_count

def sync_playlist(youtube, playlist_id, video_ids, clear_first=True):
    if clear_first:
        cleared = clear_playlist(youtube, playlist_id)
        print(f"🗑️ Cleared {cleared} old songs from playlist {playlist_id}")
        
    added = []
    for vid in video_ids:
        try:
            req = youtube.playlistItems().insert(
                part="snippet",
                body={
                    "snippet": {
                        "playlistId": playlist_id,
                        "resourceId": {
                            "kind": "youtube#video",
                            "videoId": vid
                        }
                    }
                }
            )
            resp = req.execute()
            title = resp.get("snippet", {}).get("title", vid)
            print(f"  ✅ Added: {title} ({vid})")
            added.append((vid, title))
        except Exception as e:
            print(f"  ❌ Failed to add {vid}: {e}")
            
    return added

def run_sync(song_list, include_duplicates=True, target_playlists=None, clear_first=True):
    catalog = load_catalog()
    matched = match_songs(song_list, catalog, include_duplicates=include_duplicates)
    
    all_video_ids = []
    for m in matched:
        for v in m["matches"]:
            all_video_ids.append(v["id"])
            
    print(f"\nFound {len(all_video_ids)} total recordings for {len(song_list)} songs.")
    
    youtube = get_youtube_client()
    playlists = target_playlists or DEFAULT_PLAYLISTS
    
    for pid in playlists:
        print(f"\n==========================================")
        print(f"Syncing Playlist: {pid}")
        print(f"==========================================")
        sync_playlist(youtube, pid, all_video_ids, clear_first=clear_first)
        
    return matched, all_video_ids

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Sync Sunday Worship Songs to YouTube Playlists")
    parser.add_argument("--songs", nargs="+", help="List of songs to match and sync")
    parser.add_argument("--no-duplicates", action="store_true", help="Only keep the newest recording per song")
    parser.add_argument("--playlists", nargs="*", default=DEFAULT_PLAYLISTS, help="Target playlist IDs")
    parser.add_argument("--append", action="store_true", help="Append without clearing playlist first")
    
    args = parser.parse_args()
    if args.songs:
        run_sync(
            args.songs,
            include_duplicates=not args.no_duplicates,
            target_playlists=args.playlists,
            clear_first=not args.append
        )
