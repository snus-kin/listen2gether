import asyncdispatch, jsony, json, strutils
import listenbrainz
#import listenbrainz/[core]
import types


proc listenPayloadToSubmissionPayload*(
  listenPayload: ListenPayload,
  listenType: string): SubmissionPayload =
  ## Generate ListenBrainz listen payload
  result = newSubmissionPayload(listenType, listenPayload.listens)


proc getCurrentTrack*(
  lb: SyncListenBrainz | AsyncListenBrainz,
  user: User): Future[ListenPayload] {.multisync.} =
  ## Get a user's last listened to track
  let recentListens = await lb.getUserListens(user.user_name, count=1)
  if recentListens["payload"]["count"].getInt == 0:
    raise newException(ValueError, "ERROR: User has no recent listens!")
  result = fromJson($recentListens["payload"], ListenPayload)


proc listenTrack*(
  lb: SyncListenBrainz | AsyncListenBrainz,
  listenPayload: ListenPayload,
  listenType: string): Future[JsonNode] {.multisync.} =
  ## submit a listen to ListenBrainz
  let
    payload = listenPayloadToSubmissionPayload(listenPayload, listenType)
    jsonBody = %* payload.toJson()
  result = await lb.submitListens(jsonBody)


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
