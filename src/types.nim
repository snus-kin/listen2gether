## Types
import lastfm

type 
  User* = object
    username: string
    lfmSession: LastFMSession
    lbAuthToken: string
