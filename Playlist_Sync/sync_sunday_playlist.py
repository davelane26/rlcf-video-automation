import os
import sys
import json
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from google.auth.transport.requests import Request

if sys.stdout.encoding.lower() != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8')

TOKEN_PATH = r"C:\Users\djtwo\.gemini\config\youtube_auth\token.json"
CLIENT_SECRET_PATH = r"C:\Users\djtwo\.gemini\config\youtube_auth\client_secret.json"

def get_youtube_client():
    if not os.path.exists(TOKEN_PATH):
        raise FileNotFoundError(f"Token file not found at {TOKEN_PATH}. Please run authenticate.py first.")
    
    with open(TOKEN_PATH, "r", encoding="utf-8") as f:
        token_data = json.load(f)
    
    creds = Credentials.from_authorized_user_info(token_data)
    if creds.expired and creds.refresh_token:
        print("Refreshing expired access token...", flush=True)
        creds.refresh(Request())
        with open(TOKEN_PATH, "w", encoding="utf-8") as f:
            f.write(creds.to_json())
    
    return build("youtube", "v3", credentials=creds)

def clear_playlist(youtube, playlist_id):
    """Fetches all items in the playlist and deletes them."""
    print(f"Clearing old songs from playlist: {playlist_id}...", flush=True)
    
    deleted_count = 0
    while True:
        # Fetch current items (up to 50 at a time)
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
            title = item.get("snippet", {}).get("title", "Unknown Title")
            try:
                youtube.playlistItems().delete(id=item_id).execute()
                print(f"  🗑️ Removed old: {title}", flush=True)
                deleted_count += 1
            except Exception as e:
                print(f"  ⚠️ Could not remove {title}: {e}", flush=True)
                
    print(f"Total old songs cleared: {deleted_count}\n", flush=True)
    return deleted_count

def sync_playlist(playlist_id, video_ids, clear_first=True):
    youtube = get_youtube_client()
    
    # 1. Clear old songs if requested
    if clear_first:
        clear_playlist(youtube, playlist_id)
        
    # 2. Add new songs
    print(f"Adding {len(video_ids)} new songs to playlist: {playlist_id}...", flush=True)
    results = []
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
            print(f"  ✅ Added: {title} ({vid})", flush=True)
            results.append((vid, True, title))
        except Exception as e:
            print(f"  ❌ Failed to add {vid}: {e}", flush=True)
            results.append((vid, False, str(e)))
            
    added_count = sum(1 for r in results if r[1])
    print(f"\nFinished: Successfully added {added_count}/{len(video_ids)} songs!", flush=True)
    return results

if __name__ == "__main__":
    target_playlist_id = sys.argv[1] if len(sys.argv) > 1 else "PLd5XCKe7E24E"
    
    songs = [
        "0IPYjAgAF90", # Blessed Be the Lord God Almighty — April 30, 2023
        "ejnHlWq1ZJw", # My Worth Is Not in What I Own — April 14, 2024
        "4kLq7zupeoU", # My Worth is Not in What I Own — September 10, 2023
        "BugtWRRplY8", # Abide With Me — April 21, 2024
        "kYGU44VQ15Q", # I Have Learned the Wondrous Secret — January 11, 2026
        "IkHY3p0zN80", # I Have Learned the Wondrous Secret — June 25, 2023
        "-NS2GTF__tQ"  # Yet Not I But Through Christ in Me — July 9, 2023
    ]
    
    sync_playlist(target_playlist_id, songs, clear_first=True)
