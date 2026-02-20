-- Maps mod for SSG
function place_map(map)
	local map_path = core.get_modpath("maps") .. "/maps/"
	local map_list = core.get_dir_list(map_path, true)

	for i = 1, #map_list do
		if map_list[i] == map then
			break
		elseif i == #map_list then
			return nil
		end
	end

	local map_data = dofile(map_path .. map .. "/map.lua")
	core.place_schematic({x=0, y=0, z=0}, map_path .. map .. "/map.mts", 0, nil, true)

	if map_data.spawn_x == nil or map_data.spawn_y == nil or map_data.spawn_z == nil then -- set a default spawnpoint if not set
		map_data.spawn_x = map_data.size_x / 2
		map_data.spawn_y = map_data.barrier_level + 1
		map_data.spawn_z = map_data.size_z / 2
	end

	if map_data.start_time == nil or map_data.start_time <= 0 then
		map_data.start_time = 30
	end

	if map_data.classes == nil then
		map_data.classes = {}
		map_data.classes.class_1 = {}
		map_data.classes.class_2 = {}
		map_data.classes.class_3 = {}
	end

	if map_data.classes.class_1.initial_items == nil or map_data.classes.class_1.name == nil then
		map_data.classes.class_1.initial_items = {"ctf_ranged:m200_loaded", "default:sword_stone", "ctf_ranged:ammo 99"}
		map_data.classes.class_1.name = "Long-range"
	end

	if map_data.classes.class_2.initial_items == nil or map_data.classes.class_2.name == nil then
		map_data.classes.class_2.initial_items = {"ctf_ranged:ak47_loaded", "ctf_ranged:glock17_loaded", "ctf_ranged:ammo 99"}
		map_data.classes.class_2.name = "Mid-range"
	end

	if map_data.classes.class_3.initial_items == nil or map_data.classes.class_3.name == nil then
		map_data.classes.class_3.initial_items = {"ctf_ranged:benelli_loaded", "ctf_ranged:glock17_loaded", "ctf_ranged:ammo 99"}
		map_data.classes.class_3.name = "Short-range"
	end

	return map_data
end

function remove_barrier()
	for _, player in pairs(core.get_connected_players()) do
		local pos = player:get_pos()
		player:set_pos({x=pos.x, y=map_data.barrier_level - 3.5, z=pos.z})
	end
	assert(loadstring(map_data.scripts.on_barrier_remove or ""))()
	return ""
end
