import os, options
import listenbrainz
import models, types, utils

#[
let
  apiKey = os.getEnv("apiKey")
  apiSecret = os.getEnv("apiSecret")
]#

# temporarily set mirrored lb user to be 'tandy1000' for debug, this will be set
# by the user
when isMainModule:
  let db = openDbConn()
  db.insertTables()
  let
    clientUser = newUser("test", lbToken=some(getEnv("lbToken")))
    mirroredUser = newUser("tandy1000")
    lb = newSyncListenBrainz(get(clientUser.lbToken))
  lb.validateLbToken(get(clientUser.lbToken))
  let
    listen = lb.getCurrentTrack(mirroredUser)
    #submission = lb.listenTrack(listen, listenType="single")
  db.insertListen(listen.listens[0])