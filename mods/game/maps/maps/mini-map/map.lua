return {
	name = "mini-map",
	size = vector.new(8, 19, 8),
	
	-- This is a ridiculous hack to prevent players from teleporting into the ground..
	barrier_level = 19,
	
	spawn = vector.new(4, 15, 4),
	
	start_time = 15,

    on_start 		  = nil,
	on_end 			  = nil,
	on_barrier_remove = function()
		local pos  = map_data.pos
		local size = map_data.size + pos
		
		for x = pos.x + 1, size.x - 2 do
			for z = pos.z + 1, size.z - 2 do
				core.set_node(vector.new(x, 14, z), {name = "air"})
			end
		end
	end,
}
