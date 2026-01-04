local map_data = {
	name = "forest",
	size_x = 155,
	size_y = 53,
	size_z = 147,
	
	barrier_level = 49, -- <- Y level of the barrier
	
	spawn_x = nil,
	spawn_y = nil,
	spawn_z = nil,
	
	start_time = 30,
	
	scripts = { -- "temporary" hack to ensure there's nothing on top of the map 
		on_start = "for x=0, 154 do\nfor y=0, 16 do\nfor z=0, 146 do\ncore.set_node({x=x,y=53+y,z=z}, {name=\"air\"})\nend\nend\nend",
		on_barrier_remove = "",
		on_end = "automatic_start[2] = false"
	}
}

return map_data
