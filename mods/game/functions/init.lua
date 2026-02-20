-- Functions for SSG
function make_player_invisible(player) -- Hide a player (pre-match and spectator)
	save_player_data(player)
	player:set_properties({
		pointable = false,
		visual = "mesh",
		textures = {"blank.png"},
	})

	playertag.set(player, playertag.TYPE_BUILTIN, {a = 0})
end

function give_player_items(player) -- Give the player their initial stuff
	local class = player:get_meta():get_string("class")
	local inv = player:get_inventory()

	inv:set_list("main", {})

	if class == "1" then
		for i = 1, #map_data.classes.class_1.initial_items do
			inv:add_item("main", map_data.classes.class_1.initial_items[i])
		end

	elseif class == "2" then
		for i = 1, #map_data.classes.class_2.initial_items do
			inv:add_item("main", map_data.classes.class_2.initial_items[i])
		end

	elseif class == "3" then
		for i = 1, #map_data.classes.class_3.initial_items do
			inv:add_item("main", map_data.classes.class_3.initial_items[i])
		end
	end
end

function set_player_mode(player, mode) -- Set player mode (spectator, pre-match, normal, etc)
	player:get_meta():set_string("mode", mode)

	local player_name = player:get_player_name()
	local privs = core.get_player_privs(player_name)

	if mode == "normal" then
		player:set_properties({
			pointable = true, -- allow players to be killable after the match starts
		})

		load_player_data(player)
		privs.noclip, privs.fast, privs.fly, privs.interact, privs.debug = false, false, false, true, false

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
		privs.noclip, privs.fast, privs.fly, privs.interact, privs.debug = true, true, true, false, true

		make_player_invisible(player)

		core.chat_send_player(player_name, core.colorize("#0574fc", "You are now a spectator."))

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

			button[0.3,1;2.5,1;class_sniper;]]  .. map_data.classes.class_1.name .. [[]
			button[2.8,1;2.5,1;class_assault;]] .. map_data.classes.class_2.name .. [[]
			button[5.3,1;2.5,1;class_shotgun;]] .. map_data.classes.class_3.name .. [[]

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

function start_match(map) -- Start the match
	if match_state ~= "not_started" then
		return
	end

	map_data = place_map(map or "forest") -- default to forest if no map is specified

	if not map_data then
		return nil
	end

	set_match_state("pre_match")

	local map_loading_images = {}
	for _, player in pairs(core.get_connected_players()) do
		set_player_mode(player, "pre_match")

		map_loading_images[player:get_player_name()] = player:hud_add({
			type      = "image",
			position  = {x=0.5, y=0.5},
			image_scale = 100,
			text      = "map_loading.png",
			scale     = {x=-100, y=-100},
			z_index = 1000,
		})

		give_player_items(player)

		player:set_pos({x = map_data.spawn_x, y = map_data.spawn_y, z = map_data.spawn_z})

		player:set_hp(20)
	end

	core.after(3, function()
		for _, player in pairs(core.get_connected_players()) do
			player:set_pos({x = map_data.spawn_x, y = map_data.spawn_y, z = map_data.spawn_z})
			player:hud_remove(map_loading_images[player:get_player_name()])
		end


		assert(loadstring(map_data.scripts.on_start or ""))()

		core.chat_send_all(core.colorize("#b011f9", string.format("Match about to start in %d seconds!\nOpen inventory to change class!", map_data.start_time)))

		for i = 10, 1, -1 do -- count down from 10 to 1 (yes you are free to set me on fire for this horrible solution)
			core.after(map_data.start_time - 10 + i, function()
				core.chat_send_all(core.colorize("green", string.format("Match starts in %d second%s.", 11 - i, 11 - i == 1 and "" or "s"))) -- <- RIP readability
			end)
		end

		core.after(map_data.start_time, function()
			set_match_state("in_progress")
			core.chat_send_all(core.colorize("green", "Match started!"))

			remove_barrier()

			alive_players = {}

			for _, player in pairs(core.get_connected_players()) do
				local player_name = player:get_player_name()
				local inv = player:get_inventory()

				inv:set_list("main", {})

				give_player_items(player)

				player:set_properties({
					pointable = true, -- allow players to be killable after the match starts
				})
				alive_players[player_name] = "alive"

				set_player_mode(player, "normal")
			end
		end)
	end)
end

function end_match() -- End the match
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

function set_match_state(state) -- why on earth does this function exist
	match_state = state
end

function save_player_data(player) -- Save the player's skin storing it in their metadata
	local skins = player:get_properties().textures

	-- probably the invisible skin so dont save it
	if skins[1] == "blank.png" then
		return
	end

	player:get_meta():set_string("skin", core.serialize(skins))
end

function load_player_data(player) -- Load the player's skin stored in their metadata
	local skins = core.deserialize(player:get_meta():get_string("skin"))

	player:set_properties({
		visual = "mesh",
		textures = skins
	})
end

function kill_player(player, reason) -- Handle killed/disconnected players properly
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

		assert(loadstring(map_data.scripts.on_end or ""))()

		set_match_state("post_match")

		core.after(5, end_match)
	end
end

function get_alive_players() -- Get the names of the alive players
	local alive_players_names = {}

	for player_name, _ in pairs(alive_players) do
		if alive_players[player_name] == "alive" then
			table.insert(alive_players_names, player_name)
		end
	end

	return alive_players_names
end
