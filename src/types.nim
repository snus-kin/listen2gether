import times, options

## Types

type
  User* = ref object
    username*: string
    lfmSessionKey*, lbToken*: Option[string]

  ListenPayload* = ref object
    count*: int
    latestListenTS*: Option[int64]
    listens*: seq[Listen]
    listenType*: Option[string]

  Listen* = ref object
    insertedAt*: Option[Time]
    listenedAt*: Option[int64]
    recordingMSID*: Option[string]
    trackMetadata*: TrackMetadata
    playingNow*: Option[bool]
    username*: string

  TrackMetadata* = ref object
    trackName*, artistName*: string
    releaseName*: Option[string]
    additionalInfo*: Option[AdditionalInfo]
  
  AdditionalInfo* = ref object
    trackNumber*: Option[int]
    artistMSID*, trackMBID*, recordingMBID*, releaseGroupMBID*, releaseMBID*, releaseMSID*, recordingMSID*, isrc*, spotifyID*, listeningFrom*: Option[string]
    tags*, artistMBIDs*, wordMBIDs*: Option[seq[string]]


func newUser*(
  username: string,
  lfmSessionKey, lbToken: Option[string]): User =
  ## Create new User object
  new(result)
  result.username = username
  result.lfmSessionKey = lfmSessionKey
  result.lbToken = lbToken


func newListenPayload*(
  count: int,
  latestListenTS: Option[int64],
  listens: seq[Listen],
  listenType: Option[string]): ListenPayload =
  ## Create new ListenPayload object
  new(result)
  result.count = count
  result.latestListenTS = latestListenTS
  result.listens = listens
  result.listenType = listenType


func newListen*(
  insertedAt: Option[Time],
  listenedAt: Option[int64],
  recordingMSID: Option[string],
  trackMetadata: TrackMetadata,
  playingNow: Option[bool],
  username: string): Listen =
  ## Create new Listen object
  new(result)
  result.insertedAt = insertedAt
  result.listenedAt = listenedAt
  result.recordingMSID = recordingMSID
  result.trackMetadata = trackMetadata
  result.playingNow = playingNow
  result.username = username


func newTrackMetadata*(
  trackName, artistName: string,
  releaseName: Option[string],
  additionalInfo: Option[AdditionalInfo]): TrackMetadata =
  ## Create new TrackMetadata object
  new(result)
  result.trackName = trackName
  result.artistName = artistName
  result.releaseName = releaseName
  result.additionalInfo = additionalInfo


func newAdditionalInfo*(
  trackNumber: Option[int],
  artistMSID, trackMBID, recordingMBID, releaseGroupMBID, releaseMBID, releaseMSID, recordingMSID, isrc, spotifyID, listeningFrom: Option[string],
  tags, artistMBIDs, wordMBIDs: Option[seq[string]]): AdditionalInfo =
  ## Create new Track object
  new(result)
  result.trackNumber = trackNumber
  result.artistMSID = artistMSID
  result.trackMBID = trackMBID
  result.recordingMBID = recordingMBID
  result.releaseGroupMBID = releaseGroupMBID
  result.releaseMBID = releaseMBID
  result.releaseMSID = releaseMSID
  result.recordingMSID = recordingMSID
  result.isrc = isrc
  result.spotifyID = spotifyID
  result.listeningFrom = listeningFrom
  result.tags = tags
  result.artistMBIDs = artistMBIDs
  result.wordMBIDs = wordMBIDs