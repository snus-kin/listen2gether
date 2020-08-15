## Types
import lastfm, listenbrainz

type 
  User* = ref object
    username*: string
    lfmSession*: LastFMSession
    lb*: ListenBrainz
  

  Track* = ref object
    name: string
    artist: string
    album: string


proc newUser*(username: string, lbToken: string): User =
  return User(username: username,
              lb: newListenBrainz(lbToken))
