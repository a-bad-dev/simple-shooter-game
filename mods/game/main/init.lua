-- Main mod for SSG

-- Variables
alive_players = {}
map_data = {}
spawn_pos = vector.new(-100, -9.6, -100)
match_state = "not_started" -- not_started, pre_match, in_progress, post_match

local diggable_groups = {
	"snappy",
	"cracky",
	"choppy",
	"crumbly",
	"oddly_breakable_by_hand",
}

-- `core.xxx` things
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

	player:hud_set_flags({
		minimap = false,
		minimap_radar = false,
	})

	if player:get_meta():get_string("class") == "" then
		player:get_meta():set_string("class", "2") -- Assault
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

core.register_on_player_receive_fields(function(player, formname, fields)

	if match_state ~= "pre_match" then
		return
	end

	if fields.class_sniper then
		player:get_meta():set_string("class", "1")
		give_player_items(player)
	elseif fields.class_assault then
		player:get_meta():set_string("class", "2")
		give_player_items(player)
	elseif fields.class_shotgun then
		player:get_meta():set_string("class", "3")
		give_player_items(player)
	end
end)

-- Privileges
core.register_privilege("match_manager", {description = "Can manage the match", give_to_singleplayer = true})
