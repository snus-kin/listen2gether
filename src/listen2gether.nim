## Main process
import os, json
import types, scrobbling
import listenbrainz

# temporarily set mirrored lb user to be 'snufkin' for debug, this will be set
# by the user
let mirroredUser = "snufkin"

when isMainModule:
  echo mirroredUser
  let user = newUser("testuser", getEnv("lbToken"))
  if user.lb.validateToken["code"].getInt != 200:
    raise newException(ValueError, "ERROR: Invalid token (or perhaps you are rate limited)")
  
  let toMirror = user.lb.getUsersRecentListens(@[mirroredUser])["payload"]["listens"][0]
  # then make this a Track object
  # then put into scrobbling module to scrobble
  #   this will make it into the lfm/lb payload format then it can be sent w/ the respective api
  echo pretty toMirror
