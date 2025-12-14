function findobstacle(x,y,rad_,style_)
	if inbounds(x,y,2) then
		local layer = map[0]
		local tile = layer:get_x(x,y)
		local result = {}
		local tileid = x + y * roomsizex
		
		--if (tile ~= 255) then
			--table.insert(result, -1)
		--end
		
		for i,unit in ipairs(units) do
            local ux,uy = unit.values[XPOS],unit.values[YPOS]
            
            if intersect(x,y,ux,uy,rad_,style_) then
                if (unit.flags[DEAD] == false) then
                    table.insert(result, unit.fixed)
                else
                    MF_alert("Unitmap: found removed unit " .. unit.strings[UNITNAME])
                end
            end
		end
		
		return result
	else
		return {-1}
	end
end

function findallhere(x,y,exclude_,fpaths_)
	local result = {}
	
	local exclude = 0
	if (exclude_ ~= nil) then
		exclude = exclude_
	end
	
	local fpaths = false
	if (fpaths_ ~= nil) then
		fpaths = fpaths_
	end
	
	local tileid = x + y * roomsizex
    local sect = findintersect(x,y,{0,0},2)
	
    for i,unitid in ipairs(sect) do
        if (unitid ~= exclude) then
            table.insert(result, unitid)
        end
    end
	
	if fpaths then
		local pathshere = MF_findpaths(x,y)
		
		if (#pathshere > 0) then
			for i,v in ipairs(pathshere) do
				table.insert(result, v)
			end
		end
	end
	
	return result
end

function inbounds(x,y,style_)
	local style = style_ or 0
	
    if (style == 2) then
        return (x >= 1) and (y >= 1) and (x <= roomsizex-2) and (y <= roomsizey-2)
	elseif (style == 1) then
		return (x > 0) and (y > 0) and (x < roomsizex - 1) and (y < roomsizey - 1)
	else
		return (x >= 0) and (y >= 0) and (x < roomsizex) and (y < roomsizey)
	end
end

function findtype(typedata,x,y,unitid_,just_testing_)
	local result = {}
	local unitid = 0
	local tileid = x + y * roomsizex
	local name = typedata[1]
	local conds = typedata[2]
	
	local just_testing = just_testing_ or false
	
	if (unitid_ ~= nil) then
		unitid = unitid_
	end
	
    local sect = findintersect(x,y)
	
    for i,v in ipairs(sect) do
        if (v ~= unitid) then

            local unit = mmf.newObject(v)
            
            if (unit.strings[UNITNAME] == name) or ((unit.strings[UNITTYPE] == "text") and (name == "text")) then
                if testcond(conds,v) then
                    table.insert(result, v)
                    
                    if just_testing then
                        return result
                    end
                end
            end
        end
    end
	
	return result
end

function findfeatureat(rule1,rule2,rule3,x,y,blockers_,checkedconds)
	local result = {}
	local blockers = blockers_ or {}
	local targets = findfeature(rule1,rule2,rule3)
	
	if (targets ~= nil) then
		local tileid = x + y * roomsizex
		
        local sect = findintersect(x,y)
        for a,unitid in ipairs(sect) do

            local unit = mmf.newObject(unitid)
            local name = getname(unit)
            
            for i,v in ipairs(targets) do
                if (name == v[1]) then
                    local valid = true
                    
                    for c,d in ipairs(blockers) do
                        local testing = hasfeature(name,"is",d,unitid,x,y,checkedconds)
                        
                        if (testing ~= nil) then
                            valid = false
                            break
                        end
                    end
                    
                    if valid then
                        local conds = v[2]
                        if testcond(conds,unit.fixed,nil,nil,nil,nil,checkedconds) then
                            table.insert(result, unit.fixed)
                        end
                    end
                end
            end
        end
	end
	
	if (#result > 0) then
		return result
	else
		return nil
	end
end

function intersect(x1,y1,x2,y2,rad_,style_)
    local style = style_ or 0
    local rad = rad_ or {1,1}

    if style == 3 then
        if (math.abs(x2-x1) < rad[1] or math.abs(x2-x1) == 0) and (math.abs(y2-y1) < rad[2] or math.abs(y2-y1) == 0) then
            return true
        end
    elseif style == 2 then
        if math.abs(x2-x1) <= rad[1] and math.abs(y2-y1) <= rad[2] then
            return true
        end
    elseif style == 1 then
        if (math.abs(x2-x1) == rad[1]) ~= (math.abs(y2-y1) == rad[2]) then
            return true
        end
    else
        if math.abs(x2-x1) < rad[1] and math.abs(y2-y1) < rad[2] then
            return true
        end
    end
    return false
end

function findintersect(x,y,rad_,style_)
    local result = {}
    for i,unit in ipairs(units) do
        local ux,uy = unit.values[XPOS],unit.values[YPOS]
        if intersect(x,y,ux,uy,rad_,style_) then
            table.insert(result, unit.fixed)
        end
    end
    return result
end

function intersectobj(name,x,y,rad_,style_)
    for i,unit in ipairs(units) do
        local ux,uy = unit.values[XPOS],unit.values[YPOS]
        if getname(unit) == name and intersect(x,y,ux,uy,rad_,style_) then
            return true
        end
    end
    return false
end