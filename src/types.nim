import options

## Types

type
  User* = ref object
    user_name*: string
    lfmSessionKey*, lbToken*: Option[string]

  SubmissionPayload* = ref object
    listen_type*: string
    payload*: seq[Listen]

  ListenPayload* = ref object
    count*: int
    latest_listen_ts*: Option[int64]
    listens*: seq[Listen]
    playing_now*: Option[bool]
    user_id*: string

  Listen* = ref object
    inserted_at*, recording_msid*: Option[string]
    listened_at*: Option[int64]
    track_metadata*: TrackMetadata
  
  TrackMetadata* = ref object
    track_name*, artist_name*: string
    release_name*: Option[string]
    additional_info*: Option[AdditionalInfo]
  
  AdditionalInfo* = ref object
    tracknumber*: Option[int]
    artist_msid*, track_mbid*, recording_mbid*, release_group_mbid*, release_mbid*, release_msid*, recording_msid*, isrc*, spotify_id*, listening_from*: Option[string]
    tags*, artist_mbids*, word_mbids*: Option[seq[string]]


func newUser*(
  user_name: string,
  lfmSessionKey, lbToken: Option[string] = none(string)): User =
  ## Create new User object
  new(result)
  result.user_name = user_name
  result.lfmSessionKey = lfmSessionKey
  result.lbToken = lbToken


func newSubmissionPayload*(
  listen_type: string,
  payload: seq[Listen]): SubmissionPayload =
  ## Create new SubmissionPayload object
  new(result)
  result.listen_type = listen_type
  result.payload = payload


func newListenPayload*(
  count: int,
  latest_listen_ts: Option[int64] = none(int64),
  listens: seq[Listen],
  playing_now: Option[bool] = none(bool),
  user_id: string): ListenPayload =
  ## Create new ListenPayload object
  new(result)
  result.count = count
  result.latest_listen_ts = latest_listen_ts
  result.listens = listens
  result.playing_now = playing_now
  result.user_id = user_id


func newListen*(
  inserted_at, recording_msid: Option[string] = none(string),
  listened_at: Option[int64] = none(int64),
  track_metadata: TrackMetadata): Listen =
  ## Create new Listen object
  new(result)
  result.inserted_at = inserted_at
  result.listened_at = listened_at
  result.recording_msid = recording_msid
  result.track_metadata = track_metadata


func newTrackMetadata*(
  track_name, artist_name: string,
  release_name: Option[string] = none(string),
  additional_info: Option[AdditionalInfo] = none(AdditionalInfo)): TrackMetadata =
  ## Create new TrackMetadata object
  new(result)
  result.track_name = track_name
  result.artist_name = artist_name
  if not release_name.isNone:
    result.release_name = release_name
  if not additional_info.isNone:
    result.additional_info = additional_info


func newAdditionalInfo*(
  tracknumber: Option[int] = none(int),
  artist_msid, track_mbid, recording_mbid, release_group_mbid, release_mbid, release_msid, recording_msid, isrc, spotify_id, listening_from: Option[string] = none(string),
  tags, artist_mbids, word_mbids: Option[seq[string]] = none(seq[string])): AdditionalInfo =
  ## Create new Track object
  new(result)
  result.tracknumber = tracknumber
  result.artist_msid = artist_msid
  result.track_mbid = track_mbid
  result.recording_mbid = recording_mbid
  result.release_group_mbid = release_group_mbid
  result.release_mbid = release_mbid
  result.release_msid = release_msid
  result.recording_msid = recording_msid
  result.isrc = isrc
  result.spotify_id = spotify_id
  result.listening_from = listening_from
  result.tags = tags
  result.artist_mbids = artist_mbids
  result.word_mbids = word_mbids