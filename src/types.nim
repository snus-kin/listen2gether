## Types
import lastfm, listenbrainz

type 
  User* = ref object
    username*: string
    lfm*: AsyncLastFM | SyncLastFM
    lb*: AsyncListenBrainz | SyncListenBrainz
  

  Track* = ref object
    name: string
    artist: string
    album: string


# new last.fm user
proc newUser*(username, apiKey, apiSecret: string): User =
  return User(username: username,
              lfm: newAsyncLastFM(apiKey, apiSecret))

# new listenbrainz user
proc newUser*(username, lbToken: string): User =
  return User(username: username,
              lb: newAsyncListenBrainz(lbToken))