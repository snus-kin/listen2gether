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
    listenedAt = payload["listenedAt"].getInt
    trackName = payload["track_metadata"]["trackName"].getStr
    artistName = payload["track_metadata"]["artistName"].getStr
  result = newListen(listenedAt, newTrack(trackName, artistName))
  if checkKey(payload["track_metadata"], "releaseName"):
    result.track.releaseName = payload["track_metadata"]["releaseName"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "trackNumber"):
    result.track.trackNumber = payload["track_metadata"]["additional_info"]["trackNumber"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "trackMBID"):
    result.track.trackMBID = payload["track_metadata"]["additional_info"]["trackMBID"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "recordingMBID"):
    result.track.recordingMBID = payload["track_metadata"]["additional_info"]["recordingMBID"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "releaseMBID"):
    result.track.releaseMBID = payload["track_metadata"]["additional_info"]["releaseMBID"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "releaseGroupMBID"):
    result.track.releaseGroupMBID = payload["track_metadata"]["additional_info"]["releaseGroupMBID"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "artistMSID"):
    result.track.artistMSID = payload["track_metadata"]["additional_info"]["artistMSID"].getStr
  if checkKey(payload, "recordingMSID"):
    result.track.recordingMSID = payload["recordingMSID"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "releaseMSID"):
    result.track.releaseMSID = payload["track_metadata"]["additional_info"]["releaseMSID"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "isrc"):
    result.track.isrc = payload["track_metadata"]["additional_info"]["isrc"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "spotifyID"):
    result.track.spotifyID = payload["track_metadata"]["additional_info"]["spotifyID"].getStr
  if checkKey(payload["track_metadata"]["additional_info"], "tags"):
    result.track.tags = payload["track_metadata"]["additional_info"]["tags"].to(seq[string])
  if checkKey(payload["track_metadata"]["additional_info"], "artistMBIDs"):
    result.track.artistMBIDs = payload["track_metadata"]["additional_info"]["artistMBIDs"].to(seq[string])
  if checkKey(payload["track_metadata"]["additional_info"],"wordMBIDs"):
    result.track.wordMBIDs = payload["track_metadata"]["additional_info"]["wordMBIDs"].to(seq[string])


proc listenToJson*(listen: Listen): JsonNode =
  ## Generate ListenBrainz listen payload given a Listen object
  result = %*
    {
      "listen_type": listen.listenType,
      "payload": [
        {
          "listenedAt": $listen.listenedAt,
          "track_metadata": {
            "additional_info": {
              "listening_from": listen.listeningFrom
            },
            "artistName": listen.track.artistName,
            "trackName": listen.track.trackName
          }
        }
      ]
    }
  if listen.playingNow:
    result["payload"][0].add("playing_now", %* listen.playingNow)
  if not listen.track.releaseName.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"].add("releaseName", %* listen.track.releaseName)
  if not listen.track.trackNumber.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("trackNumber", %* listen.track.trackNumber.parseInt())
  if not listen.track.trackMBID.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("trackMBID", %* listen.track.trackMBID)
  if not listen.track.recordingMBID.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("recordingMBID", %* listen.track.recordingMBID)
  if not listen.track.releaseMBID.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("releaseMBID", %* listen.track.releaseMBID)
  if not listen.track.releaseGroupMBID.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("releaseGroupMBID", %* listen.track.releaseGroupMBID)
  if not listen.track.artistMSID.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("artistMSID", %* listen.track.artistMSID)
  if not listen.track.recordingMSID.isEmptyOrWhitespace():
    result["payload"][0].add("recordingMSID", %* listen.track.recordingMSID)
  if not listen.track.releaseMSID.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("releaseMSID", %* listen.track.releaseMSID)
  if not listen.track.isrc.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("isrc", %* listen.track.isrc)
  if not listen.track.spotifyID.isEmptyOrWhitespace():
    result["payload"][0]["track_metadata"]["additional_info"].add("spotifyID", %* listen.track.spotifyID)
  if listen.track.tags != @[""]:
    result["payload"][0]["track_metadata"]["additional_info"].add("tags", %* listen.track.tags)
  if listen.track.artistMBIDs != @[""]:
    result["payload"][0]["track_metadata"]["additional_info"].add("artistMBIDs", %* listen.track.artistMBIDs)
  if listen.track.wordMBIDs != @[""]:
    result["payload"][0]["track_metadata"]["additional_info"].add("wordMBIDs", %* listen.track.wordMBIDs)


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
  lbToken: string) {.multisync.} =
  ## Validate a ListenBrainz token given a ListenBrainz object and token
  if lbToken != "":
    let result = await lb.validateToken(lbToken)
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
