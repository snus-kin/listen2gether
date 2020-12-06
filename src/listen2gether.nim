## Main process
import asyncdispatch, os, json
import listenbrainz
import listenbrainz/[core]
import types, scrobbling, utils

let
  lfmKeyFile = readFile("keys.json").parseJson
  lfmApiKey = lfmKeyFile["apiKey"].getStr
  lfmApiSecret = lfmKeyFile["secret"].getStr


# temporarily set mirrored lb user to be 'tandy1000' for debug, this will be set
# by the user
when isMainModule:
  let
    clientUser = newUser("tandy1000", lbToken=getEnv("lbToken"))
    mirroredUser = newUser("test")
    lb = newSyncListenBrainz(clientUser.lbToken)
  lb.validateLbToken(clientUser.lbToken)
  let track = lb.getCurrentTrack(mirroredUser)
  let submission = lb.listenTrack(clientUser, track)
  # then put into scrobbling module to scrobble
  # this will make it into the lfm/lb payload format then it can be sent w/ the respective api