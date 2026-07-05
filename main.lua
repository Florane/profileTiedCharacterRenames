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
	if file then
		file:write(json.encode(storage))
		file:close()
	end
end

local characterIndex = {} --i love preemptive optimization!!!
for _,v in ipairs(characterIds) do
	characterIndex["menu_"..v] = true

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
		storage = json.decode(file:read("*all")) or {}
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
	if not characterIndex["menu_"..string_id] then return Hooks:GetReturn() end
	if not managers.multi_profile then return Hooks:GetReturn() end
	local current_profile = managers.multi_profile._global._current_profile
	if not storage[current_profile] then return Hooks:GetReturn() end
	if not storage[current_profile]["menu_"..string_id] then return Hooks:GetReturn() end
	return storage[current_profile]["menu_"..string_id]
end)
