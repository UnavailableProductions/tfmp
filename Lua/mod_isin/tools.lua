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