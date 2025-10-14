for i,v in ipairs(verbname) do
    table.insert(editor_objlist_order, "text_"..verbname[i])
    table.insert(editor_objlist_order, "text_"..infixname[i])
    table.insert(editor_objlist_order, "text_"..infix2name[i])
    table.insert(editor_objlist_order, "text_"..prefixvname[i])

    editor_objlist["text_"..verbname[i]] = 
    {
    	name = "text_"..verbname[i],
    	sprite_in_root = false,
    	unittype = "text",
    	tags = {""},
    	tiling = -1,
    	type = 1,
    	layer = 20,
    	colour = inactivevcolours[i],
    	colour_active = activevcolours[i],
        argtype = arg[i],
        customobjects = customs[i],
        sprite = verbsprites[i]
    }
    editor_objlist["text_"..infixname[i]] = 
    {
	    name = "text_"..infixname[i],
	    sprite_in_root = false,
	    unittype = "text",
	    tags = {""},
	    tiling = -1,
	    type = 7,
	    layer = 20,
    	colour = inactivevcolours[i],
    	colour_active = activevcolours[i],
        argtype = arg[i],
        argextras = customs[i],
        sprite = infixsprites[i]
    }
    editor_objlist["text_"..infix2name[i]] = 
    {
	    name = "text_"..infix2name[i],
	    sprite_in_root = false,
	    unittype = "text",
	    tags = {""},
	    tiling = -1,
	    type = 7,
	    layer = 20,
    	colour = inactivevcolours[i],
    	colour_active = activevcolours[i],
        argtype = arg[i],
        argextras = customs[i],
        sprite = infix2sprites[i]
    }
    editor_objlist["text_"..prefixvname[i]] = 
    {
	    name = "text_"..prefixvname[i],
	    sprite_in_root = false,
	    unittype = "text",
	    tags = {""},
	    tiling = -1,
	    type = 3,
	    layer = 20,
    	colour = inactivevcolours[i],
    	colour_active = activevcolours[i],
        sprite = prefixvsprites[i]
    }

    condlist[infixname[i]] = function(params,checkedconds,checkedconds_,cdata)
	
        local allfound = 0
        local alreadyfound = {}
        local name,unitid,x,y,limit = cdata.name,cdata.unitid,cdata.x,cdata.y,cdata.limit
        if (#params > 0) then
            for a,b in ipairs(params) do
                local pname = b
                local pnot = false
                if (string.sub(b, 1, 4) == "not ") then
                    pnot = true
                    pname = string.sub(b, 5)
                end
                
                local bcode = b .. "_" .. tostring(a)
                
                if (featureindex[name] ~= nil) then
                    for c,d in ipairs(featureindex[name]) do
                        local drule = d[1]
                        local dconds = d[2]
                        
                        if (checkedconds[tostring(dconds)] == nil) then
                            if (pnot == false) then
                                if (drule[1] == name) and ((drule[2] == verbname[i]) or (drule[2] == "feel")) and (drule[3] == b) then
                                    checkedconds[tostring(dconds)] = 1
                                    
                                    if (alreadyfound[bcode] == nil) and testcond(dconds,unitid,x,y,nil,limit,checkedconds) then
                                        alreadyfound[bcode] = 1
                                        allfound = allfound + 1
                                        break
                                    end
                                end
                            else
                                if (string.sub(drule[3], 1, 4) ~= "not ") then
                                    local obj = unitreference["text_" .. drule[3]]
                                    
                                    if (obj ~= nil) then
                                        local objtype = getactualdata_objlist(obj,"type")
                                        
                                        if (objtype == 2) then
                                            if (drule[1] == name) and (drule[2] == verbname[i]) and (drule[3] ~= pname) then
                                                checkedconds[tostring(dconds)] = 1
                                                
                                                if (alreadyfound[bcode] == nil) and testcond(dconds,unitid,x,y,nil,limit,checkedconds) then
                                                    alreadyfound[bcode] = 1
                                                    allfound = allfound + 1
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            return false,checkedconds,true
        end
        
        --MF_alert(tostring(cdata.debugname) .. ", " .. tostring(allfound) .. ", " .. tostring(#params))
        
        return (allfound == #params),checkedconds,true
    end

    condlist[infix2name[i]] = function(params,checkedconds,checkedconds_,cdata)
	
        local allfound = 0
        local alreadyfound = {}
        local name,unitid,x,y,limit = cdata.name,cdata.unitid,cdata.x,cdata.y,cdata.limit
        if (#params > 0) then
            for a,b in ipairs(params) do
                local pname = b
                local pnot = false
                if (string.sub(b, 1, 4) == "not ") then
                    pnot = true
                    pname = string.sub(b, 5)
                end
                
                local bcode = b .. "_" .. tostring(a)
                
                if (featureindex[name] ~= nil) then
                    for c,d in ipairs(featureindex[name]) do
                        local drule = d[1]
                        local dconds = d[2]
                        
                        if (checkedconds[tostring(dconds)] == nil) then
                            if (pnot == false) then
                                if (drule[3] == name) and ((drule[2] == verbname[i]) or (drule[2] == "feel")) and (drule[1] == b) then
                                    checkedconds[tostring(dconds)] = 1
                                    
                                    if (alreadyfound[bcode] == nil) and testcond(dconds,unitid,x,y,nil,limit,checkedconds) then
                                        alreadyfound[bcode] = 1
                                        allfound = allfound + 1
                                        break
                                    end
                                end
                            else
                                if (string.sub(drule[3], 1, 4) ~= "not ") then
                                    local obj = unitreference["text_" .. drule[1]]
                                    
                                    if (obj ~= nil) then
                                        local objtype = getactualdata_objlist(obj,"type")
                                        
                                        if (objtype == 2) then
                                            if (drule[3] == name) and (drule[2] == verbname[i]) and (drule[1] ~= pname) then
                                                checkedconds[tostring(dconds)] = 1
                                                
                                                if (alreadyfound[bcode] == nil) and testcond(dconds,unitid,x,y,nil,limit,checkedconds) then
                                                    alreadyfound[bcode] = 1
                                                    allfound = allfound + 1
                                                    break
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        else
            return false,checkedconds,true
        end
        
        --MF_alert(tostring(cdata.debugname) .. ", " .. tostring(allfound) .. ", " .. tostring(#params))
        
        return (allfound == #params),checkedconds,true
    end

    condlist[prefixvname[i]] = function(params,checkedconds,checkedconds_,cdata)    
    local found = false
    local name,x,y,limit,subtype,conds = cdata.name,cdata.x,cdata.y,cdata.limit,cdata.subtype,tostring(cdata.conds)
    local fullname = verbname[i]

    if (featureindex[fullname] ~= nil) then
        for c,d in ipairs(featureindex[fullname]) do
            local drule = d[1]
            local dconds = d[2]
            
            if (checkedconds[tostring(dconds)] == nil) then
                if (string.sub(drule[1], 1, 4) ~= "not ") and (drule[2] == fullname) and (drule[3] == name) then
                    if (drule[1] ~= "empty") and (drule[1] ~= "level") then
                        if (unitlists[drule[1]] ~= nil) then
                            checkedconds[tostring(dconds)] = 1
                            
                            for e,f in ipairs(unitlists[drule[1]]) do
                                if testcond(dconds,f,x,y,nil,limit,checkedconds) then
                                    found = true
                                    break
                                end
                            end
                        end
                    elseif (drule[1] == "empty") then
                        local empties = findempty(dconds,true)
                        
                        if (#empties > 0) then
                            found = true
                        end
                    elseif (drule[1] == "level") and testcond(dconds,1,x,y,nil,limit,checkedconds) then
                        found = true
                    end
                end
            end
            
            if found then
                break
            end
        end
        
        -- MF_alert("New solution: " .. tostring(found) .. " " .. fullname)
    end
    
    checkedconds = checkedconds_ or {[tostring(conds)] = 1}
    
    return found,checkedconds,true
end
end
for i,v in ipairs(prefixpname) do
	table.insert(editor_objlist_order, "text_"..prefixpname[i])
	table.insert(editor_objlist_order, "text_"..propname[i])

	editor_objlist["text_"..prefixpname[i]] = 
    {
    	name = "text_"..prefixpname[i],
    	sprite_in_root = false,
    	unittype = "text",
    	tags = {""},
    	tiling = -1,
    	type = 3,
    	layer = 20,
    	colour = inactivepcolours[i],
    	colour_active = activepcolours[i],
        sprite = prefixpsprites[i]
    }
    editor_objlist["text_"..propname[i]] = 
    {
	    name = "text_"..propname[i],
	    sprite_in_root = false,
	    unittype = "text",
	    tags = {""},
	    tiling = -1,
	    type = 2,
	    layer = 20,
    	colour = inactivepcolours[i],
    	colour_active = activepcolours[i],
        sprite = propsprites[i]
    }

condlist[prefixpname[i]] = function(params,checkedconds,checkedconds_,cdata)
	
			local params = {propname[i]}
   			local allfound = 0
			local alreadyfound = {}
			local name,unitid,x,y,limit = cdata.name,cdata.unitid,cdata.x,cdata.y,cdata.limit
			if (#params > 0) then
				for a,b in ipairs(params) do
					local pname = b
					local pnot = false
					if (string.sub(b, 1, 4) == "not ") then
						pnot = true
						pname = string.sub(b, 5)
					end
					
					local bcode = b .. "_" .. tostring(a)
					
					if (featureindex[name] ~= nil) then
						for c,d in ipairs(featureindex[name]) do
							local drule = d[1]
							local dconds = d[2]
							
							if (checkedconds[tostring(dconds)] == nil) then
								if (pnot == false) then
									if (drule[1] == name) and ((drule[2] == "is") or (drule[2] == "feel")) and (drule[3] == b) then
										checkedconds[tostring(dconds)] = 1
										
										if (alreadyfound[bcode] == nil) and testcond(dconds,unitid,x,y,nil,limit,checkedconds) then
											alreadyfound[bcode] = 1
											allfound = allfound + 1
											break
										end
									end
								else
									if (string.sub(drule[3], 1, 4) ~= "not ") then
										local obj = unitreference["text_" .. drule[3]]
										
										if (obj ~= nil) then
											local objtype = getactualdata_objlist(obj,"type")
											
											if (objtype == 2) then
												if (drule[1] == name) and ((drule[2] == "is") or (drule[2] == "feel")) and (drule[3] ~= pname) then
													checkedconds[tostring(dconds)] = 1
													
													if (alreadyfound[bcode] == nil) and testcond(dconds,unitid,x,y,nil,limit,checkedconds) then
														alreadyfound[bcode] = 1
														allfound = allfound + 1
														break
													end
												end
											end
										end
									end
								end
							end
						end
					end
				end
			else
				return false,checkedconds,true
			end
			
			--MF_alert(tostring(cdata.debugname) .. ", " .. tostring(allfound) .. ", " .. tostring(#params))
			
			return (allfound == #params),checkedconds,true
		end

end

formatobjlist()