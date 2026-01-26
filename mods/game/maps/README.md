# How to create a map:

WARNING: This tutorial is NOT simple, you need more than one brain cell to follow it.

Requirements:

[Minetest/Luanti 5.0.0 or later](https://luanti.org/)

(you need at least 5.0.0 to make the map, but you need a more recent version to actually test it)

[Minetest Game](https://content.luanti.org/packages/Luanti/minetest_game/)

[WorldEdit](https://content.luanti.org/packages/sfan5/worldedit/)

[Simple Shooter Game](https://github.com/a-bad-dev/simple-shooter-game/)

Step 1: Build your map. It must be perfectly square or rectangular and not contain any non-MTG nodes or rails.

Step 2: Surround the playable area in a box made of glass, WorldEdit helps with this.

Step 3: Create a barrier 4 blocks below the top of the map out of obsidian glass, leaving a 3-block gap of air between 
the barrier and roof.

Step 4: Select opposite corners of the map with WorldEdit and run `//mtschemcreate map`.

Step 5: Create a folder with the titile of your map in all lowercase with no spaces in `simple-shooter-game/mods/game/maps/maps/`.

Step 6: Copy the file `(Minetest/Luanti install path)/worlds/(name of the world in which you created your map)/schems/map.mts` to `simple-shooter-game/mods/game/maps/maps/(your map's folder)/`.

Step 7: Create a file called `map.lua` in `simple-shooter-game/mods/game/maps/maps/(your map's folder)/`.

Step 8: Open the `map.lua` file in a text editor and put the following content in it:

```lua
local map_data = {
	name = "(Your map name here)",
	size_x = (Size in the X direction of your map),
	size_y = (Size in the Y direction of your map),
	size_z = (Size in the Z direction of your map),
	
	barrier_level = (Distance from the bottom of the map to the barrier),
	
	spawn_x = nil,
	spawn_y = nil,
	spawn_z = nil,
	
	start_time = (Amount of time in seconds before the barrier is removed),

    scripts = {
        on_start = "(Lua script to be run after /start is run, leave blank unless you know what you are doing!)",
        on_barrier_remove = "(Lua script to be run after the barrier is removed, leave blank unless you know what you are doing!)",
        on_end = "(Lua script to be run after the match has ended, leave blank unless you know what you are doing!)"
    },

	classes = {
		class_1 = {
			name = "(Name of class #1 here)", 
			initial_items = {"(Initial item #1 for class #1)", "(Initial item #2 for class #1...)"}
		},

		class_2 = {
			name = "(Name of class #2 here)",
			initial_items = {"(Initial item #1 for class #2)", "(Initial item #2 for class #2...)"}
		},

		class_3 = {
			name = "(Name of class #3 here)",
			initial_items = {"(Initial item #1 for class #3)", "(Initial item #2 for class #3...)"}
		}
	}
}

return map_data
```

Step 9: Open Minetest/Luanti and create a new world with Simple Shooter Game.

Step 10: Play the world and run `/start (your map name)`.

Step 11: Verify the map loads and works.

And that's it!
