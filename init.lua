--superpick[12.12.08]
--Texture created with gimp

minetest.register_on_punchnode(function(pos, node, puncher)
	if puncher:get_wielded_item():get_name() == "superpick:pick"
	and minetest.env: get_node(pos).name ~= "air" then
		minetest.env:remove_node(pos)
		local inv = puncher:get_inventory()
		if inv then
			if not inv:contains_item("main", node) then
				inv:add_item("main", node)
			end
		end
	end
end)

minetest.register_tool("superpick:pick", {
	description = "LX 113",
	inventory_image = "superpick.png",
	wield_scale = {x=2,y=2,z=2},
	liquids_pointable = true,
	tool_capabilities = {
		full_punch_interval = 0,
		max_drop_level=3,
		groupcaps={
			unbreakable={times={[1]=0, [2]=0, [3]=0}, uses=0, maxlevel=3},
			fleshy = {times={[1]=0, [2]=0, [3]=0}, uses=0, maxlevel=3},
			choppy={times={[1]=0, [2]=0, [3]=0}, uses=0, maxlevel=3},
			bendy={times={[1]=0, [2]=0, [3]=0}, uses=0, maxlevel=3},
			cracky={times={[1]=0, [2]=0, [3]=0}, uses=0, maxlevel=3},
			crumbly={times={[1]=0, [2]=0, [3]=0}, uses=0, maxlevel=3},
			snappy={times={[1]=0, [2]=0, [3]=0}, uses=0, maxlevel=3},
		},
		damage_groups = {fleshy = 20},
	},
})

minetest.register_on_punchnode(function(pos, node, puncher)
	if puncher:get_wielded_item():get_name() == "superpick:info"
	and minetest.env: get_node(pos).name ~= "air" then
		local inf = node.name
		print(inf)
		minetest.chat_send_all(inf)
	end
end)

minetest.register_tool("superpick:info", {
	description = "i 114",
	inventory_image = "superpick_info.png",
	wield_scale = {x=2,y=2,z=2},
	liquids_pointable = true,
	tool_capabilities = {},
})
