local map_data = {
	name = "1v1",
	size_x = 41,
	size_y = 31,
	size_z = 38,

	barrier_level = 27,

	spawn_x = nil,
	spawn_y = nil,
	spawn_z = nil,

	start_time = 15,

	scripts = {
		on_start = "for x=0, 40 do\nfor y=0, 17 do\nfor z=0, 37 do\ncore.set_node({x=x,y=31+y,z=z}, {name=\"default:glass\"})\nend\nend\nend",
		on_barrier_remove = "",
		on_end = ""
	}
}

return map_data
