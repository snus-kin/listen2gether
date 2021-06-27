import asyncdispatch, json, options, jsony, strutils
import listenbrainz, lastfm
import lastfm/[user, track]
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


type Node = ref object
  kind: string

proc renameHook*(v: var Node, fieldName: var string) =
  if fieldName == "@attr":
    fieldName = "attr"
  elif fieldName == "#text":
    fieldName = "text"

## Last.FM

## TODO
## get playing now / last played

proc to*(fmTrack: FMTrack): Track = 
  ## Convert an `FMTrack` to a `Track`
  result = newTrack(trackName = fmTrack.name,
                    artistName = fmTrack.artist.text,
                    releaseName = some(fmTrack.album.text),
                    recordingMbid = some(fmTrack.mbid),
                    releaseMbid = some(fmTrack.album.mbid),
                    artistMbids = some(@[fmTrack.artist.mbid]))


proc to*(scrobble: Scrobble): Track = 
  ## Convert an `Scrobble` to a `Track`
  result = newTrack(trackName = scrobble.track,
                    artistName = scrobble.artist,
                    releaseName = scrobble.album,
                    artistMbids = some(@[get(scrobble.mbid)]),
                    trackNumber = scrobble.trackNumber,
                    duration = scrobble.duration)


proc getRecentTracks*(
  fm: SyncLastFM | AsyncLastFM,
  user: User) {.multisync.} =
  ## Get now playing for a Last.FM user
  let
    recentTracks = await fm.userRecentTracks(user = user.username, limit = 1)
    tracks = recentTracks["track"]
  if tracks.len == 1:
    user.lastPlayed = some(to(fromJson($tracks[0], FMTrack)))
  elif tracks.len == 2:
    user.playingNow = some(to(fromJson($tracks[0], FMTrack)))
    user.lastPlayed = some(to(fromJson($tracks[1], FMTrack)))
  else:
    echo "User has no recent tracks!"


proc setNowPlaying*(
  fm: SyncLastFM | AsyncLastFM,
  scrob: Scrobble): Future[JsonNode] {.multisync.} =
  ## Sets the current playing track on Last.FM
  result = await fm.setNowPlaying(track = scrob.track,
                                  artist = scrob.artist,
                                  album = scrob.album,
                                  mbid = scrob.mbid,
                                  albumArtist = scrob.albumArtist,
                                  trackNumber = scrob.trackNumber,
                                  duration = scrob.duration)


proc scrobbleTrack*(
  fm: SyncLastFM | AsyncLastFM,
  scrob: Scrobble): Future[JsonNode] {.multisync.} = 
  ## Scrobble a track to Last.FM
  result = await fm.scrobble(track = scrob.track,
                              artist = scrob.artist,
                              album = scrob.album,
                              mbid = scrob.mbid,
                              albumArtist = scrob.albumArtist,
                              trackNumber = scrob.trackNumber,
                              duration = scrob.duration)


## ListenBrainz

proc to*(listen: Listen): Track =
  ## Convert a `Listen` object to a `Track` object
  result = newTrack(trackName = listen.trackMetadata.trackName,
                    artistName = listen.trackMetadata.artistName,
                    releaseName = listen.trackMetadata.releaseName,
                    recordingMbid = get(listen.trackMetadata.additionalInfo).recordingMbid,
                    releaseMbid = get(listen.trackMetadata.additionalInfo).releaseMbid,
                    artistMbids = get(listen.trackMetadata.additionalInfo).artistMbids,
                    trackNumber = get(listen.trackMetadata.additionalInfo).trackNumber)


proc to*(
  listenPayload: ListenPayload,
  listenType: string): SubmissionPayload =
  ## Convert a `ListenPayload` object to a `SubmissionPayload` object
  result = newSubmissionPayload(listenType, listenPayload.listens)


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


proc getNowPlaying*(
  lb: SyncListenBrainz | AsyncListenBrainz,
  user: User) {.multisync.} =
  ## Get a ListenBrainz user's now playing
  let
    nowPlaying = await lb.getUserPlayingNow(user.username)
    listen = fromJson($nowPlaying["payload"], ListenPayload)
  if listen.listens != @[]:
    user.playingNow = some(to(listen.listens[0]))


proc getCurrentTrack*(
  lb: SyncListenBrainz | AsyncListenBrainz,
  user: User) {.multisync.} =
  ## Get a user's last listened track
  let
    recentListens = await lb.getUserListens(user.userName, count=1)
    listenPayload = fromJson($recentListens["payload"], ListenPayload)  
  if listenPayload.count == 0:
    user.lastPlayed = none(Track)
    raise newException(ValueError, "ERROR: User has no recent listens!")
  else:
    user.lastPlayed = some(to(listenPayload.listens[0]))


proc listenTrack*(
  lb: SyncListenBrainz | AsyncListenBrainz,
  listenPayload: ListenPayload,
  listenType: string): Future[JsonNode] {.multisync.} =
  ## Submit a listen to ListenBrainz
  let
    payload = to(listenPayload, listenType)
    jsonBody = %* payload.toJson()
  result = await lb.submitListens(jsonBody)