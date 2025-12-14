local rulename = langtext("rules_colon")
local customrulelvls = {"1179level","2level"}
customrulelvls["2level"] = 'intro:'
customrulelvls["1179level"] = 'testering'
table.insert(mod_hook_functions["turn_end"],
    function()
        local lvl = generaldata.strings[CURRLEVEL]
		local rulenametoggle = false
		for i=1,#customrulelvls do
			if lvl == customrulelvls[i] then
				rulename = customrulelvls[lvl]
				rulenametoggle = true
			end	
		end
		if rulenametoggle == false then
			rulename = langtext("rules_colon")
		end
	end
)

currenttransform = "level"
holdenabled = 1


function writerules(parent,name,x_,y_)
	--[[ 
		@mods(this) - Override reason: Custom "this" rule display. Also remove unitid display when 
			forming "this(X) is float" and "Y mimic X"
	 ]]
	local basex = x_
	local basey = y_
	local linelimit = 12
	local maxcolumns = 4
	
	local x,y = basex,basey
	
	if (#visualfeatures > 0) then
		writetext(rulename,0,x,y,name,true,2,true)
	end
	
	local i_ = 1
	
	local count = 0
	local allrules = {}
	
	local custom = MF_read("level","general","customruleword")
	
	for i,rules in ipairs(visualfeatures) do
		local text = ""
		local rule = rules[1]
		
		if (#custom == 0) then
			text = text .. rule[1] .. " "
		else
			text = text .. custom .. " "
		end

		local conds = rules[2]
		local ids = rules[3]
		local tags = rules[4]

		local fullinvis = true
		for a,b in ipairs(ids) do
			for c,d in ipairs(b) do
				local dunit = mmf.newObject(d)
				
				if dunit.visible then
					fullinvis = false
				end
			end
		end
		
		for a,b in ipairs(tags) do
			if b == "mimic" then
				fullinvis = true
			end
		end
		
		if (fullinvis == false) then
			if (#conds > 0) then
				local num_this_conds = 0
				local this_cond = ""
				for a,cond in ipairs(conds) do
					local condtype = plasma_utils.real_condtype(cond[1])
					if condtype == "this" or condtype == "not this" then
						num_this_conds = num_this_conds + 1
						local pnoun_unitid = parse_this_unit_from_param_id(cond[2][1])
						local pnoun_unit = mmf.newObject(pnoun_unitid)

						if condtype == "this" then
							this_cond = pnoun_unit.strings[NAME]
						else
							this_cond = "not "..pnoun_unit.strings[NAME]
						end
					end
				end
				for a,cond in ipairs(conds) do
					local middlecond = true
					
					if (cond[2] == nil) or ((cond[2] ~= nil) and (#cond[2] == 0)) then
						middlecond = false
					end

					local condtype = plasma_utils.real_condtype(cond[1])
					if condtype == "this" or condtype == "not this" then
					elseif middlecond then
						if (#custom == 0) then
							local target = cond[1]
							local isnot = string.sub(target, 1, 4)
							local target_ = target
							
							if (isnot == "not ") then
								target_ = string.sub(target, 5)
							else
								isnot = ""
							end
							
							if (word_names[target_] ~= nil) then
								target = isnot .. word_names[target_]
							end
							
							text = text .. target .. " "
						else
							text = text .. custom .. " "
						end
						
						if (cond[2] ~= nil) then
							if (#cond[2] > 0) then
								for c,d in ipairs(cond[2]) do
									local this_param_name = parse_this_param_and_get_raycast_units(d)
									if this_param_name then
										text = text .. this_param_name.." "
									elseif (#custom == 0) then
										local target = d
										local isnot = string.sub(target, 1, 4)
										local target_ = target
										
										if (isnot == "not ") then
											target_ = string.sub(target, 5)
										else
											isnot = ""
										end
										
										if (word_names[target_] ~= nil) then
											target = isnot .. word_names[target_]
										end
										
										text = text .. target .. " "
									else
										text = text .. custom .. " "
									end
									
									if (#cond[2] > 1) and (c ~= #cond[2]) then
										text = text .. "& "
									end
								end
							end
						end
						
						if (a < #conds) then
							text = text .. "& "
						end
					else
						if cond[1] ~= "feelspast" and cond[1] ~= "feelsfuture" then

							if (#custom == 0) then
							text = cond[1] .. " " .. text
							else
							text = custom .. " " .. text
							end
						end
					end
				end
			end
			
			local target = rule[3]
			local isnot = string.sub(target, 1, 4)
			local target_ = target
			
			if (isnot == "not ") then
				target_ = string.sub(target, 5)
			else
				isnot = ""
			end
			
			if (word_names[target_] ~= nil) then
				target = isnot .. word_names[target_]
			end
			
			if (#custom == 0) then
				text = text .. rule[2] .. " " .. target
			else
				text = text .. custom .. " " .. custom
			end
			
			for a,b in ipairs(tags) do
				if (b == "mimic") then
					text = text .. " "
				end
			end

			for a,b in ipairs(tags) do
				if (b == "keep") then
					text = text .. " (keep)"
				end
			end

			if (allrules[text] == nil) then
				allrules[text] = 1
				count = count + 1
			else
				allrules[text] = allrules[text] + 1
			end
			i_ = i_ + 1
		end
	end
	
	local columns = math.min(maxcolumns, math.floor((count - 1) / linelimit) + 1)
	local columnwidth = math.min(screenw - f_tilesize * 2, columns * f_tilesize * 10) / columns
	
	i_ = 1
	
	local maxlimit = 4 * linelimit
	
	for i,v in pairs(allrules) do
		local text = i
		
		if (i_ <= maxlimit) then
			local currcolumn = math.floor((i_ - 1) / linelimit) - (columns * 0.5)
			x = basex + columnwidth * currcolumn + columnwidth * 0.5
			y = basey + (((i_ - 1) % linelimit) + 1) * f_tilesize * 0.8
		end
		
		if (i_ <= maxlimit-1) then
			if (v == 1) then
				writetext(text,0,x,y,name,true,2,true)
			elseif (v > 1) then
				writetext(tostring(v) .. " x " .. text,0,x,y,name,true,2,true)
			end
		end
		
		i_ = i_ + 1
	end
	
	if (i_ > maxlimit-1) then
		writetext("(+ " .. tostring(i_ - maxlimit) .. ")",0,x,y,name,true,2,true)
	end
	local y = 465
	
	local conditions = customconditions[generaldata.strings[CURRLEVEL]]
	if conditions then
        for c,d in ipairs(conditions) do
		local passed = testclearcond(d)
		local prefix = "♏"
		if passed then
			prefix = "♄"
		end

		if (d[1] == "level" or d[1] == "gate") and (editor.values[INEDITOR] ~= 0) then
			prefix = "$2,2e"
		end
			if d[1] == "noneof" then
				local text = "$2,1win $0,3without $2,1any $2,2"..d[2].."(s) $2,1in the level"

				if COMPACT_COND_MSG then
					text = "$2,2"..d[2]	
				end

				writetext(prefix.." $0,3None of - "..text,0,9,y,name,false,2,true)
				y = y - 18
			end
			if d[1] == "turns" then	
				local current = turns
				local extras = "currently on $0,3"..turns.." $1,2turns"
				local text = "$1,4win in $0,3"..d[2].." $1,4or less turns"

				if COMPACT_COND_MSG then
					extras = turns
					text = "$1,4"..d[2]	
				end

				if not COMPACT_COND_MSG then
					writetext("  $1,2("..extras..")",0,9,y,name,false,2,true)	
					y = y - 18	
					writetext(prefix.." $0,3Turns - "..text,0,9,y,name,false,2,true)	
					y = y - 18	
				else
					writetext(prefix.." $0,3Turns - "..text.." $1,2("..extras..")",0,9,y,name,false,2,true)	
					y = y - 18
				end	

			end
			if d[1] == "makerule" then	
				local text = "$5,4"..d[2].." "..d[3].." "..d[4].." $5,2must be $0,3true $5,2to win the level"

				if COMPACT_COND_MSG then
					text = "$5,4"..d[2].." "..d[3].." "..d[4]	
				end

				writetext(prefix.." $0,3True rule - "..text,0,9,y,name,false,2,true)	
				y = y - 18
			end
			if d[1] == "breakrule" then	
				local text = "$4,1"..d[2].." "..d[3].." "..d[4].." $4,0must be $0,3false $4,0to win the level"

				if COMPACT_COND_MSG then
					text = "$4,1"..d[2].." "..d[3].." "..d[4]	
				end
			
				writetext(prefix.." $0,3False rule - "..text,0,9,y,name,false,2,true)	
				y = y - 18
			end
			if d[1] == "amount" then
				if not COMPACT_COND_MSG then
					if d[4] == "exact" then			
						writetext(prefix.." $0,3amount - $6,1win with $0,3exactly $2,4"..d[3].." "..d[2].."$6,1(s) in the level",0,9,y,name,false,2,true)
					elseif d[4] == "more" then
						writetext(prefix.." $0,3amount - $6,1win with $0,3more than $2,4"..d[3].." "..d[2].."$6,1(s) in the level",0,9,y,name,false,2,true)
					elseif d[4] == "less" then
						writetext(prefix.." $0,3amount - $6,1win with $0,3less than $2,4"..d[3].." "..d[2].."$6,1(s) in the level",0,9,y,name,false,2,true)
					end
				else
					local text = "$2,4"..d[2].." x"..d[3].." ("..d[4]..")"
					writetext(prefix.." $0,3amount - "..text,0,9,y,name,false,2,true)
				end
				y = y - 18
			end
			if d[1] == "infix" then
				local text = "$3,0win with all $3,1"..d[3].."(s) $0,3"..d[2].." $3,1"..d[4].."(s)"

				if COMPACT_COND_MSG then
					text = "$3,1"..d[3].." "..d[2].." "..d[4]	
				end

				writetext(prefix.." $0,3Infix - "..text,0,9,y,name,false,2,true)
				y = y - 18
			end
			if d[1] == "prefix" then
				local text = "$5,1win with all $5,2"..d[3].."(s) $5,1being $0,3"..d[2]

				if COMPACT_COND_MSG then
					text = "$5,2"..d[2].." "..d[3]
				end

				writetext(prefix.." $0,3Prefix - "..text,0,9,y,name,false,2,true)
				y = y - 18
			end
			if d[1] == "base" then
				local text = "$0,1win with $0,3"..d[2].." "..d[3].." "..d[4].." $0,1as a baserule"

				if COMPACT_COND_MSG then
					text = "$0,2"..d[2].." "..d[3].." "..d[4]	
				end

				writetext(prefix.." $0,3Baserule - "..text,0,9,y,name,false,2,true)
				y = y - 18
			end
			if d[1] == "gate" then
				local text = "$0,1win the level with at least $0,3".. d[3] .." ".. d[2] .. "$0,1(s)"

				if COMPACT_COND_MSG then
					text = "$0,2"..d[2].." x"..d[3]
				end

				writetext(prefix.." $0,3Gate - "..text,0,9,y,name,false,2,true)
				y = y - 18
			end
			if d[1] == "level" then
				local current = currenttransform
				local extras = "level is currently: $0,3" .. current
				local text = "$4,1win with the level transformed as $0,3".. d[2]

				if COMPACT_COND_MSG then
					extras = current
					text = "$4,1"..d[2]	
				end

				if not COMPACT_COND_MSG then
					writetext("  $4,0(".. extras .. "$4,0)",0,9,y,name,false,2,true)
					y = y - 18
					writetext(prefix.." $0,3Level - "..text,0,9,y,name,false,2,true)
					y = y - 18
				else
					writetext(prefix.." $0,3Level - "..text.." $4,0("..extras..")",0,9,y,name,false,2,true)	
					y = y - 18
				end
			end
			if d[1] == "float" then	
				local text = "$1,2win with $1,4"..d[2].." $1,2and $1,4"..d[3].." $1,2on the $0,3same $1,2float level"

				if COMPACT_COND_MSG then
					text = "$1,4"..d[2]	
				end

				writetext(prefix.." $0,3Float - "..text,0,9,y,name,false,2,true)	
				y = y - 18
			end
			if d[1] == "compare" then
				if not COMPACT_COND_MSG then
					if d[4] == "exact" then			
						writetext(prefix.." $0,3compare - $6,1win with $0,3the same amount of $2,4"..d[2].."$6,1(s) and $2,4"..d[3].."$6,1(s) in the level",0,9,y,name,false,2,true)
					elseif d[4] == "more" then
						writetext(prefix.." $0,3compare - $6,1win with $0,3more $2,4"..d[2].."$6,1(s) than $2,4"..d[3].."$6,1(s) in the level",0,9,y,name,false,2,true)
					elseif d[4] == "less" then
						writetext(prefix.." $0,3compare - $6,1win with $0,3less $2,4"..d[2].."$6,1(s) than $2,4"..d[3].."$6,1(s) in the level",0,9,y,name,false,2,true)
					end
				else
					local text = "$2,4"..d[2].." compared to "..d[3].." ("..d[4]..")"
					writetext(prefix.." $0,3compare - "..text,0,9,y,name,false,2,true)
				end
				y = y - 18
			end
		end
		if COMPACT_COND_MSG then
			writetext("$0,3clear conditions $0,1("..clearcondspassed().."/"..#conditions..")$0,3:",0,5,y,name,false,2,true)
		else
			writetext("$0,3clear conditions $0,1("..clearcondspassed().."/"..#conditions..")$0,3:",0,5,y-10,name,false,2,true)
		end
	end	
end
