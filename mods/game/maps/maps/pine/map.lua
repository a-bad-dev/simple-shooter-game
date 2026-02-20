return {
	name = "pine",
	size = vector.new(111, 64, 107),
	
	barrier_level = 60, -- <- Y level of the barrier
	
	spawn = nil,
	
	start_time = 30,

	on_start 		  = nil,
	on_end 			  = nil,
	on_barrier_remove = nil,
}
