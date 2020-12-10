import asyncdispatch, json, strutils
import listenbrainz
import listenbrainz/[core]
import types

proc checkKey(source: JsonNode,
  key: string): bool = 
  result = false
  if source.contains(key):
    let val = source[key].getStr
    if val != "" and val != "null":
      result = true

proc jsonToListen*(payload: JsonNode): Listen =
  ## Convert a listen JSON payload to a Listen object
  let
    listened_at = payload["listened_at"].getInt
    track_name = payload["track_metadata"]["track_name"].getStr
    artist_name = payload["track_metadata"]["artist_name"].getStr
  result = newListen(listened_at, newTrack(track_name, artist_name))
  if checkKey(payload["track_metadata"], "release_name"):
    result.track.release_name = payload["track_metadata"]["release_name"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "tracknumber"):
    result.track.tracknumber = payload["track_metadata"]["additional_info"]["tracknumber"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "track_mbid"):
    result.track.track_mbid = payload["track_metadata"]["additional_info"]["track_mbid"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "recording_mbid"):
    result.track.recording_mbid = payload["track_metadata"]["additional_info"]["recording_mbid"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "release_mbid"):
    result.track.release_mbid = payload["track_metadata"]["additional_info"]["release_mbid"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "release_group_mbid"):
    result.track.release_group_mbid = payload["track_metadata"]["additional_info"]["release_group_mbid"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "artist_msid"):
    result.track.artist_msid = payload["track_metadata"]["additional_info"]["artist_msid"].getStr
  if checkKey(payload, "recording_msid"):
    result.track.recording_msid = payload["recording_msid"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "release_msid"):
    result.track.release_msid = payload["track_metadata"]["additional_info"]["release_msid"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "isrc"):
    result.track.isrc = payload["track_metadata"]["additional_info"]["isrc"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "spotify_id"):
    result.track.spotify_id = payload["track_metadata"]["additional_info"]["spotify_id"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "tags"):
    result.track.tags = payload["track_metadata"]["additional_info"]["tags"].to(seq[string])
  if checkKey(payload["track_metadata"]["additional_info"], "artist_mbids"):
    result.track.artist_mbids = payload["track_metadata"]["additional_info"]["artist_mbids"].to(seq[string])
  if checkKey(payload["track_metadata"]["additional_info"],"word_mbids"):
    result.track.word_mbids = payload["track_metadata"]["additional_info"]["word_mbids"].to(seq[string])


proc listenToJson*(listen: Listen): JsonNode =
  ## Generate ListenBrainz listen payload given a Listen object
  result = %*
    {
      "listen_type": listen.listen_type,
      "payload": [
        {
          "listened_at": $listen.listened_at,
          "track_metadata": {
            "additional_info": {
              "listening_from": listen.listening_from
            },
            "artist_name": listen.track.artist_name,
            "track_name": listen.track.track_name
          }
        }
      ]
    }
  if listen.playing_now:
    result["payload"][0].add("playing_now", %* listen.playing_now)
  if not listen.track.release_name.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"].add("release_name", %* listen.track.release_name)
  if not listen.track.tracknumber.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("tracknumber", %* listen.track.tracknumber.parseInt())
  if not listen.track.track_mbid.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("track_mbid", %* listen.track.track_mbid)
  if not listen.track.recording_mbid.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("recording_mbid", %* listen.track.recording_mbid)
  if not listen.track.release_mbid.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("release_mbid", %* listen.track.release_mbid)
  if not listen.track.release_group_mbid.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("release_group_mbid", %* listen.track.release_group_mbid)
  if not listen.track.artist_msid.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("artist_msid", %* listen.track.artist_msid)
  if not listen.track.recording_msid.isEmptyOrWhitespace():
    result["payload"][0].add("recording_msid", %* listen.track.recording_msid)
  if not listen.track.release_msid.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("release_msid", %* listen.track.release_msid)
  if not listen.track.isrc.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("isrc", %* listen.track.isrc)
  if not listen.track.spotify_id.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("spotify_id", %* listen.track.spotify_id)
  if listen.track.tags != @[""]:
    result["payload"][0]["track_metadata"]["additional_info"].add("tags", %* listen.track.tags)
  if listen.track.artist_mbids != @[""]:
    result["payload"][0]["track_metadata"]["additional_info"].add("artist_mbids", %* listen.track.artist_mbids)
  if listen.track.word_mbids != @[""]:
    result["payload"][0]["track_metadata"]["additional_info"].add("word_mbids", %* listen.track.word_mbids)


proc getCurrentTrack*(
  lb: SyncListenBrainz | AsyncListenBrainz,
  user: User): Future[Listen] {.multisync.} =
  ## Get a user's last listened to track
  let recentListens = await getUsersRecentListens(lb, @[user.username])
  if recentListens["payload"]["count"].getInt == 0:
    raise newException(ValueError, "ERROR: User has no recent listens!")
  return jsonToListen(recentListens["payload"]["listens"][0])


proc listenTrack*(
  lb: SyncListenBrainz | AsyncListenBrainz,
  listen: Listen): Future[JsonNode] {.multisync.} =
  ## submit a listen to ListenBrainz given a ListenBrainz object, and Listen object
  result = await lb.submitListens(listenToJson(listen))


proc validateLbToken*(
  lb: SyncListenBrainz | AsyncListenBrainz,
  lb_token: string) {.multisync.} =
  ## Validate a ListenBrainz token given a ListenBrainz object and token
  if lb_token != "":
    let result = await lb.validateToken(lb_token)
    if result["code"].getInt != 200:
      raise newException(ValueError, "ERROR: Invalid token (or perhaps you are rate limited)")
  else:
    raise newException(ValueError, "ERROR: Token is empty string.")


#### Last.FM support

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


#proc newScrobble(scrobble: Scrobble): string =


#proc scrobbleToTrack*(fm: SyncLastFM | AsyncLastFM)


#proc scrobbleTrack*(fm: SyncLastFM | AsyncLastFM)
