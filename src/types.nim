import options

## Types

type
  User* = ref object
    username*: string
    lfmSessionKey*, lbToken*: Option[string]

  SubmissionPayload* = ref object
    listenType*: string
    payload*: seq[Listen]

  ListenPayload* = ref object
    count*: int
    latestListenTs*: Option[int64]
    listens*: seq[Listen]
    playingNow*: Option[bool]
    userId*: string

  Listen* = ref object
    insertedAt*, recordingMsid*: Option[string]
    listenedAt*: Option[int64]
    trackMetadata*: TrackMetadata
  
  TrackMetadata* = ref object
    trackName*, artistName*: string
    releaseName*: Option[string]
    additionalInfo*: Option[AdditionalInfo]
  
  AdditionalInfo* = ref object
    tracknumber*: Option[int]
    trackMbid*, recordingMbid*, releaseGroupMbid*, releaseMbid*, artistMsid*, releaseMsid*, recordingMsid*, isrc*, spotifyId*, listeningFrom*: Option[string]
    tags*, artistMbids*, workMbids*: Option[seq[string]]


func newUser*(
  username: string,
  lfmSessionKey, lbToken: Option[string] = none(string)): User =
  ## Create new User object
  new(result)
  result.username = username
  result.lfmSessionKey = lfmSessionKey
  result.lbToken = lbToken


func newSubmissionPayload*(
  listenType: string,
  payload: seq[Listen]): SubmissionPayload =
  ## Create new SubmissionPayload object
  new(result)
  result.listenType = listenType
  result.payload = payload


func newListenPayload*(
  count: int,
  latestListenTs: Option[int64] = none(int64),
  listens: seq[Listen],
  playingNow: Option[bool] = none(bool),
  userId: string): ListenPayload =
  ## Create new ListenPayload object
  new(result)
  result.count = count
  result.latestListenTs = latestListenTs
  result.listens = listens
  result.playingNow = playingNow
  result.userId = userId


func newListen*(
  insertedAt, recordingMsid: Option[string] = none(string),
  listenedAt: Option[int64] = none(int64),
  trackMetadata: TrackMetadata): Listen =
  ## Create new Listen object
  new(result)
  result.insertedAt = insertedAt
  result.listenedAt = listenedAt
  result.recordingMsid = recordingMsid
  result.trackMetadata = trackMetadata


func newTrackMetadata*(
  trackName, artistName: string,
  releaseName: Option[string] = none(string),
  additionalInfo: Option[AdditionalInfo] = none(AdditionalInfo)): TrackMetadata =
  ## Create new TrackMetadata object
  new(result)
  result.trackName = trackName
  result.artistName = artistName
  if not releaseName.isNone:
    result.releaseName = releaseName
  if not additionalInfo.isNone:
    result.additionalInfo = additionalInfo


func newAdditionalInfo*(
  tracknumber: Option[int] = none(int),
  artistMsid, trackMbid, recordingMbid, releaseGroupMbid, releaseMbid, releaseMsid, recordingMsid, isrc, spotifyId, listeningFrom: Option[string] = none(string),
  tags, artistMbids, workMbids: Option[seq[string]] = none(seq[string])): AdditionalInfo =
  ## Create new Track object
  new(result)
  result.tracknumber = tracknumber
  result.artistMsid = artistMsid
  result.trackMbid = trackMbid
  result.recordingMbid = recordingMbid
  result.releaseGroupMbid = releaseGroupMbid
  result.releaseMbid = releaseMbid
  result.releaseMsid = releaseMsid
  result.recordingMsid = recordingMsid
  result.isrc = isrc
  result.spotifyId = spotifyId
  result.listeningFrom = listeningFrom
  result.tags = tags
  result.artistMbids = artistMbids
  result.workMbids = workMbids