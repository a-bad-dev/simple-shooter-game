-- Maps mod for SSG

local map_path = core.get_modpath("maps") .. "/maps/"
map_data = {}

map_list = core.get_dir_list(map_path, true)
table.sort(map_list)

function place_map(map)
	local map_pos = vector.new(0, 0, 0)

	for i = 1, #map_list do
		if map_list[i] == map then
			map_pos = vector.new(1000 * (i - 1), 0, 0)
			break
		elseif i == #map_list then
			return nil
		end
	end

	map_data = dofile(map_path .. map .. "/map.lua")
	map_data.pos = map_pos
	core.place_schematic(map_pos, map_path .. map .. "/map.mts", 0, nil, true)
	
	if not map_data.spawn then -- set a default spawnpoint if not set
		map_data.spawn = vector.new(map_data.size.x / 2, map_data.barrier_level + 1, map_data.size.z / 2) + map_pos
	else
		map_data.spawn = map_data.spawn + map_pos
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
end

function remove_barrier()
	for _, player in pairs(core.get_connected_players()) do
		local pos = player:get_pos()
		player:set_pos({x=pos.x, y=map_data.barrier_level - 3.5, z=pos.z})
	end
	
	if map_data.on_barrier_remove then
		map_data.on_barrier_remove()
	end
end
