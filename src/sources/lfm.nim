import options

type
  FMTrack* = ref object
    artist*, album*: FMObject
    mbid*, name*, url*: string
    streamable*: bool
    attr: Option[Attributes]

  FMObject* = ref object
    mbid*, text*: string

  Attributes* = ref object
    nowplaying*: bool

  Scrobble* = ref object
    track*, artist*: string
    album*, mbid*, albumArtist*: Option[string]
    trackNumber*, duration*: Option[int]


func newFMTrack*(
  artist, album: FMObject,
  mbid, name, url: string,
  streamable: bool,
  attr: Option[Attributes] = none(Attributes)): FMTrack = 
  ## Create new `FMTrack` object
  new(result)
  result.artist = artist
  result.album = album
  result.mbid = mbid
  result.name = name
  result.url = url
  result.streamable = streamable
  result.attr = attr


func newFMObject*(
  mbid, text: string): FMObject = 
  ## Create new `FMObject` object
  new(result)
  result.mbid = mbid
  result.text = text


func newAttributes*(
  nowplaying: bool): Attributes =
  new(result)
  result.nowplaying = nowplaying


func newScrobble*(
  track, artist: string,
  album, mbid, albumArtist: Option[string] = none(string),
  trackNumber, duration: Option[int] = none(int)): Scrobble =
  ## Create new `Scrobble` object
  new(result)
  result.track = track
  result.artist = artist
  result.album = album
  result.mbid = mbid
  result.albumArtist = albumArtist
  result.trackNumber = trackNumber
  result.duration = duration