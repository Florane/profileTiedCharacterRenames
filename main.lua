if _G.ProfileTiedCharacterRenames then
	return
end
_G.ProfileTiedCharacterRenames = true

local modId = "profile_renames"
local characterIds = {"russian","german","spanish","american"
,"jowi","old_hoxton","female_1","dragan"
,"jacket","bonnie","sokol","dragon"
,"bodhi","jimmy","sydney","wild"
,"chico","max","joy","myh"
,"ecp_male","ecp_female"}

local storage = {}

MenuCallbackHandler[modId.."_save"] = function(self)
	local file = io.open(SavePath..modId..".txt","w")
	if file then -- csv parsing bc json lib cannot work with spread tables
		for k,v in pairs(storage) do
			file:write(tostring(k)..",")
			for _k,_v in pairs(v) do file:write(_k..",".._v..",") end
			file:write("\n")
		end
		file:close()
	end
end

local characterIndex = {} --i love preemptive optimization!!!
for _,v in ipairs(characterIds) do
	characterIndex["menu_"..v] = v

	MenuCallbackHandler[modId.."_"..v.."_set"] = function (self, item)
		if not managers.multi_profile then return end
		local current_profile = managers.multi_profile._global._current_profile
		if not storage[current_profile] then storage[current_profile] = {} end
		storage[current_profile][v] = item:value()~="" and item:value() or nil
	end
end

Hooks:Add("MenuManagerBuildCustomMenus","MenuManagerBuildCustomMenus_profile_renames",function(menu_manager, nodes)
	local file = io.open(SavePath..modId..".txt","r")
	if file then
		for line in file:lines() do -- csv parsing bc json lib cannot work with spread tables
			local buffer = {}
			for v in string.gmatch(line,"(.-),") do buffer[#buffer+1] = v end
			buffer[1] = tonumber(buffer[1])
			storage[buffer[1]] = {}
			for i=2,#buffer,2 do storage[buffer[1]][buffer[i]] = buffer[i+1] end
		end
		file:close()
	end

	MenuHelper:NewMenu(modId)

	for i,v in ipairs(characterIds) do
		MenuHelper:AddInput({
			id = modId.."_"..v,
			title = "menu_"..v,
			desc = modId.."_"..v.."_desc",
			menu_id = modId,
			priority = -i,
			callback = modId.."_"..v.."_set"
		})
	end

	nodes[modId] = MenuHelper:BuildMenu(modId, {back_callback = modId.."_save"})
	MenuHelper:AddMenuItem(nodes.blt_options, modId, "menu_"..modId, "menu_"..modId.."_desc")
end)

Hooks:PostHook(LocalizationManager,"text",modId.."_text",function(self, string_id)
	if not characterIndex[string_id] then return Hooks:GetReturn() end
	if not managers.multi_profile then return Hooks:GetReturn() end
	local current_profile = managers.multi_profile._global._current_profile
	if not storage[current_profile] then return Hooks:GetReturn() end
	if not storage[current_profile][characterIndex[string_id]] then return Hooks:GetReturn() end
	return storage[current_profile][characterIndex[string_id]]
end)

Hooks:Add("LocalizationManagerPostInit",modId.."LocalizationManagerPostInit",function()
	LocalizationManager:add_localized_strings({
		["menu_"..modId] = "Profile-tied Character Renames",
		["menu_"..modId.."_desc"] = "Settings with inputs to rename every character in currently selected profile",
		[modId.."_russian_desc"] = "Dallas",
		[modId.."_german_desc"] = "Wolf",
		[modId.."_spanish_desc"] = "Chains",
		[modId.."_american_desc"] = "Houston",
		[modId.."_jowi_desc"] = "John Wick",
		[modId.."_old_hoxton_desc"] = "Hoxton",
		[modId.."_female_1_desc"] = "Clover",
		[modId.."_dragan_desc"] = "Dragan",
		[modId.."_jacket_desc"] = "Jacket",
		[modId.."_bonnie_desc"] = "Bonnie",
		[modId.."_sokol_desc"] = "Sokol",
		[modId.."_dragon_desc"] = "Jiro",
		[modId.."_bodhi_desc"] = "Bodhi",
		[modId.."_jimmy_desc"] = "Jimmy",
		[modId.."_sydney_desc"] = "Sydney",
		[modId.."_wild_desc"] = "Rust",
		[modId.."_chico_desc"] = "Scarface",
		[modId.."_max_desc"] = "Sangres",
		[modId.."_joy_desc"] = "Joy",
		[modId.."_myh_desc"] = "Duke",
		[modId.."_ecp_male_desc"] = "I do not respect your choice of character",
		[modId.."_ecp_female_desc"] = "I do not respect your choice of character"
	})
end)
