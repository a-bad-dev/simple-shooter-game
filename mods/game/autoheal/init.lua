-- Autohealing mod for SSG
local timer = 0
core.register_globalstep(function(dtime)
	timer = timer + dtime

	if timer >= 10 then
		timer = 0
		for _, player in pairs(core.get_connected_players()) do
			if alive_players[player:get_player_name()] == "alive" and player:get_hp() > 0 then
				player:set_hp(math.min(player:get_hp() + 2, 20))
			end
		end
	end
end)
