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
  let lb = user.lb

  echo pretty lb.validateToken()

  if lb.validateToken["code"].getInt != 200:
    raise newException(ValueError, "ERROR: Invalid token (or perhaps you are rate limited)")
