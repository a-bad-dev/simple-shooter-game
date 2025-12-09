function place_map(map)
	local map_path = core.get_modpath("maps") .. "/maps/"
	core.place_schematic({x=0, y=0, z=0}, map_path .. map .. "/map.mts", 0, nil, false)
	dofile(map_path .. map .. "/map.lua")
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
