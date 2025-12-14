CHARGE_ERR_HAPPENING = false

MF_loadsound("uncharged1")
MF_loadsound("uncharged2")
MF_loadsound("uncharged3")

table.insert(nlist.full, "charge")
table.insert(nlist.short, "charge")
table.insert(nlist.objects, "charge")

table.insert(objlistdata.alltags, "charges")

table.insert(editor_objlist_order, "text_charge")

editor_objlist["text_charge"] = 
{
	name = "text_charge",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","abstract","charges"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {2, 1},
	colour_active = {2, 2},
}

table.insert(editor_objlist_order, "text_wires")

editor_objlist["text_wires"] = 
{
	name = "text_wires",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","abstract","text_verb","charges"},
	tiling = -1,
	type = 1,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 3},
	argtype = {2},
}

table.insert(editor_objlist_order, "text_unplug")

editor_objlist["text_unplug"] = 
{
	name = "text_unplug",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","abstract","text_quality","charges"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {3, 3},
	colour_active = {4, 4},
}

table.insert(editor_objlist_order, "text_charged")

editor_objlist["text_charged"] = 
{
	name = "text_charged",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","abstract","text_condition","charges"},
	tiling = -1,
	type = 7,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 3},
	argtype = {2},
}

table.insert(editor_objlist_order, "text_refers")

editor_objlist["text_refers"] = 
{
	name = "text_refers",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","abstract","text_condition","charges"},
	tiling = -1,
	type = 7,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 3},
	argtype = {0, 2},
}

charge_fix = {}

function addcharge(name,col)
	table.insert(editor_objlist_order, "charge_"..name)

	editor_objlist["charge_"..name] = 
	{
		name = "charge_"..name,
		sprite_in_root = false,
		unittype = "charge",
		tags = {"abstract","charges"},
		tiling = -1,
		type = 0,
		layer = 20,
		colour = col,
	}

	table.insert(charge_fix,"charge_"..name)
end

addcharge("unplug",{4,4})

addcharge("you",{4,1})
addcharge("you2",{4,1})
addcharge("win",{2,4})
addcharge("stop",{5,1})

addcharge("push",{6,1})
addcharge("pull",{6,2})
addcharge("swap",{3,1})
addcharge("move",{5,3})
addcharge("auto",{4,1})
addcharge("shift",{1,3})

addcharge("defeat",{2,1})
addcharge("weak",{1,2})
addcharge("sink",{1,3})
addcharge("hot",{2,3})
addcharge("melt",{1,3})
addcharge("open",{2,4})
addcharge("shut",{2,2})
addcharge("boom",{2,2})

addcharge("safe",{0,3})
addcharge("float",{1,4})
addcharge("phantom",{0,1})

addcharge("red",{2,2})
addcharge("blue",{3,3})

formatobjlist()

condlist["charged"] = function(params,checkedconds,checkedconds_,cdata)
	for a,b in ipairs(params) do
		local found = false
		for c,d in ipairs(units) do
			if (hasfeature(getname(d), "is", b, d.fixed)) and (not hasfeature(getname(d), "is", "unplug", d.fixed)) then
				found = true
				break
			end
		end

		local _,empties = findallfeature(nil, "is", b, false)

		if #empties > 0 then
			found = true
		end

		if not found then
			return false,checkedconds
		end
	end
	return true,checkedconds
end

function checkcharge()
	for a,b in ipairs(units) do
		if CHARGE_ERR_HAPPENING then
			return
		end
		if b.strings[UNITTYPE] == "charge" then
			local safe = false
			local checkfor = string.sub(b.strings[UNITNAME],8)

			for c,d in ipairs(units) do
				if (hasfeature(getname(d),"is",checkfor,d.fixed)) and (not hasfeature(getname(d),"is","unplug",d.fixed)) then
					safe = true
					break
				end
			end

			local _,empties = findallfeature(nil, "is", checkfor,false)

			if #empties > 0 then
				safe = true
			end

			if not safe then
				CHARGE_ERR_HAPPENING = true
				destroylevel("charge")
			end
		end
	end
end

table.insert(mod_hook_functions["undoed_after"],
	function()
		CHARGE_ERR_HAPPENING = false
	end
)

table.insert(mod_hook_functions["level_start"],
		function()
			CHARGE_ERR_HAPPENING = false
			for _,v in ipairs(charge_fix) do
				fullunitlist[v] = 1
			end
		end
)

table.insert(mod_hook_functions["effect_once"],
	function()
		checkcharge()
	end
)

function isadjective(word)
	if (word == "push") or (word == "select") or (word == "stop") or (word == "meta") or (word == "unmeta") or (word == "word") then
		return true
	end
	if (word == "error") or (word == "all") or (word == "createall") or (word == "text") or (word == "level") or (word == "empty") then
		return false
	end
	if string.sub(word,1,4) == "not " then
		return false
	end
	local altname = objectpalette["text_"..word]
	return (getactualdata_objlist(altname, "type") == 2)
end

function get_charges_for_effects_on_unitid(unitid, x, y)
	local result = {}
	local uname = "empty"
	if unitid ~= 2 then
		local unit = mmf.newObject(unitid)
		uname = unit.strings[UNITNAME]
		x, y = nil, nil
	end
	for _,v in ipairs(featureindex[uname]) do
		local brule = v[1]
		local conds = v[2]
		local effect = brule[3]
		if (brule[1] == uname) and (brule[2] == "is") and isadjective(effect) then
			if testcond(conds, unitid, x, y) then
				table.insert(result, "charge_"..effect)
			end
		end
	end
	return result
end