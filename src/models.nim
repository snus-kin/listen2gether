import norm/[model, sqlite]
import frosty
import types


let DBLOCATION = "listen2gether.db"


type
  TrackMetadataTable = ref object of Model
    trackMetadata: string

  ListenTable = ref object of Model
    listen: string
    trackMetadata: TrackMetadataTable


func newTrackMetadataTable(track = ""): TrackMetadataTable =
  TrackMetadataTable(trackMetadata: track)


func newListenTable(listen = "",
  track = newTrackMetadataTable()): ListenTable =
  ListenTable(listen: listen, trackMetadata: track)


proc openDbConn*(dbLocation = DBLOCATION): DbConn =
  result = open(dbLocation, "", "", "")


proc closeDbConn*(db: DbConn) =
  db.closeDbConn()


proc insertTables*(db: DbConn) =
  db.createTables(newListenTable())


proc insertListen*(db: DbConn,
  listen: Listen) =
  var 
    trackMetadata = newTrackMetadataTable(freeze(listen.trackMetadata))
    listen = newListenTable(freeze(listen), trackMetadata)
  db.insert(listen)


#proc getListen*(db: DbConn, ): Listen = 