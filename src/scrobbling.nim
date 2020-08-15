## Scrobbling functions for nim, ideally these are just generic procs that will
## work with both lfm and lb given an overload or something
## ```xml
##   <track nowplaying="true">
##    <artist mbid="2f9ecbed-27be-40e6-abca-6de49d50299e">Aretha Franklin</artist>
##    <name>Sisters Are Doing It For Themselves</name>
##    <mbid/>
##    <album mbid=""/>
##    <url>www.last.fm/music/Aretha+Franklin/_/Sisters+Are+Doing+It+For+Themselves</url>
##    <date uts="1213031819">9 Jun 2008, 17:16</date>
##    <streamable>1</streamable>
##  </track>
##```
##
##```json
## {
##   "inserted_at": "Sat, 15 Aug 2020 13:42:00 GMT",
##   "listened_at": 1597498920,
##   "recording_msid": "4cce6819-e5ee-461c-ba43-76aae03ac18c",
##   "track_metadata": {
##     "additional_info": {
##       "artist_msid": "bc768dae-df5e-40ee-857a-ca7d59c8db40",
##       "recording_msid": "4cce6819-e5ee-461c-ba43-76aae03ac18c",
##       "release_msid": "55766ac8-af00-4d41-b65e-a21889e0325a"
##     },
##     "artist_name": "TELOZKOPE",
##     "release_name": "Equanaimo",
##     "track_name": "☄∑motionswamp"
##   },
##   "user_name": "snufkin"
## }
##```
