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


return function(boot_params, wicker_stem)
	local assert = assert
	local ipairs = ipairs
	local table = table
	local type = type
	local setfenv = setfenv


	local GetWickerBooter = assert( GetWickerBooter )
	local GetModBooter = assert( GetModBooter )


	local modcode_root = boot_params.modcode_root
	local package = boot_params.package
	assert( type(package) == "table" )
	local searchers = assert( package.searchers or package.loaders )
	assert( type(searchers) == "table" )
	assert( type(package.loaded) == "table" )


	local function basic_module(name)
		local t = {}

		t._M = t
		t._NAME = name
		t._PACKAGE = name:match("^(.-)[%a_][%w_]*$") or ""

		package.loaded[name] = t

		setfenv(2, t)
		return t
	end


	local function NewMappedSearcher(input_map, output_map)
		local current_searchers = {}
		for _, fn in ipairs(searchers) do
			table.insert(current_searchers, fn)
		end

		return function(name)
			local mapped_name = input_map(name)
			if mapped_name then
				print("MAPPED NAME TO "..mapped_name)
				for _, fn in ipairs(current_searchers) do
					local ret = fn(mapped_name)
					if type(ret) == "function" then
						return output_map(ret)
					end
				end
				return "\tno file '" .. mapped_name .. "'"
			else
				print("DIDN'T MAP "..name)
			end
		end
	end

	local function NewBootBinder(get_booter)
		return function(fn)
			return function(name, ...)
				local _M = basic_module(name)
				get_booter()(_M)
				setfenv(fn, _M)
				return fn(name, ...)
			end
		end
	end


	local function NewPrefixFilter(prefix)
		return function(name)
			if name:find(prefix, 1, true) == 1 then
				return name
			end
		end
	end

	local function NewPrefixAdder(prefix)
		return function(name)
			return prefix..name
		end
	end

	local function Id(x)
		return x
	end


	local wicker_searcher = NewMappedSearcher(
		NewPrefixFilter(wicker_stem),
		NewBootBinder(GetWickerBooter)
	)
	local mod_searcher = NewMappedSearcher(
		NewPrefixFilter(modcode_root),
		NewBootBinder(GetModBooter)
	)


	table.insert(searchers, 1, mod_searcher)
	local mod_rerouter = NewMappedSearcher(
		NewPrefixAdder(modcode_root),
		Id
	)
	table.insert(_G.package.loaders, mod_rerouter)
	table.insert(searchers, 1, wicker_searcher)
end
