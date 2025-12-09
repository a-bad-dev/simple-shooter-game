function place_map(map)
	local map_path = core.get_modpath("maps") .. "/maps/"
	core.place_schematic({x=0, y=0, z=0}, map_path .. map .. "/map.mts", 0, nil, false)
	local map_data = dofile(map_path .. map .. "/map.lua")
	
	if map_data.spawn_x == nil or map_data.spawn_y == nil or map_data.spawn_z == nil do -- set a default spawnpoint if not set
		map_data.spawn_x = map_data.size_x / 2
		map_data.spawn_y = map_data.barrier_level + 1
		map_data.spawn_z = map_data.size_z / 2
	end
	
	return map_data
end

function remove_barrier(x, y, z)
	for node_x = 1, x do
		for node_z = 1, z do
			core.set_node({x=x, y=y, z=z}, {name = "air"})
		end
	end	
	return ""
end
