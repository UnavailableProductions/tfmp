--[[function inside(name,x,y,dir,unitid)
	local ins = findfeature(nil,"in",name)
	
	if (ins ~= nil) then
		for i,v in ipairs(ins) do
			if (v[2] == nil) or ((v[2] ~= nil) and ison(v,unitid)) then
				if (v[1] ~= "text") then
					for a,b in ipairs(materials) do
						if (b == v[1]) and (v[1] ~= "empty") then
							if (v[1] ~= "all") then
								create(v[1],x,y,dir)
							else
								createall(v,x,y,unitid)
							end
						end
					end
				else
					create("text_" .. name,x,y,dir)
				end
			end
		end
	end
end--]]

function inside(name,x,y,dir_,unitid,leveldata_)
	local ins = {}
	local tileid = x + y * roomsizex
	local maptile = unitmap[tileid] or {}
	local dir = dir_
	
	local leveldata = leveldata_ or {}
	
	if (dir == 4) then
		dir = fixedrandom(0,3)
	end
	
	if (featureindex[name] ~= nil) then
		for i,rule in ipairs(featureindex[name]) do
			local baserule = rule[1]
			local conds = rule[2]
			
			local target = baserule[1]
			local verb = baserule[2]
			local object = baserule[3]
			
			if (target == name) and (verb == "has") and (findnoun(object,nlist.short) or (unitreference[object] ~= nil)) then
				table.insert(ins, {object,conds})
			elseif (object == name) and (verb == "isin") and (findnoun(target,nlist.short) or (unitreference[target] ~= nil)) then
				table.insert(ins, {target,conds})
			end
		end
	end
	
	if (#ins > 0) then
		for i,v in ipairs(ins) do
			local object = v[1]
			local conds = v[2]
			if testcond(conds,unitid,x,y) then
				if (object ~= "text") then
					for a,mat in pairs(objectlist) do
						if (a == object) and (object ~= "empty") then
							if (object ~= "all") and (string.sub(object, 1, 5) ~= "group") then
								create(object,x,y,dir,nil,nil,nil,nil,leveldata)
							elseif (object == "all") then
								createall(v,x,y,unitid,nil,leveldata)
							end
						end
					end
				else
					create("text_" .. name,x,y,dir,nil,nil,nil,nil,leveldata)
				end
			end
		end
	end
end