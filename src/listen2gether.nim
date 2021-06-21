import os, json, jsony, options
import listenbrainz
#import models,
#import types, utils
import prologue
import prologue/middlewares/utils
import prologue/middlewares/staticfile
import ./urls


#[
let
  lfm_keys = readFile("keys.json").parseJson
  lfm_key = lfm_keys["apiKey"].getStr
  lfm_secret = lfm_keys["secret"].getStr
]#

# temporarily set mirrored lb user to be 'tandy1000' for debug, this will be set
# by the user
when isMainModule:
  #let db = openDbConn()
  #db.insertTables()

  let
    env = loadPrologueEnv(".env")
    settings = newSettings(appName = env.getOrDefault("appName", "Prologue"),
                  debug = env.getOrDefault("debug", true),
                  port = Port(env.getOrDefault("port", 8888)),
                  secretKey = env.getOrDefault("secretKey", "a")
      )

  # let
  #   clientUser = newUser("test", lbToken=some(getEnv("lbToken")))
  #   mirroredUser = newUser("tandy1000")
  #   lb = newSyncListenBrainz(get(clientUser.lbToken))
  # lb.validateLbToken(get(clientUser.lbToken))

  # let
  #   listen = lb.getCurrentTrack(mirroredUser)
  #   #submission = lb.listenTrack(listen)
    
  var app = newApp(settings = settings)

  app.use(staticFileMiddleware(env.getOrDefault("staticDir", "static")))
  app.use(debugRequestMiddleware())
  app.addRoute(urls.urlPatterns, "")
  app.run()

  #db.insertListen(listen)
  #db.closeDbConn()
