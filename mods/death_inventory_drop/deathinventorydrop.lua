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
	
	--- The percentage of destroyed items.
	percentage_destroyed_items = settings.get_table("deathinventorydrop_percentage_destroyed_items", { min = 0.15, max = 0.35 }, "min", "max"),
	
	--- The percentage of retained items.
	percentage_retained_items = settings.get_table("deathinventorydrop_percentage_retained_items", { min = 0, max = 0.15 }, "min", "max"),
	
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
	local items = inventory:get_list(list_name)
	
	local total_item_count = 0
	for index, value in ipairs(items) do
		total_item_count = total_item_count + value:get_count()
	end
	
	-- Get the retained items.
	local retained_items = deathinventorydrop.take_from_inventory(
		items,
		total_item_count,
		deathinventorydrop.percentage_retained_items)
	
	-- Destroy some items.
	deathinventorydrop.take_from_inventory(
		items,
		total_item_count,
		deathinventorydrop.percentage_destroyed_items)
	
	itemutil.blop(
		player,
		items,
		deathinventorydrop.velocity.x,
		deathinventorydrop.velocity.y,
		deathinventorydrop.velocity.z,
		deathinventorydrop.split)
	
	inventory:set_list(list_name, retained_items)
end

--- Takes random amount from the given list and returns the taken items.
--
-- @param items The list of items.
-- @param total_item_count The total count of items in the list.
-- @param range The range, having min and max values.
-- @return The list of taken items.
function deathinventorydrop.take_from_inventory(items, total_item_count, range)
	local taken_items = {}
	
	if range.max > 0  then
		local min_item_count = mathutil.round(total_item_count * range.min)
		local max_item_count = mathutil.round(total_item_count * range.max)
		local item_count = random.next_int(min_item_count, max_item_count)
		local items_per_stack = mathutil.round(total_item_count / item_count)
		
		while item_count > 0 do
			for index, value in ipairs(items) do
				if item_count > 0 and value:get_count() > 0 then
					local max_count = math.min(value:get_count(), math.min(items_per_stack, item_count))
					local count = random.next_int(0, max_count)
					
					local taken_item = value:take_item(count)
					
					if taken_items[index] == nil then
						taken_items[index] = taken_item
					else
						taken_items[index]:add_item(taken_item)
					end
					
					item_count = item_count - count
				end
			end
		end
	end
	
	return taken_items
end

