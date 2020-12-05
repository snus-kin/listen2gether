## Types

type
  User* = ref object
    username*, lfmSessionKey*, lbToken*: string

  Track* = ref object
    track_name*, artist_name*, release_name* : string
    track_mbid*, artist_mbid*, release_mbid*: string

proc newUser*(username: string,
  lfmSessionKey, lbToken: string = ""): User =
  ## new user
  new(result)
  result.username = username
  result.lfmSessionKey = lfmSessionKey
  result.lbToken = lbToken


proc newTrack*(track_name, artist_name: string,
  release_name, track_mbid, artist_mbid, release_mbid: string = ""): Track =
  ## new track
  new(result)
  result.track_name = track_name
  result.artist_name = artist_name
  result.release_name = release_name
  result.track_mbid = track_mbid
  result.artist_mbid = artist_mbid
  result.release_mbid = release_mbid