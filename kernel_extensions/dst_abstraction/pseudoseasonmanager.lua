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

local Lambda = wickerrequire "paradigms.functional"

local PU = pkgrequire "pseudoutils"

local TUNING = TUNING

local is_rog = _G.IsDLCEnabled(_G.REIGN_OF_GIANTS)

---

local SEASON_NAMES
if not is_rog then
	SEASON_NAMES = {"summer", "winter"}
else
	SEASON_NAMES = {"autumn", "winter", "spring", "summer"}
end

local LIGHTNING_MODES_PRETTYNAME_MAP = {
	rain = "WhenRaining",
	snow = "WhenSnowing",
	any = "WhenPrecipitating", -- "any" is the new "precip"
	always = "Always",
	never = "Never",
}

---

local PseudoSeasonManager = Class(function(self, inst)
	assert(IsDST(), "Attempt to create a PseudoSeasonManager object in singleplayer!")
	assert(inst == TheWorld)
	self.inst = inst
end)
local PseudoSM = PseudoSeasonManager

-- Just a utility table.
-- Methods set here are put in PseudoSeasonManager, except they raise an error when called if we are not the host.
local MasterPseudoSeasonManager = PU.NewMasterSetter(PseudoSeasonManager, "PseudoSeasonManager")
local MasterPseudoSM = MasterPseudoSeasonManager

---

local PushWE = PU.PushWorldEvent
local PushWET = PU.PushWorldEventTrigger
local WSGet = PU.WorldStateGet
local WSGetter = PU.WorldStateGetter

local defineSeasonMethods = PU.NewGenericMethodDefiner(SEASON_NAMES)
local defineLightningModeMethods = PU.NewGenericMethodDefiner(LIGHTNING_MODES_PRETTYNAME_MAP)

local setSeason = PushWET("ms_setseason")
local setSeasonMode = PushWET("ms_setseasonmode")

---

-- TODO: change this when caves are supported in DST.
PseudoSM.SetCaves = Lambda.Error("Caves are not supported yet.")

MasterPseudoSM.SetMoiustureMult = PushWET("ms_setmoisturescale")
MasterPseudoSM.SetMoistureMult = MasterPseudoSM.SetMoiustureMult

defineSeasonMethods(MasterPseudoSM, "Endless%s", function(self, season, pre_length, rampup)
	-- pre_length and rampup are currently hardcoded constants in
	-- components/seasons.lua, so the parameters are ignored.
	
	setSeason(self, season)
	setSeasonMode(self, "endless")
end)

defineSeasonMethods(MasterPseudoSM, "Always%s", function(self, season)
	setSeason(self, season)
	setSeasonMode(self, "always")
end)

MasterPseudoSM.Cycle = Lambda.BindSecond(setSeasonMode, "cycle")

MasterPseudoSM.AlwaysWet = PushWET("ms_setprecipitationmode", "always")

MasterPseudoSM.AlwaysDry = PushWET("ms_setprecipitationmode", "never")

function MasterPseudoSM:OverrideLightningDelays(min, max)
	PushWE("ms_setlightningmode", {min = min, max = max})
end

function MasterPseudoSM:DefaultLightningDelays()
	PushWE("ms_setlightningmode", {})
end

defineLightningModeMethods(MasterPseudoSM, "Lightning%s", PushWET("ms_setlightningmode"))

local argsToSeasonTable
if is_rog then
	argsToSeasonTable = function(autumn, winter, spring, summer)
		return {
			autumn = autumn,
			winter = winter,
			spring = spring,
			summer = summer,
		}
	end
else
	argsToSeasonTable = function(summer, winter)
		return {
			summer = summer,
			winter =  winter,
		}
	end
end

function MasterPseudoSM:SetSeasonLengths(...)
	PushWE("ms_setseasonlengths", argsToSeasonTable(...), self)
end

function MasterPseudoSM:SetSegs(...)
	PushWE("ms_setseasonclocksegs", argsToSeasonTable(...), self)
end

PseudoSM.GetCurrentTemperature = WSGetter("temperature")

PseudoSM.GetDaysLeftInSeason = WSGetter("remainingdaysinseason")

PseudoSM.GetDaysIntoSeason = WSGetter("elapseddaysinseason")

PseudoSM.GetSeasonString = WSGetter("season")

function PseudoSM:GetPercentSeason()
	return self:GetDaysIntoSeason()/self:GetSeasonLength()
end

function MasterPseudoSM:ForcePrecip()
	PushWE("ms_forceprecipitation", true)
end

MasterPseudoSM.DoLightningStrike = PushWET("ms_sendlightningstrike")

PseudoSM.GetPOP = WSGetter("pop")

PseudoSM.GetPrecipitationRate = WSGetter("precipitationrate")

PseudoSM.GetMoistureLimit = WSGetter("moistureceil")

defineSeasonMethods(MasterPseudoSM, "Start%s", PushWET("ms_setseason"))

-- Not a complete equivalence.
function MasterPseudoSM:StartPrecip()
	self:ForcePrecip()
	self.inst.components.weather:OnUpdate(0)
end

do
	local len_strs = {}
	for _, season in ipairs(SEASON_NAMES) do
		len_strs[season] = season.."length"
	end

	function PseudoSM:GetSeasonLength()
		return WSGet(len_strs[self:GetSeason()], self)
	end
end

defineSeasonMethods(PseudoSM, "Is%s", function(self, season)
	return self:GetSeaason() == season
end)

PseudoSM.GetSnowPercent = WSGetter("snowlevel")

MasterPseudoSM.Advance = PushWET("ms_advanceseason")

function PseudoSM:GetTemperature()
	return self:GetCurrentTemperature()
end

MasterPseudoSM.Retreat = PushWET("ms_retreatseason")

-- Not a complete equivalence.
function MasterPseudoSM:StopPrecip()
	PushWE("ms_forceprecipitation", false)
	self.inst.components.weather:OnUpdate(0)
end

PseudoSM.IsRaining = WSGetter("israining")

PseudoSM.GetSeason = WSGetter("season")

PseudoSM.OnUpdate = Lambda.Nil
PseudoSM.LongUpdate = Lambda.Nil

return PseudoSM
