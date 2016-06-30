local load_time_start = os.clock()

local newhand = {
	wield_image = "wield_dummy.png^[combine:16x16:2,2=wield_dummy.png:-52,-23=character.png^[transformfy",
	wield_scale = {x=1.8,y=1,z=2.8},
}

if minetest.setting_getbool"creative_mode" then
	newhand.range = 14

	local function add_to_inv(puncher, node)
		local inv = puncher:get_inventory()
		if inv then
			if not inv:contains_item("main", node) then
				inv:add_item("main", node)
			end
		end
	end

	local caps = {}
	for _,i in pairs{
		"unbreakable", "immortal", "fleshy", "choppy", "bendy", "cracky",
		"crumbly", "snappy", "level", "nether", "oddly_breakable_by_hand",
		"not_in_creative_inventory"
	} do
		caps[i] = {times={[1]=0, [2]=0, [3]=0}, uses=0, maxlevel=3}
	end

	local function rc_info(_, player, pt)
		if not player
		or not pt
		or player:get_wield_index() ~= 1 then
			return
		end
		local pname = player:get_player_name()
		if not minetest.check_player_privs(pname, {server=true}) then
			return
		end
		local pos = pt.under
		local node = minetest.get_node_or_nil(pos)
		if not node then
			minetest.chat_send_player(pname, "?")
			return
		end
		local pcontrol = player:get_player_control()
		if pcontrol.down
		and pcontrol.up then
			add_to_inv(player, node)
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
			{"light", light or 0},
		}

		-- nodename (if not shown by F5)
		local nam = node.name
		local data = minetest.registered_nodes[nam]
		if not data then
			table.insert(infos, 1, {"name", nam})
		end

		-- nodedef dump
		if pcontrol.sneak
		and pcontrol.aux1
		and not pcontrol.up
		and not pcontrol.right then
			infos[#infos+1] = {"nodedata", dump(data)}
		end

		if pcontrol.left
		and pcontrol.right then
			if pcontrol.aux1 then
				-- node timer
				local nt = minetest.get_node_timer(pos)
				infos[#infos+1] = {"nodetimer",
					"started:"..tostring(nt:is_started())..
					",elapsed:"..tostring(nt:get_elapsed())..
					",timeout:"..tostring(nt:get_timeout())
				}
			else
				-- meta
				local t = minetest.get_meta(pos):to_table()
				local show
				for i in pairs(t) do
					if i ~= "inventory"
					and i ~= "fields" then
						show = true
					end
				end
				if not show then
					if next(t.inventory)
					or next(t.fields) then
						show = true
					end
				end
				infos[#infos+1] = {"meta", show and dump(t) or "default"}
			end
		end

		-- make msg and show it
		local msg = ""
		for i = 1,#infos do
			local n,i = unpack(infos[i])
			if i ~= 0 then
				msg = msg..n.."="..i..", "
			end
		end
		minetest.sound_play("superpick", {pos = pos, gain = 0.4, max_hear_distance = 10})
		if msg == "" then
			msg = data.description or nam
		else
			msg = string.sub(msg, 0, -3)
		end
		minetest.log("action", "[superpick] "..pname..": "..msg)
		minetest.chat_send_player(pname, msg)
	end

	--newhand.on_place = rc_info

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
		on_place = rc_info,
	})

	minetest.register_on_punchnode(function(pos, node, player)
		if player:get_wield_index() ~= 1
		or player:get_wielded_item():to_string() ~= "creative:pick"
		or node.name == "air" then
			return
		end
		local item = player:get_wielded_item():get_name()
		if item ~= "creative:pick"
		and item then
			return
		end
		local pname = player:get_player_name()
		if not minetest.check_player_privs(pname, {server=true}) then
			return
		end
		minetest.after(0.3, function(pos, name)
			if minetest.get_node(pos).name ~= "air"
			and not minetest.is_protected(pos, name) then
				minetest.log("info", "[superpick] force destroying node at ("..pos.x.."|"..pos.y.."|"..pos.z..")")
				minetest.remove_node(pos)
			end
		end, pos, pname)
		add_to_inv(player, node)
	end)

	local function cleaninventory(name)
		if not name
		or name == "" then
			return
		end
		local inv = minetest.get_player_by_name(name):get_inventory()
		local list = inv:get_list"main"
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
end

minetest.after(0, function(nh)
	minetest.override_item("", nh)
end, newhand)

minetest.log("info", string.format("[superpick] loaded after ca. %.2fs", os.clock() - load_time_start))
