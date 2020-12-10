# Package

version       = "0.1.0"
author        = "snus-kin & tandy-1000"
description   = "Sync your listens on Last.fm and ListenBrainz with other people "
license       = "AGPLv3.0"
srcDir        = "src"
bin           = @["listen2gether"]



# Dependencies

requires "nim >= 1.2.2"
requires "https://gitlab.com/tandy1000/listenbrainz-nim"
requires "norm"

#requires "https://gitlab.com/tandy1000/lastfm-nim"
