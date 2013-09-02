--[[
Copyright (C) 2013  simplex

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]--

--@@ENVIRONMENT BOOTUP
local _modname = assert( (assert(..., 'This file should be loaded through require.')):match('^[%a_][%w_%s]*') , 'Invalid path.' )
module( ..., require(_modname .. '.booter') )

--@@END ENVIRONMENT BOOTUP


require 'map/terrain'

local tiledefs = require 'worldtiledefs'
local GROUND = _G.GROUND
local GROUND_NAMES = _G.GROUND_NAMES

local resolvefilepath = _G.resolvefilepath

--[[
-- The return value from this function should be stored and
-- reused between saves (otherwise the tile information saved in the map may
-- become mismatched if the order of ground value generation changes).
--]]
local function getNewGroundValue(id)
	local used = {}

	for k, v in pairs(GROUND) do
		used[v] = true
	end

	local i = 1
	while used[i] and i < GROUND.UNDERGROUND do
		i = i + 1
	end

	if i >= GROUND.UNDERGROUND then
		-- The game assumes values greater than or equal to GROUND.UNDERGROUND
		-- represent walls.
		return error("No more values available!")
	end

	return i
end


-- Lists the structure for a tile specification by mapping the possible fields to their
-- default values.
local tile_spec_defaults = {
	noise_texture = "images/square.tex",
	runsound = "dontstarve/movement/run_dirt",
	walksound = "dontstarve/movement/walk_dirt",
	snowsound = "dontstarve/movement/run_ice",
}

-- Like the above, but for the minimap tile specification.
local mini_tile_spec_defaults = {
	name = "map_edge",
	noise_texture = "levels/textures/mini_dirt_noise.tex",
}

--[[
-- name should match the texture/atlas specification in levels/tiles.
-- (it's not just an arbitrary name, it defines the texture used)
--]]
function AddTile(id, numerical_id, name, specs, minispecs)
	assert( type(id) == "string" )
	assert( numerical_id == nil or type(numerical_id) == "number" )
	assert( type(name) == "string" )
	assert( GROUND[id] == nil, ("GROUND.%s already exists!"):format(id))

	specs = specs or {}
	minispecs = minispecs or {}

	assert( type(specs) == "table" )
	assert( type(minispecs) == "table" )

	-- Ideally, this should never be passed, and we would wither generate it or load it
	-- from savedata if it had already been generated once for the current map/saveslot.
	if numerical_id == nil then
		numerical_id = getNewGroundValue()
	else
		for k, v in pairs(GROUND) do
			if v == numerical_id then
				return error(("The numerical value %d is already used by GROUND.%s!"):format(v, tostring(k)))
			end
		end
	end


	GROUND[id] = numerical_id
	GROUND_NAMES[numerical_id] = name


	local real_specs = { name = name }
	for k, default in pairs(tile_spec_defaults) do
		if specs[k] == nil then
			real_specs[k] = default
		else
			-- resolvefilepath() gets called by the world entity.
			real_specs[k] = specs[k]
		end
	end

	table.insert(tiledefs.ground, {
		GROUND[id], real_specs
	})


	local real_minispecs = {}
	for k, default in pairs(mini_tile_spec_defaults) do
		if minispecs[k] == nil then
			real_minispecs[k] = default
		else
			real_minispecs[k] = minispecs[k]
		end
	end

	TheMod:AddPrefabPostInit("minimap", function(inst)
		local handle = GLOBAL.MapLayerManager:CreateRenderLayer(
			GROUND[id],
			resolvefilepath( ("levels/tiles/%s.xml"):format(real_minispecs.name) ),
			resolvefilepath( ("levels/tiles/%s.tex"):format(real_minispecs.name) ),
			resolvefilepath( real_minispecs.noise_texture )
		)
		inst.MiniMap:AddRenderLayer( handle )
	end)


	return real_specs, real_minispecs
end


TheMod:EmbedAdder("Tile", AddTile)


return AddTile
