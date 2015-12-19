--[[
Copyright (c) 2015, Robert 'Bobby' Zenz
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]



--- A system which makes the player drop their inventory when they die.
deathinventorydrop = {
	--- If the system should be activated automatically.
	activate_automatically = settings.get_bool("deathinventorydrop_activate", true),
	
	--- If the system is active/has been activated.
	active = false,
	
	--- The list of inventories/list names to drop, they need to be in players
	-- inventory, defaults to "main".
	inventories = settings.get_list("deathinventorydrop_inventories", "main"),
	
	--- The split mode to use, can either be "random", "single" or "stack",
	-- defaults to "random".
	split = settings.get_string("deathinventorydrop_split", "random"),
	
	--- The velocity with which the items are dropped, defaults to "7, 10, 7".
	velocity = settings.get_pos3d("deathinventorydrop_velocity", { x = 7, y = 10, z = 7 })
}


--- Activates the system, if it has not been disabled in the configuration by
-- setting "deathinventorydrop_activate" to "false".
function deathinventorydrop.activate()
	if deathinventorydrop.activate_automatically then
		deathinventorydrop.activate_internal()
	end
end

--- Activates the system, without checking the configuration. Multiple
-- invocations have no effect.
function deathinventorydrop.activate_internal()
	if not deathinventorydrop.active then
		minetest.register_on_dieplayer(deathinventorydrop.drop)
		
		deathinventorydrop.active = true
	end
end

--- Drops the inventory of the given player.
--
-- @param player The Player object of which to drop the inventory.
function deathinventorydrop.drop(player)
	local inventory = player:get_inventory()
	
	deathinventorydrop.inventories:foreach(function(list_name, index)
		deathinventorydrop.drop_inventory(player, inventory, list_name)
	end)
end

--- Drops the given list from the given player, removing all items from
-- the list.
--
-- @param player The Player object.
-- @param inventory The InvRef object.
-- @param list_name The name of the list of which to drop.
function deathinventorydrop.drop_inventory(player, inventory, list_name)
	itemutil.blop(
		player,
		inventory:get_list(list_name),
		deathinventorydrop.velocity.x,
		deathinventorydrop.velocity.y,
		deathinventorydrop.velocity.z,
		deathinventorydrop.split)
	
	-- Now clear the whole list.
	for index = 1, inventory:get_size(list_name), 1 do
		inventory:set_stack(list_name, index, nil)
	end
end

