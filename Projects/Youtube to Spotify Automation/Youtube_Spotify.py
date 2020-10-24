
import json

from secrets import *

class CreatePlaylist:

    def __init__(self):
        self.user_id


    # Step 1: Log Into Youtube
    def get_youtube_client(self):
        pass

    # Step 2: Get Liked Videos
    def get_liked_videos(self):
        pass

    # Step 3: Create a New Playlist
    def create_playlist(self):

        request_body = json.dumps({
            "name": "Youtube Liked Videos",
            "description": "All Liked Youtube Videos",
            "public": True
        })

        query = "https://api.spotify.com/v1/users/{user_id}/playlists".format()

    # Step 4: Search for the Song
    def get_spotify_url(self):
        pass

    # Step 5: Add this song into new spotify playlist
    def add_song_to_playlist(self):
        pass

