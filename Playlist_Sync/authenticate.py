import os
import sys
from google_auth_oauthlib.flow import InstalledAppFlow

if sys.stdout.encoding.lower() != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8')

CLIENT_SECRET_FILE = r"C:\Users\djtwo\.gemini\config\youtube_auth\client_secret.json"
TOKEN_FILE = r"C:\Users\djtwo\.gemini\config\youtube_auth\token.json"

SCOPES = [
    "https://www.googleapis.com/auth/youtube"
]

print("Starting Google OAuth flow with exact credentials...", flush=True)

flow = InstalledAppFlow.from_client_secrets_file(
    CLIENT_SECRET_FILE,
    scopes=SCOPES
)

creds = flow.run_local_server(port=0, prompt="consent", open_browser=True)

with open(TOKEN_FILE, "w", encoding="utf-8") as f:
    f.write(creds.to_json())

print("\n==========================================", flush=True)
print("SUCCESS: Authentication complete!", flush=True)
print(f"Token saved to: {TOKEN_FILE}", flush=True)
print("==========================================", flush=True)
