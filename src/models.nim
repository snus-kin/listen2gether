import norm/[model, sqlite]
import frosty
import types

let DBLOCATION = "listens.db"

type
  TrackTable = ref object of Model
    track: string

  ListenTable = ref object of Model
    listen: string
    track: TrackTable


func newTrackTable(track = ""): TrackTable =
  TrackTable(track: track)

func newListenTable(listen = "",
  track = newTrackTable()): ListenTable =
  ListenTable(listen: listen, track: track)


proc openDbConn*(dbLocation = DBLOCATION): DbConn =
  result = open(dbLocation, "", "", "")

proc closeDbConn*(db: DbConn) =
  db.closeDbConn()

proc insertTables*(db: DbConn) =
  db.createTables(newListenTable())

proc insertListen*(db: DbConn,
  listen: Listen) =
  var 
    track = newTrackTable(freeze(listen.track))
    listen = newListenTable(freeze(listen), track)
  db.insert(listen)

#proc getListen*(db: DbConn, ): Listen = 