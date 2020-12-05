import asyncdispatch, json, times
import listenbrainz
import listenbrainz/[core]
import types

proc newListen(track: Track, timestamp: string): JsonNode =
  result = %*
    {
      "listen_type": "single",
      "payload": [
        {
          "listened_at": timestamp,
          "track_metadata": {
            "additional_info": {
              "listening_from": "Listen2gether"
            }
          },
        "artist_name": track.artist_name,
        "track_name": track.track_name,
        }
      ]
    }
  if track.release_name != "":
    result["payload"].add(%* {"release_name": track.release_name})
  if track.track_mbid != "":
    result["payload"]["track_metadata"]["additional_info"] = %* {"track_mbid": track.track_mbid}
  if track.artist_mbid != "":
    result["payload"]["track_metadata"]["additional_info"] = %* {"artist_mbid": track.artist_mbid}
  if track.release_mbid != "":
    result["payload"]["track_metadata"]["additional_info"] = %* {"release_mbid": track.release_mbid}

proc listenTrack*(
  lb: SyncListenBrainz | AsyncListenBrainz,
  user: User,
  track: Track,
  timestamp = $getTime().toUnix()): Future[JsonNode] {.multisync.} =
  result = await lb.submitListens(newListen(track, timestamp))



#[
lastfm xml
#####
<track nowplaying="true">
  <artist mbid="2f9ecbed-27be-40e6-abca-6de49d50299e">Aretha Franklin</artist>
  <name>Sisters Are Doing It For Themselves</name>
  <mbid/>
  <album mbid=""/>
  <url>www.last.fm/music/Aretha+Franklin/_/Sisters+Are+Doing+It+For+Themselves</url>
  <date uts="1213031819">9 Jun 2008, 17:16</date>
  <streamable>1</streamable>
</track>
]#


#proc newScrobblePayload(scrobble: Scrobble): string =


#proc scrobbleTrack*(fm: SyncLastFM | AsyncLastFM)