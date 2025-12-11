local alive_players = {}
local map_data = {} -- constrict the map data to this file

local spawn_pos = vector.new(-100, -9.6, -100)

local match_state = "not_started" -- not_started, pre_match, in_progress, post_match

local function save_player_data(player)
	local skins = player:get_properties().textures

	-- probably the invisible skin so dont save it
	if skins[1] == "blank.png" then
		return
	end
		
	player:get_meta():set_string("skin", core.serialize(skins))
end

local function load_player_data(player)
	local skins = core.deserialize(player:get_meta():get_string("skin"))

	player:set_properties({
		visual = "mesh",
		textures = skins
	})
end

function make_player_invisible(player)
	save_player_data(player)
	player:set_properties({
		pointable = false,
		visual = "mesh",
		textures = {"blank.png"},
	})

	playertag.set(player, playertag.TYPE_BUILTIN, {a = 0})
end

function give_player_items(player)
	local class = player:get_meta():get_string("class")
	local inv = player:get_inventory()

	inv:set_list("main", {})

	if class == "sniper" then
		inv:add_item("main", "ctf_ranged:m200_loaded")
		inv:add_item("main", "default:sword_stone")
		inv:add_item("main", "ctf_ranged:ammo 100")
	elseif class == "assault" then
		inv:add_item("main", "ctf_ranged:ak47_loaded")
		inv:add_item("main", "ctf_ranged:glock17_loaded")
		inv:add_item("main", "ctf_ranged:ammo 100")
	elseif class == "shotgun" then
		inv:add_item("main", "ctf_ranged:benelli_loaded")
		inv:add_item("main", "ctf_ranged:glock17_loaded")
		inv:add_item("main", "ctf_ranged:ammo 100")
	end
end

function set_player_mode(player, mode)
	player:get_meta():set_string("mode", mode)

	local player_name = player:get_player_name()
	local privs = core.get_player_privs(player_name)

	if mode == "normal" then
		player:set_properties({
			pointable = true, -- allow players to be killable after the match starts
		})

		load_player_data(player)
		privs.noclip, privs.fast, privs.fly, privs.interact = false, false, false, true

		playertag.set(player, playertag.TYPE_ENTITY, {a = 255, r = 255, g = 255, b = 255})

		player:set_inventory_formspec([[
    		size[8,4]
    		list[current_player;main;0,0;8,1;]
    		list[current_player;main;0,1.25;8,3;8]
    		listring[current_player;main]
		]])

		player:hud_set_flags({
			hotbar = true,
			healthbar = true,
			breathbar = true,
		})		
	elseif mode == "spectator" then
		privs.noclip, privs.fast, privs.fly, privs.interact = true, true, true, false

		make_player_invisible(player)

		core.chat_send_player(player_name, core.colorize("blue", "You are now a spectator."))

		player:set_inventory_formspec([[
    		size[8,4]
    		list[current_player;main;0,0;8,1;]
    		list[current_player;main;0,1.25;8,3;8]
    		listring[current_player;main]
		]])

		player:hud_set_flags({
			hotbar = false,
			healthbar = false,
			breathbar = false,
		})

	elseif mode == "pre_match" then
		privs.noclip, privs.fast, privs.fly, privs.interact = false, true, false, false -- allow fast movement to get to a specific point on the large map

		make_player_invisible(player)

		player:set_inventory_formspec([[
    		size[8,6]

			label[3,0.1;Change class:]

			button[0.3,1;2.5,1;class_sniper;Long-range]
			button[2.8,1;2.5,1;class_assault;Mid-range]
			button[5.3,1;2.5,1;class_shotgun;Short-range]

    		list[current_player;main;0,2;8,1;]
    		list[current_player;main;0,3.25;8,3;8]
    		listring[current_player;main]
		]])

		player:hud_set_flags({
			hotbar = true,
			healthbar = false,
			breathbar = false,
		})
	end

	core.change_player_privs(player_name, privs)
end

function start_match()
	if match_state ~= "not_started" then
		return
	end

	set_match_state("pre_match")

	map_data = place_map(map_data.name or "forest") -- default to forest if no map is specified
	
	core.chat_send_all(core.colorize("green", "Match about to start in 30 seconds!\nOpen inventory to change class!"))

	for _, player in pairs(core.get_connected_players()) do
		set_player_mode(player, "pre_match")
		give_player_items(player)

		player:set_pos({x = map_data.spawn_x, y = map_data.spawn_y, z = map_data.spawn_z})

		player:set_hp(20)
	end

	for i = 10, 1, -1 do -- count down from 10 to 1 (yes you are free to set me on fire for this horrible solution)
		core.after(20 + i, function()
			core.chat_send_all(core.colorize("green", "Match starts in " .. (11 - i) .. " seconds."))
		end)
	end

	core.after(30, function()
		set_match_state("in_progress")
		core.chat_send_all(core.colorize("green", "Match started!"))
	
		remove_barrier(map_data.size_x, map_data.barrier_level, map_data.size_z)

		alive_players = {}

		for _, player in pairs(core.get_connected_players()) do
			local player_name = player:get_player_name()
			inv = player:get_inventory()

			inv:set_list("main", {})

			give_player_items(player)

			player:set_properties({
				pointable = true, -- allow players to be killable after the match starts
			})
			alive_players[player_name] = "alive"

			set_player_mode(player, "normal")
		end
	end)
end

function end_match()
	set_match_state("not_started")

	for _, player in pairs(core.get_connected_players()) do
		player:set_pos(spawn_pos)
		player:get_inventory():set_list("main", {})

		player:set_inventory_formspec([[
    		size[8,4]
    		list[current_player;main;0,0;8,1;]
    		list[current_player;main;0,1.25;8,3;8]
    		listring[current_player;main]
		]])


		player:set_properties({pointable = false})

		set_player_mode(player, "normal")
	end

	return true
end

function set_match_state(state)
	match_state = state
end

local function get_alive_players()
	local alive_players_names = {}

	for player_name, _ in pairs(alive_players) do
		if alive_players[player_name] == "alive" then
			table.insert(alive_players_names, player_name)
		end
	end

	return alive_players_names
end

local function kill_player(player, reason)
	local player_name = player:get_player_name()

	if alive_players[player_name] ~= "alive" or match_state ~= "in_progress" then
		return
	end

	alive_players[player_name] = "dead"

	local alive_player_names = get_alive_players()

	local message = string.format("%s has been eliminated! (%s) %d player%s left!", player_name, reason, #alive_player_names, #alive_player_names == 1 and "" or "s")
	core.chat_send_all(core.colorize("red", message))
	if #alive_player_names == 1 then
		local winner_name = alive_player_names[1]
		core.chat_send_all(core.colorize("green", winner_name .. " is the winner!"))

		set_match_state("post_match")

		core.after(5, end_match)
	end
end

local diggable_groups = {
	"snappy",
	"cracky",
	"choppy",
	"crumbly",
	"oddly_breakable_by_hand",
}

core.register_on_mods_loaded(function()
	for itemname, _ in pairs(core.registered_nodes) do
		local node = core.registered_nodes[itemname]
		local groups = node.groups

		groups.fall_damage_add_percent = -100

		groups.immortal = 1

		for _, group in pairs(diggable_groups) do
			groups[group] = nil
		end

		core.override_item(itemname, {groups = groups})
	end
end)

core.register_on_joinplayer(function(player)
	core.place_schematic({x=-105, y=-10, z=-108}, core.get_modpath("main") .. "/schems/spawn.mts", 0, nil, true)
	player:set_pos(spawn_pos)
	player:get_inventory():set_list("main", {})

	player:set_inventory_formspec([[
    		size[8,4]
    		list[current_player;main;0,0;8,1;]
    		list[current_player;main;0,1.25;8,3;8]
    		listring[current_player;main]
	]])
	player:set_properties({pointable = false})

	player:set_hud_flags({
		minimap = false,
		minimap_radar = false,
	})

	if player:get_meta():get_string("class") == "" then
		player:get_meta():set_string("class", "assault")
	end

	set_player_mode(player, "normal")
end)

core.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	
	kill_player(player, "left the game")
end)

core.register_on_dieplayer(function(player)
	local player_name = player:get_player_name()
	
	kill_player(player, "died")
end)

core.register_on_respawnplayer(function(player)
	local player_name = player:get_player_name()

	if match_state == "in_progress" or match_state == "post_match" then
		set_player_mode(player, "spectator")

		player:set_pos({x = map_data.spawn_x, y = map_data.spawn_y, z = map_data.spawn_z})
		player:get_inventory():set_list("main", {})
	
		player:set_properties({pointable = false})
	end

	return true
end)

local timer = 0
core.register_globalstep(function(dtime)
	timer = timer + dtime

	if timer >= 10 then
		timer = 0
		for _, player in pairs(core.get_connected_players()) do
			if alive_players[player:get_player_name()] == "alive" then
				player:set_hp(math.min(player:get_hp() + 2, 20))
			end
		end
	end
end)

core.register_on_player_receive_fields(function(player, formname, fields)

	if match_state ~= "pre_match" then
		return
	end

	if fields.class_sniper then
		player:get_meta():set_string("class", "sniper")
		give_player_items(player)
	elseif fields.class_assault then
		player:get_meta():set_string("class", "assault")
		give_player_items(player)
	elseif fields.class_shotgun then
		player:get_meta():set_string("class", "shotgun")
		give_player_items(player)
	end
end)


core.register_privilege("match_manager", {description = "Can manage the match", give_to_singleplayer = true})

core.register_chatcommand("load", {
	params = "<map>",
	privs = {match_manager = true},
	description = "Load a map",
	func = function(_, param)
		if not param or param == "" then
			return false, "-!- You must specify a map name!"
		end

		if match_state == "pre_match" or match_state == "post_match" or match_state == "in_progress" then
			return false, "-!- Match is already in progress!"
		end

		map_data = place_map(param)

		return true, "-!- Map loaded!"
	end
})

core.register_chatcommand("start", {
	params = "",
	privs = {match_manager = true},
	description = "Start the match",
	func = function()
		start_match()
		return true, "-!- Match started!"
	end
})

core.register_chatcommand("reset", {
	params = "",
	privs = {match_manager = true},
	description = "Terminate the match",
	func = function()
		if match_state ~= "pre_match" and match_state ~= "post_match" and match_state ~= "not_started" then
			core.chat_send_all(core.colorize("red", "Match Terminated"))
			end_match()

			return true
		end

		return false, "Match Cannot be terminated at the moment"
	end
})