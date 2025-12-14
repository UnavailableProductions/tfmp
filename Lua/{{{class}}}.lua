

local function setdefault(name, thing)
	if _G[name] == nil then
		_G[name] = thing
	end
end

local function addhook(place, func)
	table.insert(mod_hook_functions[place], func)
end

if broad_nouns == nil then
	broad_nouns = {}
	for _,v in ipairs(nlist.objects) do
		if (v ~= "empty") and (v ~= "obj") and (v ~= "build") and (not v:find("_")) then
			table.insert(broad_nouns, v)
		end
	end
end

special_prefixes = {}
for _, v in ipairs(broad_nouns) do
	table.insert(special_prefixes, v .. "_")
end

local backup_for_func_addunit = addunit
function addunit(id,undoing_,levelstart_, ...)
	if (levelstart_ == true) and (#objectpalette == 0) then
		createobjectpalette()
	end
	backup_for_func_addunit(id,undoing_,levelstart_, ...)
end

setdefault("is_str_special_prefix", function(str)
	for _, v in ipairs(special_prefixes) do
		if str == v then
			return true
		end
	end
	return false
end)

setdefault("is_str_special_prefixed", function(str)
	for _, v in ipairs(special_prefixes) do
		if string.sub(str, 1, string.len(v)) == v then
			return true
		end
	end
	return false
end)

setdefault("get_pref", function(str)
	for _, v in ipairs(special_prefixes) do
		if string.sub(str, 1, string.len(v)) == v then
			return v
		end
	end
	return ""
end)

setdefault("get_ref", function(str)
	for _, v in ipairs(special_prefixes) do
		if string.sub(str, 1, string.len(v)) == v then
			return string.sub(str, string.len(v) + 1)
		end
	end
	return str
end)

setdefault("get_text_type", function(name)
    if is_str_special_prefixed(name) and not is_str_special_prefix(name) then return 0 end
    local aname = "text_"..name
    if objectpalette[aname] ~= nil then
        local altname = objectpalette[aname]
		local result = getactualdata_objlist(altname, "type")
        return result
    end
    local result = editor_objlist[aname]
    if result ~= nil then return result.type end
    return -2
end)

function findclassunits()
	local result = {}
	local alreadydone = {}
	local checkrecursion = {}
	local related = {}
	
	local identifier = ""
	local fullid = {}
	
	if (featureindex["class"] ~= nil) then
		for i,v in ipairs(featureindex["class"]) do
			local rule = v[1]
			local conds = v[2]
			local ids = v[3]
			local tags = v[4]

			for _,tag in ipairs(tags) do
				if tag == "classy" then
					goto continue
				end
			end
			
			local name = rule[1]
			local subid = ""
			
			if (rule[2] == "is") then
				if (get_pref(name) ~= "text_") and (name ~= "text") and (name ~= empty) and (alreadydone[name] == nil) and (findnoun(name, nlist.objects)) then
					local these = findall({name,{}})
					alreadydone[name] = 1
					
					if (#these > 0) then
						for a,b in ipairs(these) do
							local bunit = mmf.newObject(b)
							local valid = true
							
							if (featureindex["broken"] ~= nil) then
								if (hasfeature(getname(bunit),"is","broken",b,bunit.values[XPOS],bunit.values[YPOS]) ~= nil) then
									valid = false
								end
							end
							
							if valid then
								table.insert(result, {b, conds})
								subid = subid .. name
								-- LISÄÄ TÄHÄN LISÄÄ DATAA
							end
						end
					end
				end
				
				if (#subid > 0) then
					for a,b in ipairs(conds) do
						local condtype = b[1]
						local params = b[2] or {}
						
						subid = subid .. condtype
						
						if (#params > 0) then
							for c,d in ipairs(params) do
								subid = subid .. tostring(d)
								
								related = findunits(d,related,conds)
							end
						end
					end
				end
				
				table.insert(fullid, subid)
			end

			:: continue ::
		end
		
		table.sort(fullid)
		for i,v in ipairs(fullid) do
			-- MF_alert("Adding " .. v .. " to id")
			identifier = identifier .. v
		end
		
		--MF_alert("Identifier: " .. identifier)
	end
	
	--MF_alert("Current id (end): " .. identifier)
	
	return result,identifier,related
end
classunits = {}
classid = ""
classrelated = {}
classfirsts = {}
addhook("rule_update", function(ran)
	if (HACK_INFINITY < 200) then
		classunits, classid, classrelated = findclassunits()
		classresult = {}
		local tocheck = {}
		if (#classunits > 0) then
			for i,v in ipairs(classunits) do
				if testcond(v[2],v[1]) then
					classresult[v[1]] = 1
					table.insert(tocheck, v[1])
				else
					classresult[v[1]] = 0
				end
			end
		end

		local wordunitresult = {}
			
		if (#wordunits > 0) then
			for i,v in ipairs(wordunits) do
				if testcond(v[2],v[1]) then
					wordunitresult[v[1]] = 1
				else
					wordunitresult[v[1]] = 0
				end
			end
		end

		local alreadyused = {}
		classfirsts = {}
		for iid, unitid in ipairs(tocheck) do
			local unit = mmf.newObject(unitid)
			local x, y = unit.values[XPOS], unit.values[YPOS]
			local ox, oy, nox, noy = 0, 0
			local tileid = x + y * roomsizex

			setcolour(unit.fixed)
			
			if (alreadyused[tileid] == nil) and (unit.values[TYPE] ~= 5) and (unit.flags[DEAD] == false) then
				for i = 1, 2 do
					local drs = dirs[i + 2]
					local ndrs = dirs[i]
					ox = drs[1]
					oy = drs[2]
					nox = ndrs[1]
					noy = ndrs[2]

					--MF_alert("Doing firstwords check for " .. unit.strings[UNITNAME] .. ", dir " .. tostring(i))

					local hm = codecheck(unitid, ox, oy, i, nil, wordunitresult)
					local hm2 = codecheck(unitid, nox, noy, i, nil, wordunitresult)

					if (#hm == 0) and (#hm2 > 0) then
						--MF_alert("Added " .. unit.strings[UNITNAME] .. " to firstwords, dir " .. tostring(i))
						local text = get_ref(unit.strings[UNITNAME])

						table.insert(classfirsts, { { unitid }, i, 1, text, get_text_type(text), {} })

						if (alreadyused[tileid] == nil) then
							alreadyused[tileid] = {}
						end

						alreadyused[tileid][i] = 1
					end
				end
			end
		end
	end
end)

addhook("rule_update_after", function(ran)
	if not ran then
		if letterunits[1] == 0 then
			letterunits = {}
		end
		
		for _,v in ipairs(classunits) do
			table.insert(wordunits, v)
		end

		for _,v in ipairs(classrelated) do
			table.insert(wordrelatedunits, v)
		end
	end
end)

local backup_for_func_formlettermap = formlettermap
function formlettermap()

	if (letterunits == nil) or (letterunits[1] == 0) then
		letterunits = {}
	end

	backup_for_func_formlettermap()

	if #letterunits == 0 and #classunits > 0 then
		letterunits = {0} -- HACKY WAY TO MAKE THE REST OF PARSING CODE RUN
	end
end

local backup_for_func_codecheck = codecheck
function codecheck(unitid,ox,oy,cdir_,ignore_end_,wordunitresult_, ...)
	local results, l, jl = backup_for_func_codecheck(unitid,ox,oy,cdir_,ignore_end_,wordunitresult_, ...)
	local unit = mmf.newObject(unitid)
	local x = unit.values[XPOS] + ox
	local y = unit.values[YPOS] + oy

	local cdir = cdir_ or 0
	
	if (cdir == 0) then
		MF_alert("CODECHECK - CDIR == 0 - why??")
	end
	
	local tileid = x + y * roomsizex
	
	if (unitmap[tileid] ~= nil) then
		for i,b in ipairs(unitmap[tileid]) do
			local v = mmf.newObject(b)
			local uname = v.strings[UNITNAME]
			
			if (v.flags[DEAD] == false) then
				if (string.sub(uname, 1, 5) ~= "text_") then
					if (#classunits > 0) then
						local valid = false
						
						if (classresult[b] ~= nil) and (classresult[b] == 1) then
							valid = true
						elseif (classresult[b] == nil) then
							for c,d in ipairs(classunits) do
								if (b == d[1]) and testcond(d[2],d[1]) then
									valid = true
									break
								end
							end
						end
						
						if valid then
							local text = get_ref(uname)
							table.insert(results, {{b}, 1, text, get_text_type(text), cdir})
						end
					end
				end
			end
		end
	end
	return results, l, jl
end

is_from_text = false
local backup_for_func_docode = docode
function docode(firsts)
	for _, v in ipairs(classfirsts) do
		table.insert(firsts, v)
	end
	is_from_text = true
	backup_for_func_docode(firsts)
	is_from_text = false
end

local backup_for_func_addoption = addoption
function addoption(option,conds_,idss,visible,notrule,tags_,...)
	local flag = false
	if is_from_text and (option[2] == "is") and (option[3] == "class") then
		local i = 0
		for _,ids in ipairs(idss) do
			if i == 3 then break end
			i = i + 1
			for _, id in ipairs(ids) do
				local unit = mmf.newObject(id)
				local name = unit.strings[UNITNAME]
				if (string.sub(name,1,5) ~= "text_") and (is_str_special_prefixed(name)) then
					flag = true
					if (i == 1) and (option[1] ~= get_ref(name)) then
						flag = false
					end
					break
				end
			end
		end
		if flag then
			tags_ = tags_ or {}
			for _,tag in ipairs(tags_) do
				if tag == "classy" then
					flag = false
					break
				end
			end
			if flag then
				table.insert(tags_, "classy")
			end
		end
	end
	backup_for_func_addoption(option,conds_,idss,visible,notrule,tags_,...)
end

runagain = false
local backup_for_func_postrules = postrules
function postrules(ran)
	result = backup_for_func_postrules(ran)
	local _,newclassid,__ = findclassunits()
	if (newclassid ~= classid) then
		runagain = true
	end
	return result
end

local backup_for_func_findwordunits = findwordunits
function findwordunits()
	if runagain then
		runagain = false
		return {}, 0, {}
	end
	c,b,a = backup_for_func_findwordunits()
	return c,b,a
end