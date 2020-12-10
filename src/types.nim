## Types

type
  User* = ref object
    username*, lfm_session_key*, lb_token*: string

  Listen* = ref object
    listened_at*: int64
    track*: Track
    playing_now*: bool
    listen_type*, listening_from*: string 

  Track* = ref object
    track_name*, artist_name*, release_name*, tracknumber*, track_mbid*, recording_mbid*, release_mbid*, release_group_mbid*, artist_msid*, recording_msid*, release_msid*, isrc*, spotify_id*: string
    tags*, artist_mbids*, word_mbids*: seq[string]


func newUser*(username: string,
  lfm_session_key, lb_token: string = ""): User =
  ## Create new User object
  new(result)
  result.username = username
  result.lfm_session_key = lfm_session_key
  result.lb_token = lb_token

func newListen*(listened_at: int64,
  track: Track,
  playing_now: bool = false,
  listen_type: string = "single",
  listening_from: string = "Listen2gether"): Listen =
  ## Create new Listen object
  new(result)
  result.listened_at = listened_at
  result.playing_now = playing_now
  result.track = track
  result.listen_type = listen_type
  result.listening_from = listening_from

func newTrack*(track_name, artist_name: string,
  release_name, tracknumber, track_mbid, recording_mbid, release_mbid, release_group_mbid, artist_msid, recording_msid, release_msid, isrc, spotify_id: string = "",
  tags, artist_mbids, word_mbids: seq[string] = @[""]): Track =
  ## Create new Track object
  new(result)
  result.track_name = track_name
  result.artist_name = artist_name
  result.release_name = release_name
  result.tracknumber = tracknumber
  result.track_mbid = track_mbid
  result.recording_mbid = recording_mbid
  result.release_mbid = release_mbid
  result.release_group_mbid = release_group_mbid
  result.artist_msid = artist_msid
  result.recording_msid = recording_msid
  result.release_msid = release_msid
  result.isrc = isrc
  result.spotify_id = spotify_id
  result.tags = tags
  result.artist_mbids = artist_mbids
  result.word_mbids = word_mbids