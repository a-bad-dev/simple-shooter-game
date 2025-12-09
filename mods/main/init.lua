local player_data = {}
local alive_players = {}

local function save_player_data(player)
	local name = player:get_player_name()
	player_data[name] = {
		size = player:get_properties().visual_size,
		skin = player:get_properties().textures,
	}
end

local function load_player_data(player)
	local name = player:get_player_name()
	player:set_properties({
		visual = "mesh",
		textures = player_data[name].skin,
		visual_size = player_data[name].size,
	})
end

function set_player_mode(player, mode)
	local name = player:get_player_name()
    local privs = core.get_player_privs(name)
	local meta = player:get_meta()
	local current_mode = meta:get_string("mode")

	if current_mode == mode then
		return
	end

    if mode == "normal" then
        privs.fly = false
        privs.fast = false
        privs.noclip = false
        privs.shout = true
        privs.interact = true

		load_player_data(player)

		player:set_properties({pointable = true})

		meta:set_string("mode", "normal")
 
	-- add pre_match mode?
    elseif mode == "spectator" then
        privs.fly = true
        privs.fast = true
        privs.noclip = true
        privs.shout = false
        privs.interact = false

		save_player_data(player)

		player:set_properties({
			pointable = false,
			visual = "mesh",
			textures = {"blank.png"},
			visual_size = {x=0, y=0},
		})

		player:set_nametag_attributes({color = {a = 0}})

		core.chat_send_player(name, core.colorize("cyan", "You are now a spectator."))

		meta:set_string("mode", "spectator")
    end
 
    core.change_player_privs(name, privs)
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

	if alive_players[player_name] ~= "alive" then
		return
	end

	alive_players[player_name] = "dead"

	local alive_player_names = get_alive_players()

	local message = string.format("%s has been eliminated! (%s) %d player%s left!", player_name, reason, #alive_player_names, #alive_player_names == 1 and "" or "s")
	core.chat_send_all(core.colorize("red", message))
	if #alive_player_names == 1 then
		local winner_name = alive_player_names[1]
		core.chat_send_all(core.colorize("green", winner_name .. " is the winner!"))
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
	core.place_schematic({x=0, y=-10, z=0}, core.get_modpath("main") .. "/schems/spawn.mts", 0, nil, true)
	player:set_pos({x=5, y=-9.6, z=8})
	player:get_inventory():set_list("main", {})

	player:set_inventory_formspec([[
    		size[8,4]
    		list[current_player;main;0,0;8,1;]
    		list[current_player;main;0,1.25;8,3;8]
    		listring[current_player;main]
	]])

	local player_name = player:get_player_name()
	
	player_data[player_name] = {
		size = player:get_properties().visual_size,
		skin = player:get_properties().textures,
	}

	player:set_properties({pointable = false})

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
	set_player_mode(player, "spectator")

	local player_name = player:get_player_name()

	player:set_pos({x = map_data.spawn_x, y = map_data.spawn_y, z = map_data.spawn_z})

	player:get_inventory():set_list("main", {})
	
	player:set_properties({pointable = false})

	return true
end)

core.register_privilege("match_manager", {description = "Can manage the match", give_to_singleplayer = true})

core.register_chatcommand("load", {
	params = "<map>",
	privs = {match_manager = true},
	description = "Load a map",
	func = function(_, param)
		map_data = place_map(param)
		for _, player in pairs(core.get_connected_players()) do
			local player_name = player:get_player_name()
			set_player_mode(player, "normal")
			player:set_nametag_attributes({color = {a = 0}})
			player:set_hp(20)
			
			player:set_pos({x=map_data.spawn_x, y=map_data.spawn_y, z=map_data.spawn_z})

		end
	end
})

core.register_chatcommand("start", {
	params = "",
	privs = {match_manager = true},
	description = "Start the match",
	func = function()
		remove_barrier(map_data.size_x, map_data.barrier_level, map_data.size_z)
		core.chat_send_all(core.colorize("green", "Match started!"))
		alive_players = {}
		for _, player in pairs(core.get_connected_players()) do
			local player_name = player:get_player_name()
			inv = player:get_inventory()
			inv:add_item("main", "ctf_ranged:ak47_loaded")
			inv:add_item("main", "ctf_ranged:ammo 3")
			player:set_properties({
				pointable = true, -- allow players to be killable after the match starts
			})
			alive_players[player_name] = "alive"
		end
		return ""
	end
})

core.register_chatcommand("reset", {
	params = "",
	privs = {match_manager = true},
	description = "Reset map",
	func = function()
		for _, player in pairs(core.get_connected_players()) do
			local player_name = player:get_player_name()
			player:set_pos({x = map_data.spawn_x, y = map_data.spawn_y, z = map_data.spawn_z})
			set_player_mode(player, "normal")
			player:get_inventory():set_list("main", {})
			player:set_properties({
				visual = "mesh",
				textures = player_data[player_name].skin,
				visual_size = player_data[player_name].size,
				pointable=false,
			})
			player_data[player_name] = {}
		end
		core.chat_send_all(core.colorize("red", "Match terminated."))
		return ""
	end
})
