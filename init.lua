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

	local supported_groups = {
		"unbreakable", "immortal", "fleshy", "choppy", "bendy",
		"cracky", "crumbly", "snappy", "level", "nether",
		"oddly_breakable_by_hand", "not_in_creative_inventory"
	}
	local caps = {}
	for _,i in pairs(supported_groups) do
		caps[i] = {times={[1]=0, [2]=0, [3]=0}, uses=0, maxlevel=3}
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
			groupcaps=caps,
			damage_groups = {fleshy = 20},
		},
		on_place = function(itemstack, placer, pt)
			if not placer
			or not pt then
				return
			end
			local pname = placer:get_player_name()
			local pos = pt.under
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
			local light = minetest.get_node_light(pos)
			if not light
			or light == 0 then
				light = minetest.get_node_light(pt.above)
			end
			local infos = {
				{"param1", node.param1},
				{"param2", node.param2},
				{"light", light},
			}
			local nam = node.name
			local data = minetest.registered_nodes[nam]
			if not data then
				table.insert(infos, 1, {"name", nam})
			end
			if pcontrol.sneak
			and pcontrol.aux1
			and not pcontrol.up then
				table.insert(infos, {"nodedata", dump(data)})
			end
			local msg = ""
			for _,i in ipairs(infos) do
				local n,i = unpack(i)
				if i ~= 0 then
					msg = msg..n.."="..i..", "
				end
			end
			minetest.sound_play("superpick", {pos = pos, gain = 0.9, max_hear_distance = 10})
			if msg == "" then
				msg = data.description or nam
			else
				msg = string.sub(msg, 0, -3)
			end
			minetest.log("action", "[superpick] "..msg)
			minetest.chat_send_player(pname, msg)
		end,
	})

	minetest.register_on_punchnode(function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "creative:pick"
		and node.name ~= "air" then
			minetest.after(0.3, function(pos, name)
				if minetest.get_node(pos).name ~= "air"
				and not minetest.is_protected(pos, name) then
					minetest.log("info", "[superpick] force destroying node at ("..pos.x.."|"..pos.y.."|"..pos.z..")")
					minetest.remove_node(pos)
				end
			end, pos, puncher:get_player_name())
			add_to_inv(puncher, node)
		end
	end)

	local function cleaninventory(name)
		if name == nil
		or name == "" then
			return
		end
		local inv = minetest.get_player_by_name(name):get_inventory()
		local list = inv:get_list("main")
		inv:set_list("main", {"creative:pick", list[2], list[3]})
		minetest.log("info", "[superpick] "..name.." has cleaned his inventory")
		minetest.chat_send_player(name, 'Inventory Cleaned!')
	end

	minetest.register_chatcommand("cleaninv",{
		description = "Tidy up your inventory.",
		params = "",
		privs = {give=true},
		func = cleaninventory
	})
	minetest.log("info", string.format("[superpick] loaded after ca. %.2fs", os.clock() - load_time_start))
end
