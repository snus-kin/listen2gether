import os
import listenbrainz
import models, types, utils

#[
let
  lfm_keys = readFile("keys.json").parseJson
  lfm_key = lfm_keys["apiKey"].getStr
  lfm_secret = lfm_keys["secret"].getStr
]#

# temporarily set mirrored lb user to be 'tandy1000' for debug, this will be set
# by the user
when isMainModule:
  let db = openDbConn()
  db.insertTables()
  let
    clientUser = newUser("test", lbToken=getEnv("lbToken"))
    mirroredUser = newUser("tandy1000")
    lb = newSyncListenBrainz(clientUser.lbToken)
  lb.validateLbToken(clientUser.lbToken)
  let
    listen = lb.getCurrentTrack(mirroredUser)
    submission = lb.listenTrack(listen)
  db.insertListen(listen)
  db.closeDbConn()