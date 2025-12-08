player_data = {}
alive_players = {}

core.register_on_mods_loaded(function()
	for itemname, _ in pairs(core.registered_nodes) do
		core.override_item(itemname, {groups = {fall_damage_add_percent = -100}})
	end
end)

core.register_on_joinplayer(function(player) 
	core.place_schematic({x = 0, y = 0, z = 0}, core.get_modpath("main") .. "/schematics/map1.mts", 0, nil, false)
	player:set_pos({x = 20, y = 26.5, z = 17})
	player:get_inventory():set_list("main", {})
	core.change_player_privs(player:get_player_name(), {["fly"] = false, ["fast"] = false, ["noclip"] = false, ["shout"] = true, ["interact"] = true})
end)

core.register_on_leaveplayer(function(player)
	alive_players[player:get_player_name()] = "alive"
	core.chat_send_all(core.colorize("red", player:get_player_name() .. " left the game! " .. tostring(#alive_players) .. " players left!"))
	if #alive_players == 1 then
		core.chat_send_all(core.colorize("green", alive_players[1] .. " wins!"))
	end
end)

core.register_on_dieplayer(function(player)
	alive_players[player:get_player_name()] = "dead"
	core.chat_send_all(core.colorize("red", player:get_player_name() .. " died! " .. tostring(#alive_players) .. " players left!"))
	if #alive_players == 1 then
		core.chat_send_all(core.colorize("green", tostring(alive_players[1]) .. " wins!"))
	end
end)

core.register_on_respawnplayer(function(player) 
	core.change_player_privs(player:get_player_name(), {["fly"] = true, ["fast"] = true, ["noclip"] = true, ["shout"] = false, ["interact"] = false})
	player:get_inventory():set_list("main", {})
	player_data[player] = {}
	player_data[player].size = player:get_properties().visual_size
	player_data[player].skin = player:get_properties().textures
	player:set_properties({
		visual = "mesh",
		textures={"invisible_skin.png"},
		visual_size = {x=0, y=0},
		pointable=false,
	})
end)

core.register_chatcommand("start", {
	params = "",
	description = "Start the match",
	func = function()
		for x = 1, 39 do
			for z = 1, 36 do
				core.set_node({x = x, y = 25, z = z}, {name = "air"})
			end
		end
		core.chat_send_all(core.colorize("green", "Match started!"))
		alive_players = {}
		for _, player in pairs(core.get_connected_players()) do
			player:set_nametag_attributes({color = {a = 0}})
			player:set_hp(20)
			inv = player:get_inventory()
			inv:add_item("main", "ctf_ranged:ak47_loaded")
			inv:add_item("main", "ctf_ranged:ammo 3")
			alive_players[player:get_player_name()] = "alive"
		end
		return ""
	end
})

core.register_chatcommand("reset", {
	params = "",
	description = "Reset map",
	func = function()
		core.place_schematic({x = 0, y = 0, z = 0}, core.get_modpath("main") .. "/schematics/map1.mts", 0, nil, false)
		for _, player in pairs(core.get_connected_players()) do
			player:set_nametag_attributes({color = {a = 255, r = 255, g = 255, b = 255}})
			player:set_pos({x = 20, y = 26.5, z = 17})
			core.change_player_privs(player:get_player_name(), {["fly"] = false, ["fast"] = false, ["noclip"] = false, ["shout"] = true, ["interact"] = true})
			player:get_inventory():set_list("main", {})
			player:set_properties({
				visual = "mesh",
				textures = player_data[player].skin,
				visual_size = player_data[player].size,
				pointable=true,
			})
			player_data[player] = {}
		end
		core.chat_send_all(core.colorize("red", "Match terminated."))
		return ""
	end
})
