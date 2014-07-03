---
-- Main file. Run through modmain.lua
--
-- @author debugman18
-- @author simplex


BindModModule 'modenv'
-- This just enables syntax conveniences.
BindTheMod()


--[[
-- The following test checks if we are running the development branch (according to what modinfo.lua informs us).
--]]
if IsDevelopment() then
	-- This enables the prefab compiler (i.e., the automatic generation of files in scripts/prefabs).
	wickerrequire('plugins.prefab_compiler')

	-- This enables the asset compiler (i.e., the automatic generation of a file listing all of our assets).
	-- If the output filename is nil, disables it instead.
	wickerrequire('plugins.asset_compiler')(GetConfig("ASSET_COMPILER", "OUTPUT_FILE"))
end

-- This enables the save load-time check for U&A being enabled. The argument is how to call U&A
-- in the button for automatically enabling the mod. It should be short to fit in the button.
wickerrequire('plugins.save_safeguard')("UA")


local Pred = wickerrequire 'lib.predicates'
local Reflection = wickerrequire 'game.reflection'

require 'mainfunctions'

modrequire 'api_abstractions'

modrequire 'profiling'
modrequire 'debugtools'
modrequire 'strings'
modrequire 'patches'
modrequire 'postinits'
modrequire 'actions'
modrequire 'resources.recipes'

wickerrequire 'plugins.addplayerprefabpostinit'


do
	local oldSpawnPrefab = _G.SpawnPrefab
	function _G.SpawnPrefab(name)
		if name == "cave" and Pred.IsCloudLevel() then
			name = "cloudrealm"
			_G.TheSim:LoadPrefabs {"cloudrealm"}
		end
		return oldSpawnPrefab(name)
	end
end


AddGamePostInit(function()
	local ground = GetWorld()
	if ground and Pred.IsCloudLevel() then
		for _, node in ipairs(ground.topology.nodes) do
			local mist = assert( SpawnPrefab("cloud_mist") )
			mist:AddToNode(node)
			if mist:IsValid() and mist.components.emitter then
				mist.components.emitter:Emit()
			end
		end
	end
end)

local function winter_perk(inst)
	if GetPlayer().prefab == "winnie" then
		TUNING.MIN_CROP_GROW_TEMP = -100
	end	
end	

--[[
-- This is just to prevent changes in our implementation breaking old saves.
--]]
AddSimPostInit(function()
	local LevelMeta = modrequire 'lib.level_metadata'
	if LevelMeta.Get("height") == nil then
		local Climbing = modrequire 'lib.climbing'
		LevelMeta.Set("height", Climbing.GetLevelHeight())
	end
end)


--[[
local function OnUnlockMound(inst)
	if not inst:IsValid() then return end

	local tree = SpawnPrefab("beanstalk_sapling")
	if tree then
		tree.Transform:SetPosition(inst.Transform:GetWorldPosition())
	end
	TheMod:DebugSay("[", inst, "] unlocked.")
	inst:Remove()
end
--]]
 

local function addmoundtag(inst)
		local function beanstalktest(inst, item)
		    if item.prefab == "magic_beans" and not item:HasTag("cooked") then
		    	if not inst.components.workable then
		        	return true
		        end
		    else return false end
		end

		local function beanstalkaccept(inst, giver, item)
			print("Beans accepted.")
			local tree = SpawnPrefab("beanstalk_sapling") 
			if tree then 
				tree.Transform:SetPosition(inst.Transform:GetWorldPosition())
			end 
		end

		local function beanstalkrefuse(inst, item)
		    print("Dig a hole.")
		    GetPlayer().components.talker:Say("I need to dig a hole first.")
		end

		if not inst.components.hole then
			inst:AddComponent("inventory")
		    inst:AddComponent("trader")
		    inst.components.trader:SetAcceptTest(beanstalktest)
		    inst.components.trader.onaccept = beanstalkaccept
		    inst.components.trader.onrefuse = beanstalkrefuse
		    inst.components.trader:Enable()
		end

		inst:AddTag("mound")
end	

AddPrefabPostInit("mound", addmoundtag)

table.insert(GLOBAL.CHARACTER_GENDERS.FEMALE, "winnie")

--This adds our minimap atlases.

AddMinimapAtlas("images/winnie.xml")
AddMinimapAtlas("images/beanstalk.xml")
AddMinimapAtlas("images/beanstalk_exit.xml")
AddMinimapAtlas("images/cloud_coral.xml")
AddMinimapAtlas("images/shopkeeper.xml")
AddMinimapAtlas("images/scarecrow.xml")

AddMinimapAtlas("images/cloudcrag.xml")
AddMinimapAtlas("images/octocopter.xml")
AddMinimapAtlas("images/dragonblood_tree.xml")
AddMinimapAtlas("images/hive_marshmallow.xml")
AddMinimapAtlas("images/cauldron.xml")
AddMinimapAtlas("images/thunder_tree.xml")
AddMinimapAtlas("images/jellyshroom_red.xml")
AddMinimapAtlas("images/jellyshroom_green.xml")
AddMinimapAtlas("images/jellyshroom_blue.xml")
AddMinimapAtlas("images/cloud_bush.xml")
AddMinimapAtlas("images/tea_bush.xml")

AddMinimapAtlas("images/crystal_lamp.xml")
AddMinimapAtlas("images/cloud_fruit_tree.xml")
AddMinimapAtlas("images/kettle.xml")
AddMinimapAtlas("images/gummybear_den.xml")

AddMinimapAtlas("images/cloud_algae.xml")

AddMinimapAtlas("images/weather_machine.xml")

AddMinimapAtlas("images/beanlet_hut.xml")

AddMinimapAtlas("images/refiner.xml")

AddMinimapAtlas("images/research_lectern.xml")
AddMinimapAtlas("images/weavernest.xml")

--AddMinimapAtlas("images/bean_giant_statue.xml"

AddModCharacter("winnie")

--This adds the new crockpot recipes.

local jellycooktime = 0.75

local redjellyhealth = 0

local redjellyhunger = 0

local redjellysanity = 0

local greenjellyhealth = 0

local greenjellyhunger = 0

local greenjellysanity = 0

local greenjelly = {
	name = "greenjelly",
	test = function(cooker, names, tags) return tags.greenbean == 2 and tags.jelly == 2 end,
	priority = 1,
	weight = 1,
	foodtype = "VEGGIE",
	health = greenjellyhealth,
	hunger = greenjellyhunger,
	sanity = greenjellysanity,
	perishtime = TUNING.PERISH_MED,
	cooktime = jellycooktime,
}

local redjelly = {
	name = "redjelly",
	test = function(cooker, names, tags) return tags.rubber == 2 and tags.jelly == 2 end,
	priority = 1,
	weight = 1, 
	foodtype = "VEGGIE",
	health = redjellyhealth,
	hunger = redjellyhunger,
	sanity = redjellysanity,
	perishtime = TUNING.PERISH_MED,
	cooktime = jellycooktime,
}

local crystalcandy = {
	name = "crystalcandy",
	test = function(cooker, names, tags) return tags.crystal == 3 and tags.inedible == 1 end,
	priority = 1,
	weight = 1, 
	foodtype = "VEGGIE",
	health = redjellyhealth,
	hunger = redjellyhunger,
	sanity = redjellysanity,
	perishtime = TUNING.PERISH_MED,
	cooktime = jellycooktime,	
}

AddCookerRecipe("cookpot", greenjelly)
AddCookerRecipe("cookpot", redjelly)
AddCookerRecipe("cookpot", crystalcandy)

--This lets Winnie grow crops during the winter.

local function winnie_aware_MakeNoGrowInWinter(inst)
	if GetPlayer().prefab ~= "winnie" or not (inst.components.pickable and inst.components.pickable.transplanted) then
		return oldMakeNoGrowInWinter(inst)
	end
end
 
function _G.MakeNoGrowInWinter(inst)
	if GetPlayer() then
		return winnie_aware_MakeNoGrowInWinter(inst)
	else
		-- We need to delay the actual work because spawning the player happens late.
		inst:DoTaskInTime(0, winnie_aware_MakeNoGrowInWinter)
	end
end
