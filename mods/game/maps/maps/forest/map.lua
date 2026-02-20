return {
	name = "forest",
	size = vector.new(155, 53, 147),

	barrier_level = 49, -- <- Y level of the barrier
	
	spawn = nil,
	
	start_time = 30,
	
	on_start 		  = nil,
	on_end 			  = nil,
	on_barrier_remove = nil,

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
