import asyncdispatch, json
import lastfm
import lastfm/[user]

# proc getCurrentTrack*(
#   auth: LastFMSession,
#   username: string): (string, string, string) =
#   let
#     lastTrack = (waitFor userRecentTracks(auth, username, limit=1)){"recenttracks", "track"}[0]
#     trackName = lastTrack["name"].getStr()
#     trackArtist = lastTrack{"artist", "#text"}.getStr()
#     trackAlbum = lastTrack{"album", "#text"}.getStr()
#   return (trackName, trackArtist, trackAlbum)