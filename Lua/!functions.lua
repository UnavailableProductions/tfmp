turns = 0
alive = {}

function testclearcond(cond)
	local d = cond
	if d[1] == "noneof" then
		if testcond({{"without", {d[2]}}},1) then
			return true
		end
	end
	if d[1] == "turns" then
		if turns <= (d[2] - 1) then
			return true
		end
	end
	if d[1] == "makerule" then
		local orthadox = findallfeature(d[2], d[3], d[4])
		if #orthadox > 0 then
			return true
		end
	end
	if d[1] == "breakrule" then
		local orthadox = findallfeature(d[2], d[3], d[4])
		if #orthadox < 1 then
			return true
		end
	end
	if d[1] == "amount" then
		if unitlists[d[2]] ~= nil then
			if d[4] == "exact" then
				if #unitlists[d[2]] == d[3] then
					return true
				end
			elseif d[4] == "more" then
				if #unitlists[d[2]] > d[3] then
					return true
				end
			elseif d[4] == "less" then
				if #unitlists[d[2]] < d[3] then
					return true
				end
			end
		end
	end
	if d[1] == "infix" then
		local didpass = true
		if d[3] ~= "level" and d[3] ~= "empty" then
			if unitlists[d[3]] ~= nil then
				for e,f in ipairs(unitlists[d[3]]) do
					if not testcond({{d[2], {d[4]}}},f) then
						didpass = false
						break
					end
				end
				if didpass then
					return true
				end
			end
		else
			if d[3] == "level" then
				if not testcond({{d[2], {d[4]}}},1) then
					didpass = false
				end
			else
				if not testcond({{d[2], {d[4]}}},2) then
					didpass = false
				end
			end
			if didpass then
				return true
			end
		end
	end
	if d[1] == "prefix" then
		local didpass = true
		if unitlists[d[3]] ~= nil then
			for e,f in ipairs(unitlists[d[3]]) do
				if not testcond({{d[2], {}}},f) then
					didpass = false
					break
				end
			end
			if didpass then
				return true
			end
		end
	end
	if d[1] == "base" then
		return true
	end
	if d[1] == "gate" then
		local prizes = tonumber(MF_read("save",generaldata.strings[WORLD] .. "_prize","total")) or 0
		local clears = tonumber(MF_read("save",generaldata.strings[WORLD] .. "_clears","total")) or 0
		local bonus = tonumber(MF_read("save",generaldata.strings[WORLD] .. "_bonus","total")) or 0
		local localprizes = tonumber(MF_read("save",generaldata.strings[WORLD] .. "_prize",generaldata.strings[CURRLEVEL])) or 0

		if d[2] == "orb" then
			if bonus >= d[3] then
				return true
			end
		elseif d[2] == "blossom" then
			if clears >= d[3] then
				return true
			end
		elseif d[2] == "spore" then
			if prizes >= d[3] then
				return true
			end
		elseif d[2] == "local spore" then
			if localprizes >= d[3] then
				return true
			end
		end

		if (editor.values[INEDITOR] ~= 0) then
			return true
		end
	end
	if d[1] == "level" then
		if currenttransform == d[2] or (editor.values[INEDITOR] ~= 0)  then
			return true
		end
	end
	if d[1] == "float" then
		if unitlists[d[2]] ~= nil and unitlists[d[3]] ~= nil then
			for e,f in ipairs(unitlists[d[2]]) do
				local funit = mmf.newObject(f)
				for g,h in ipairs(unitlists[d[3]]) do
					local hunit = mmf.newObject(h)
					if floating(f,h,funit.values[XPOS],funit.values[YPOS],hunit.values[XPOS],hunit.values[YPOS]) then
						return true
					end
				end
			end
		end
	end
	if d[1] == "compare" then
		if unitlists[d[2]] ~= nil and unitlists[d[3]] ~= nil then
			if d[4] == "exact" then
				if #unitlists[d[2]] == #unitlists[d[3]] then
					return true
				end
			elseif d[4] == "more" then
				if #unitlists[d[2]] > #unitlists[d[3]] then
					return true
				end
			elseif d[4] == "less" then
				if #unitlists[d[2]] < #unitlists[d[3]] then
					return true
				end
			end
		end
	end

	return false
end

function testwinconds()
	local conditions = customconditions[generaldata.strings[CURRLEVEL]]
	if conditions then
	       	for c,d in ipairs(conditions) do
			if testclearcond(d) == false then
				return false
			end
		end
	end
	return true
end

table.insert(mod_hook_functions["turn_end"],
	function()
		turns = turns + 1
	end
)

table.insert(mod_hook_functions["level_end"],
	function()
		currenttransform = "level"
	end
)

table.insert(mod_hook_functions["undoed_after"],
	function()
		turns = turns - 1
		if turns < 0 then
			turns = 0
		end
	end
)

local function script_path()
    local str = debug.getinfo(1).source:sub(2)
    return str:match("(.*/)")
end

table.insert(mod_hook_functions["level_start"],
	function()
		turns = 0
	end
)

table.insert(mod_hook_functions["rule_baserules"],
	function()
		local conditions = customconditions[generaldata.strings[CURRLEVEL]]
		if conditions then
       			for c,d in ipairs(conditions) do
				if d[1] == "base" then
					addoption({d[2],d[3],d[4]},{},{},false,nil,{"base"})
				end
			end
		end
	end
)

function clearcondspassed()
	local passed = 0

	local conditions = customconditions[generaldata.strings[CURRLEVEL]]
	if conditions then
	       	for c,d in ipairs(conditions) do
			if testclearcond(d) then
				passed = passed + 1
			end
		end
	end
	return passed
end