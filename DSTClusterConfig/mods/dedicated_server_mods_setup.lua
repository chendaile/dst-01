--There are two functions that will install mods, ServerModSetup and ServerModCollectionSetup. Put the calls to the functions in this file and they will be executed on boot.

--ServerModSetup takes a string of a specific mod's Workshop id. It will download and install the mod to your mod directory on boot.
	--The Workshop id can be found at the end of the url to the mod's Workshop page.
	--Example: http://steamcommunity.com/sharedfiles/filedetails/?id=350811795
	--ServerModSetup("350811795")

--ServerModCollectionSetup takes a string of a specific mod's Workshop id. It will download all the mods in the collection and install them to the mod directory on boot.
	--The Workshop id can be found at the end of the url to the collection's Workshop page.
	--Example: http://steamcommunity.com/sharedfiles/filedetails/?id=379114180
	--ServerModCollectionSetup("379114180")
	

-- Auto-download is DISABLED on purpose.
-- The in-game Workshop downloader kept timing out on some of these mods (EResult 16),
-- so they are provided as LOCAL mods in server_dst/mods/workshop-<id>/ (./volumes/mods on
-- the host), fetched deterministically with steamcmd, and enabled via modoverrides.lua.
-- Re-enable a line below only if you want the server to auto-download that mod again.

-- Global Positions    https://steamcommunity.com/sharedfiles/filedetails/?id=378160973
-- ServerModSetup("378160973")

-- Extra Equip Slots   https://steamcommunity.com/sharedfiles/filedetails/?id=375850593
-- ServerModSetup("375850593")

-- Health Info         https://steamcommunity.com/sharedfiles/filedetails/?id=375859599
-- ServerModSetup("375859599")

-- Food Values         https://steamcommunity.com/sharedfiles/filedetails/?id=458940297
-- ServerModSetup("458940297")
