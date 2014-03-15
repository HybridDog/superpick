if minetest.setting_getbool("creative_mode") then
	local load_time_start = os.clock()

	local function add_to_inv(puncher, node)
		local inv = puncher:get_inventory()
		if inv then
			if not inv:contains_item("main", node) then
				inv:add_item("main", node)
			end
		end
	end

	minetest.register_tool(":creative:pick", {
		description = "LX 113",
		inventory_image = "superpick.png",
		wield_scale = {x=2,y=2,z=2},
		liquids_pointable = true,
		range = 14,
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
		on_place = function(itemstack, placer, pointed_thing)
			if( placer == nil or pointed_thing == nil) then
				return
			end
			local pname = placer:get_player_name()
			local pos = minetest.get_pointed_thing_position(pointed_thing, under)
			local node = minetest.get_node_or_nil(pos)
			if not node then
				minetest.chat_send_player(pname, "?")
				return
			end
			local pcontrol = placer:get_player_control()
			if pcontrol.down
			and pcontrol.up then
				add_to_inv(placer, node)
				return
			end
			local nam = node.name
			local par1 = node.param1
			local par2 = node.param2
			if par1 == 0
			and par2 == 0 then
				a = " "
			else
				a = par1
			end
			if par2 == 0 then
				b = ""
			else
				b = par2
			end
			local m = nam.." "..a.." "..b
			if pcontrol.sneak
			and pcontrol.aux1
			and not pcontrol.up then
				m = m..' '..dump(minetest.registered_nodes[nam])
			end
			print("[superpick] "..m)
			minetest.sound_play("superpick", {pos = pos, gain = 0.9, max_hear_distance = 10})
			minetest.chat_send_player(pname, m)
		end,
	})

	minetest.register_on_punchnode(function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "creative:pick"
		and node.name ~= "air" then
			minetest.after(0, function(pos)
				if not minetest.get_node(pos).name == "air" then
					print("[superpick] force destroying node at ("..pos.x.."|"..pos.y.."|"..pos.z..")")
					minetest.remove_node(pos)
				end
			end, pos)
			add_to_inv(puncher, node)
		end
	end)

	local function cleaninventory(name)
		if name == nil
		or name == "" then
			return
		end
		minetest.get_player_by_name(name):
			get_inventory():
				set_list("main", {
					[1] = "creative:pick",
				})
		print("[superpick] "..name.." has cleaned his inventory.")
		minetest.chat_send_player(name, 'Inventory Cleaned!')
	end

	minetest.register_chatcommand('cleaninv',{
		description = 'Tidy up your inventory.',
		params = "",
		privs = {},
		func = cleaninventory
	})
	print(string.format("[superpick] loaded after ca. %.2fs", os.clock() - load_time_start))
end
