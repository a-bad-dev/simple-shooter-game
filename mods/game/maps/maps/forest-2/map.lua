local map_data = {
	name = "forest-2",
	size_x = 189,
	size_y = 71,
	size_z = 102,

	barrier_level = 67, -- <- Y level of the barrier

	spawn_x = nil,
	spawn_y = nil,
	spawn_z = nil,

	start_time = 45,

	scripts = { -- "temporary" hack to ensure there's nothing on top of the map
		on_start = "for x=0, 188 do\nfor y=0, 4 do\nfor z=0, 101 do\ncore.set_node({x=x,y=71+y,z=z}, {name=\"air\"})\nend\nend\nend",
		on_barrier_remove = "",
		on_end = ""
	}
}

return map_data
