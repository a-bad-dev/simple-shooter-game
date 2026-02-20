local map_data = {
	name = "forest-4",
	size_x = 190,
	size_y = 69,
	size_z = 155,

	barrier_level = 65,

	spawn_x = nil,
	spawn_y = nil,
	spawn_z = nil,

	start_time = 30,

	scripts = {
		on_start = "for x=0, 189 do\nfor y=0, 10 do\nfor z=0, 154 do\ncore.set_node({x=x,y=69+y,z=z}, {name=\"air\"})\nend\nend\nend",
		on_barrier_remove = "",
		on_end = ""
	},

	classes = {
		class_1 = {
			name = "Long-range",
			initial_items = {"ctf_ranged:m200_loaded", "default:sword_stone", "ctf_ranged:ammo 99", "default:torch 1"}
		},

		class_2 = {
			name = "Mid-ranged",
			initial_items = {"ctf_ranged:ak47_loaded", "ctf_ranged:glock17_loaded", "ctf_ranged:ammo 99", "default:torch 1"}
		},

		class_3 = {
			name = "Short-range",
			initial_items = {"ctf_ranged:benelli_loaded", "ctf_ranged:glock17_loaded", "ctf_ranged:ammo 99", "default:torch 1"}
		}
	}
}

return map_data
