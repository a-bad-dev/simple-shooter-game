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
   }
}

return map_data
