---
-- Main worldgen file. Run through modworldgenmain.lua.
--
-- @author debugman18
-- @author simplex



BindModModule 'modenv'
-- This just enables syntax conveniences.
BindTheMod()

-- These embed the corresponding methods in TheMod.
wickerrequire 'api.plugins.addtile'
wickerrequire 'api.plugins.addsaveindexpostinit'


modrequire('api_abstractions')()


LoadConfiguration "tuning.lua"
LoadConfiguration "rc.defaults.lua"
if _G.kleifileexists(MODROOT .. "rc.lua") then LoadConfiguration "rc.lua" end
if _G.kleifileexists(MODROOT .. "dev.rc.defaults.lua") then LoadConfiguration "dev.rc.defaults.lua" end
if _G.kleifileexists(MODROOT .. "dev.rc.lua") then LoadConfiguration "dev.rc.lua" end


----------------------------------
-- Custom Level mod example
--
--
--
--  AddLevel(newlevel)
--		Inserts a new level into the list of possible levels. This will cause the level
--		to show up in Customization -> Presets if it's a survival level, or into the
--		random playlist if it's an adventure level.
--
--	AddLevelPreInit("levelname", initfn)
--		Gets the raw data for a level before it's processed, allowing for modifications
--		to its tasks, overrides, etc.
--
--	AddLevelPreInitAny(initfn)
--		Same as above, but will apply to any level that gets generated, always.
--
--	AddTask(newtask)
--		Inserts a task into the master tasklist, which can then be used by new or modded
--		levels in their "tasks".
--
--	AddTaskPreInit("taskname", initfn)
--		Gets the raw data for a task before it's processed, allowing for modifications to
--		its rooms and locks.
--
--	AddRoom(newroom)
--		Inserts a room into the master roomlist, which can then be used by new or moded
--		tasks in their "room_choices".
--
--	AddRoomPreInit("roomname", initfn)
--		Gets the raw data for a room before it's processed, allowing for modifications to
--		its prefabs, layouts, and tags.
--
-----------------------------------

modrequire 'map.tiledefs'

if GetConfig "DISABLE_CUSTOM_TILES" then
	for _, tilename in ipairs(GetConfig "NEW_TILES") do
		GROUND[tilename:upper()] = GROUND.ROCKY
	end
end

modrequire 'map.layouts'
modrequire 'map.rooms'
modrequire 'map.tasks'
modrequire 'map.levels'

--This also does the following.
local TRANSLATE_TO_PREFABS = GLOBAL.require("map/forest_map").TRANSLATE_TO_PREFABS
TRANSLATE_TO_PREFABS["skyflowers"] = {"skyflower"}
TRANSLATE_TO_PREFABS["sheep"] = {"sheep"}
TRANSLATE_TO_PREFABS["cloud_bush"] = {"cloud_bush"}
TRANSLATE_TO_PREFABS["hive_marshmallow"] = {"hive_marshmallow"}
TRANSLATE_TO_PREFABS["bee_marshmallow"] = {"bee_marshmallow"}
TRANSLATE_TO_PREFABS["goose"] = {"goose"}
TRANSLATE_TO_PREFABS["cloudcrag"] = {"cloudcrag"}
TRANSLATE_TO_PREFABS["skyflies"] = {"skyflies"}
TRANSLATE_TO_PREFABS["crystal_relic"] = {"crystal_relic"}

local Layouts = GLOBAL.require("map/layouts").Layouts
local StaticLayout = GLOBAL.require("map/static_layout")

-- We'll just use an existing layout here, but feel free to add your own in a
-- scripts/map/static_layouts folder.
Layouts["ShopkeeperStall"] = StaticLayout.Get("map/static_layouts/shopkeeper_stall")
-- Add this layout to every "forest" room in the game
AddRoomPreInit("Graveyard", function(room)
	if not room.contents.countstaticlayouts then
		room.contents.countstaticlayouts = {}
	end
	room.contents.countstaticlayouts["ShopkeeperStall"] = 1
end)
