## Main process
import os, json
import listenbrainz
import listenbrainz/[core]
import types, scrobbling, utils

let
  lfmKeyFile = readFile("keys.json").parseJson
  lfmApiKey = lfmKeyFile["apiKey"].getStr
  lfmApiSecret = lfmKeyFile["secret"].getStr


# temporarily set mirrored lb user to be 'snufkin' for debug, this will be set
# by the user
let
  mirroringUser = "tandy1000"
  mirroredUser = "snufkin"


when isMainModule:
  echo mirroredUser
  let
    user = newUser(mirroringUser, lbToken=getEnv("lbToken"))
    lb = newSyncListenBrainz(user.lbToken)

  if lb.validateToken(user.lbToken)["code"].getInt != 200:
    raise newException(ValueError, "ERROR: Invalid token (or perhaps you are rate limited)")
  
  let track = getCurrentTrack(lb, user)
  
  # then put into scrobbling module to scrobble
  # this will make it into the lfm/lb payload format then it can be sent w/ the respective api