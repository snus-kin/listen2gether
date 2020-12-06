import asyncdispatch, json
import listenbrainz
import listenbrainz/[core]
import types

proc validateLbToken*(
  lb: SyncListenBrainz | AsyncListenBrainz,
  lbToken: string) {.multisync.} =
  if lbToken != "":
    let result = await lb.validateToken(lbToken)
    if result["code"].getInt != 200:
      raise newException(ValueError, "ERROR: Invalid token (or perhaps you are rate limited)")
  else:
    raise newException(ValueError, "ERROR: Token is empty string.")


proc listenToTrack(listen: JsonNode): Track =
  new(result)
  result.track_name = $listen["track_metadata"]["track_name"]
  result.artist_name = $listen["track_metadata"]["artist_name"]
  if listen["track_metadata"].contains("release_name"):
    result.release_name = $listen["track_metadata"]["release_name"]
  if listen["track_metadata"]["additional_info"].contains("recording_mbid"):
    result.track_mbid = $listen["track_metadata"]["additional_info"]["recording_mbid"]
  if listen["track_metadata"]["additional_info"].contains("artist_mbid"):
    result.artist_mbid = $listen["track_metadata"]["additional_info"]["artist_mbid"]
  if listen["track_metadata"]["additional_info"].contains("release_mbid"):
    result.release_mbid = $listen["track_metadata"]["additional_info"]["release_mbid"]


proc getCurrentTrack*(
  lb: SyncListenBrainz | AsyncListenBrainz,
  user: User): Future[Track] {.multisync.} =
  let recentListens = await getUsersRecentListens(lb, @[user.username])
  return listenToTrack(recentListens["payload"]["listens"][0])