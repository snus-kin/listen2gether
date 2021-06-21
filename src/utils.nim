import asyncdispatch, json, options, jsony, strutils
import listenbrainz
#import listenbrainz/[core]
import types


proc camel2snake*(s: string): string =
  ## CanBeFun => can_be_fun
  ## https://forum.nim-lang.org/t/1701
  result = newStringOfCap(s.len)
  for i in 0..<len(s):
    if s[i] in {'A'..'Z'}:
      if i > 0:
        result.add('_')
      result.add(chr(ord(s[i]) + (ord('a') - ord('A'))))
    else:
      result.add(s[i])


template dumpKey(s: var string, v: string) =
  const v2 = v.camel2snake().toJson() & ":"
  s.add v2


proc dumpHook*[T](s: var string, v: Option[T]) =
  if v.isSome:
    s.dumpHook(v.get())


proc dumpHook*(s: var string, v: object) =
  s.add '{'
  var i = 0
  when compiles(for k, e in v.pairs: discard):
    # Tables and table like objects.
    for k, e in v.pairs:
      if i > 0:
        s.add ','
      s.dumpHook(k)
      s.add ':'
      s.dumpHook(e)
      inc i
  else:
    # Normal objects.
    for k, e in v.fieldPairs:
      when compiles(e.isSome):
        if e.isSome:
          if i > 0:
            s.add ','
          s.dumpKey(k)
          s.dumpHook(e)
          inc i
      else:
        if i > 0:
          s.add ','
        s.dumpKey(k)
        s.dumpHook(e)
        inc i
  s.add '}'


proc listenPayloadToSubmissionPayload*(
  listenPayload: ListenPayload,
  listenType: string): SubmissionPayload =
  ## Generate ListenBrainz listen payload
  result = newSubmissionPayload(listenType, listenPayload.listens)


proc getCurrentTrack*(
  lb: SyncListenBrainz | AsyncListenBrainz,
  user: User): Future[ListenPayload] {.multisync.} =
  ## Get a user's last listened to track
  let recentListens = await lb.getUserListens(user.userName, count=1)
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
