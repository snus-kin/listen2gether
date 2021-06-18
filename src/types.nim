## Types

type
  User* = ref object
    username*, lfmSessionKey*, lbToken*: string

  Listen* = ref object
    listenedAt*: int64
    track*: Track
    playingNow*: bool
    listenType*, listeningFrom*: string 

  Track* = ref object
    trackName*, artistName*, releaseName*, trackNumber*, trackMBID*, recordingMBID*, releaseMBID*, releaseGroupMBID*, artistMSID*, recordingMSID*, releaseMSID*, isrc*, spotifyID*: string
    tags*, artistMBIDs*, wordMBIDs*: seq[string]


func newUser*(username: string,
  lfmSessionKey, lbToken: string = ""): User =
  ## Create new User object
  new(result)
  result.username = username
  result.lfmSessionKey = lfmSessionKey
  result.lbToken = lbToken

func newListen*(listenedAt: int64,
  track: Track,
  playingNow: bool = false,
  listenType: string = "single",
  listeningFrom: string = "Listen2gether"): Listen =
  ## Create new Listen object
  new(result)
  result.listenedAt = listenedAt
  result.playingNow = playingNow
  result.track = track
  result.listenType = listenType
  result.listeningFrom = listeningFrom

func newTrack*(trackName, artistName: string,
  releaseName, trackNumber, trackMBID, recordingMBID, releaseMBID, releaseGroupMBID, artistMSID, recordingMSID, releaseMSID, isrc, spotifyID: string = "",
  tags, artistMBIDs, wordMBIDs: seq[string] = @[""]): Track =
  ## Create new Track object
  new(result)
  result.trackName = trackName
  result.artistName = artistName
  result.releaseName = releaseName
  result.trackNumber = trackNumber
  result.trackMBID = trackMBID
  result.recordingMBID = recordingMBID
  result.releaseMBID = releaseMBID
  result.releaseGroupMBID = releaseGroupMBID
  result.artistMSID = artistMSID
  result.recordingMSID = recordingMSID
  result.releaseMSID = releaseMSID
  result.isrc = isrc
  result.spotifyID = spotifyID
  result.tags = tags
  result.artistMBIDs = artistMBIDs
  result.wordMBIDs = wordMBIDs