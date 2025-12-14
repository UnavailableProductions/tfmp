function undo()
	local result = 0
	HACK_INFINITY = 0
	logevents = false
	
	if (#undobuffer > 1) then
		result = 1
		local currentundo = undobuffer[2]
		
		-- MF_alert("Undoing: " .. tostring(#undobuffer))
		
		do_mod_hook("undoed")
		
		last_key = currentundo.key or 0
		Fixedseed = currentundo.fixedseed or 100
		
		if (currentundo ~= nil) then
			for i,line in ipairs(currentundo) do
				local style = line[1]
				
				if (style == "update") then
					local uid = line[9]
					
					if (paradox[uid] == nil) then
						local unitid = getunitid(line[9])
						
						local unit = mmf.newObject(unitid)
						
						local oldx,oldy = unit.values[XPOS],unit.values[YPOS]
						local x,y,dir = line[3],line[4],line[5]
						unit.values[XPOS] = x
						unit.values[YPOS] = y
						unit.values[DIR] = dir
						unit.values[POSITIONING] = 0
						
						updateunitmap(unitid,oldx,oldy,x,y,unit.strings[UNITNAME])
						dynamic(unitid)
						dynamicat(oldx,oldy)
						
						if (spritedata.values[CAMTARGET] == uid) then
							MF_updatevision(dir)
						end
						
						local ox = math.abs(oldx-x)
						local oy = math.abs(oldy-y)
						
						if (ox + oy <= 1 and ox + oy > 0) and (unit.values[TILING] == 2) then
							unit.values[VISUALDIR] = ((unit.values[VISUALDIR] - 1)+4) % 4
							unit.direction = unit.values[DIR] * 8 + unit.values[VISUALDIR]
						end
						
						if (unit.strings[UNITTYPE] == "text") then
							updatecode = 1
						end
						
						local undowordunits = currentundo.wordunits
						local undowordrelatedunits = currentundo.wordrelatedunits
						
						if (#undowordunits > 0) then
							for a,b in pairs(undowordunits) do
								if (b == line[9]) then
									updatecode = 1
								end
							end
						end
						
						if (#undowordrelatedunits > 0) then
							for a,b in pairs(undowordrelatedunits) do
								if (b == line[9]) then
									updatecode = 1
								end
							end
						end
					else
						particles("hot",line[3],line[4],1,{1, 1})
					end
				elseif (style == "remove") then
					local uid = line[6]
					local baseuid = line[7] or -1
					
					if (paradox[uid] == nil) and (paradox[baseuid] == nil) then
						local x,y,dir,levelfile,levelname,vislevel,complete,visstyle,maplevel,colour,clearcolour,followed,back_init,ogname,signtext = line[3],line[4],line[5],line[8],line[9],line[10],line[11],line[12],line[13],line[14],line[15],line[16],line[17],line[18],line[19]
						local name = line[2]
						
						local unitname = ""
						local unitid = 0
						
						--MF_alert("Trying to create " .. name .. ", " .. tostring(unitreference[name]))
						unitname = unitreference[name]
						if (name == "level") and (unitreference[name] ~= "level") then
							unitname = "level"
							unitreference["level"] = "level"
							MF_alert("ALERT! Unitreference for level was wrong!")
						end
						
						unitid = MF_emptycreate(unitname,x,y)
						
						local unit = mmf.newObject(unitid)
						unit.values[ONLINE] = 1
						unit.values[XPOS] = x
						unit.values[YPOS] = y
						unit.values[DIR] = dir
						unit.values[ID] = line[6]
						unit.flags[9] = true
						
						unit.strings[U_LEVELFILE] = levelfile
						unit.strings[U_LEVELNAME] = levelname
						unit.flags[MAPLEVEL] = maplevel
						unit.values[VISUALLEVEL] = vislevel
						unit.values[VISUALSTYLE] = visstyle
						unit.values[COMPLETED] = complete
						
						unit.strings[COLOUR] = colour
						unit.strings[CLEARCOLOUR] = clearcolour
						unit.strings[UNITSIGNTEXT] = signtext or ""
						
						if (unit.className == "level") then
							MF_setcolourfromstring(unitid,colour)
						end
						
						addunit(unitid,true)
						addunitmap(unitid,x,y,unit.strings[UNITNAME])
						dynamic(unitid)
						
						unit.followed = followed
						unit.back_init = back_init
						unit.originalname = ogname
						
						if (unit.strings[UNITTYPE] == "text") then
							updatecode = 1
						end
						
						if (spritedata.values[VISION] == 1) then
							unit.x = -24
							unit.y = -24
						end
						
						local undowordunits = currentundo.wordunits
						local undowordrelatedunits = currentundo.wordrelatedunits
						
						if (#undowordunits > 0) then
							for a,b in ipairs(undowordunits) do
								if (b == line[6]) then
									updatecode = 1
								end
							end
						end
						
						if (#undowordrelatedunits > 0) then
							for a,b in ipairs(undowordrelatedunits) do
								if (b == line[6]) then
									updatecode = 1
								end
							end
						end
					else
						particles("hot",line[3],line[4],1,{1, 1})
					end
				elseif (style == "create") then
					local uid = line[3]
					local baseid = line[4]
					local source = line[5]
					
					if (paradox[uid] == nil) then
						local unitid = getunitid(line[3])
						
						local unit = mmf.newObject(unitid)
						local unitname = unit.strings[UNITNAME]
						local x,y = unit.values[XPOS],unit.values[YPOS]
						local unittype = unit.strings[UNITTYPE]
						
						unit = {}
						delunit(unitid)
						MF_remove(unitid)
						dynamicat(x,y)
						
						if (unittype == "text") then
							updatecode = 1
						end
						
						local undowordunits = currentundo.wordunits
						local undowordrelatedunits = currentundo.wordrelatedunits
						
						if (#undowordunits > 0) then
							for a,b in ipairs(undowordunits) do
								if (b == line[3]) then
									updatecode = 1
								end
							end
						end
						
						if (#undowordrelatedunits > 0) then
							for a,b in ipairs(undowordrelatedunits) do
								if (b == line[3]) then
									updatecode = 1
								end
							end
						end
					end
				elseif (style == "backset") then
					local uid = line[3]
					
					if (paradox[uid] == nil) then
						local unitid = getunitid(line[3])
						local unit = mmf.newObject(unitid)
						
						unit.back_init = line[4]
					end
				elseif (style == "done") then
					local unitid = line[7]
					--print(unitid)
					local unit = mmf.newObject(unitid)
					
					unit.values[FLOAT] = line[8]
					unit.angle = 0
					unit.values[POSITIONING] = 0
					unit.values[A] = 0
					unit.values[VISUALLEVEL] = 0
					unit.flags[DEAD] = false
					
					--print(unit.className .. ", " .. tostring(unitid) .. ", " .. tostring(line[3]) .. ", " .. unit.strings[UNITNAME])
					
					addunit(unitid,true)
					unit.originalname = line[9]
					
					if (unit.values[TILING] == 1) then
						dynamic(unitid)
					end
				elseif (style == "float") then
					local uid = line[3]
					
					if (paradox[uid] == nil) then
						local unitid = getunitid(line[3])
						
						-- K�kk� ratkaisu!
						if (unitid ~= nil) and (unitid ~= 0) then
							local unit = mmf.newObject(unitid)
							unit.values[FLOAT] = tonumber(line[4])
						end
					end
				elseif (style == "levelupdate") then
					MF_setroomoffset(line[2],line[3])
					mapdir = line[6]
				elseif (style == "maprotation") then
					maprotation = line[2]
					MF_levelrotation(maprotation)
				elseif (style == "mapdir") then
					mapdir = line[2]
				elseif (style == "mapcursor") then
					mapcursor_set(line[3],line[4],line[5],line[10])
					
					local undowordunits = currentundo.wordunits
					local undowordrelatedunits = currentundo.wordrelatedunits
					
					local unitid = getunitid(line[10])
					if (unitid ~= nil) and (unitid ~= 0) then
						local unit = mmf.newObject(unitid)
						
						if (unit.strings[UNITTYPE] == "text") then
							updatecode = 1
						end
					end
					
					if (#undowordunits > 0) then
						for a,b in pairs(undowordunits) do
							if (b == line[10]) then
								updatecode = 1
							end
						end
					end
					
					if (#undowordrelatedunits > 0) then
						for a,b in pairs(undowordrelatedunits) do
							if (b == line[10]) then
								updatecode = 1
							end
						end
					end
				elseif (style == "colour") then
					local unitid = getunitid(line[2])
					MF_setcolour(unitid,line[3],line[4])
					local unit = mmf.newObject(unitid)
					unit.values[A] = line[5]
				elseif (style == "broken") then
					local unitid = getunitid(line[3])
					local unit = mmf.newObject(unitid)
					--MF_alert(unit.strings[UNITNAME])
					unit.broken = 1 - line[2]
				elseif (style == "bonus") then
					local style = 1 - line[2]
					MF_bonus(style)
				elseif (style == "followed") then
					local unitid = getunitid(line[2])
					local unit = mmf.newObject(unitid)
					
					unit.followed = line[3]
				elseif (style == "startvision") then
					local target = line[2]
					
					if (line[2] ~= 0) and (line[2] ~= 0.5) then
						target = getunitid(line[2])
					end
					
					visionmode(0,target,true)
				elseif (style == "stopvision") then
					local target = line[2]
					
					if (line[2] ~= 0) and (line[2] ~= 0.5) then
						target = getunitid(line[2])
					end
					
					visionmode(1,target,true,{line[3],line[4],line[5]})
				elseif (style == "visiontarget") then
					local unitid = getunitid(line[2])
					
					if (spritedata.values[VISION] == 1) and (unitid ~= 0) then
						local unit = mmf.newObject(unitid)
						MF_updatevision(unit.values[DIR])
						MF_updatevisionpos(unit.values[XPOS],unit.values[YPOS])
						spritedata.values[CAMTARGET] = line[2]
					end
				elseif (style == "holder") then
					local unitid = getunitid(line[2])
					local unit = mmf.newObject(unitid)
					
					unit.holder = line[3]
				end
			end
		end
		
		local nextundo = undobuffer[1]
		nextundo.wordunits = {}
		nextundo.wordrelatedunits = {}
		nextundo.visiontargets = {}
		nextundo.fixedseed = Fixedseed
		
		for i,v in ipairs(currentundo.wordunits) do
			table.insert(nextundo.wordunits, v)
		end
		for i,v in ipairs(currentundo.wordrelatedunits) do
			table.insert(nextundo.wordrelatedunits, v)
		end
		
		if (#currentundo.visiontargets > 0) then
			visiontargets = {}
			for i,v in ipairs(currentundo.visiontargets) do
				table.insert(nextundo.visiontargets, v)
				
				local fix = MF_getfixed(v)
				if (fix ~= nil) then
					table.insert(visiontargets, fix)
				end
			end
		end
		
		table.remove(undobuffer, 2)
	end
	
	--MF_alert("Current fixed seed: " .. tostring(Fixedseed))
	
	do_mod_hook("undoed_after")
	logevents = true
	
	return result
end

function delete(unitid,x_,y_,total_,noinside_)
	local total = total_ or false
	local noinside = noinside_ or false
	
	local check = unitid
	
	if (unitid == 2) then
		check = 200 + x_ + y_ * roomsizex
	end
	
	if (deleted[check] == nil) then
		local unit = {}
		local x,y,dir = 0,0,4
		local unitname = ""
		local insidename = ""
		
		if (unitid ~= 2) then
			unit = mmf.newObject(unitid)
			x,y,dir = unit.values[XPOS],unit.values[YPOS],unit.values[DIR]
			unitname = unit.strings[UNITNAME]
			insidename = getname(unit)
		else
			x,y = x_,y_
			unitname = "empty"
			insidename = "empty"
		end
		
		--x = math.floor(x)
		--y = math.floor(y)
		
		if (total == false) and inbounds(x,y,1) and (noinside == false) then
			local leveldata = {}
			
			if (unitid == 2) then
				dir = emptydir(x,y)
			else
				leveldata = {unit.strings[U_LEVELFILE],unit.strings[U_LEVELNAME],unit.flags[MAPLEVEL],unit.values[VISUALLEVEL],unit.values[VISUALSTYLE],unit.values[COMPLETED],unit.strings[COLOUR],unit.strings[CLEARCOLOUR]}
			end
			
			inside(insidename,x,y,dir,unitid,leveldata)
		end
		
		if (unitid ~= 2) then
			if (spritedata.values[CAMTARGET] == unit.values[ID]) then
				changevisiontarget(unit.fixed)
			end
			
			addundo({"remove",unitname,x,y,dir,unit.values[ID],unit.values[ID],unit.strings[U_LEVELFILE],unit.strings[U_LEVELNAME],unit.values[VISUALLEVEL],unit.values[COMPLETED],unit.values[VISUALSTYLE],unit.flags[MAPLEVEL],unit.strings[COLOUR],unit.strings[CLEARCOLOUR],unit.followed,unit.back_init,unit.originalname,unit.strings[UNITSIGNTEXT]},unitid)
			unit = {}
			delunit(unitid)
			MF_remove(unitid)
			
			--MF_alert("Removed " .. tostring(unitid))
			
			if inbounds(x,y,1) then
				dynamicat(x,y)
			end
		end
		
		deleted[check] = 1
	else
		MF_alert("already deleted")
	end
end

function handleinside(unitid,x_,y_)
	local unit = {}
	local x,y,dir = 0,0,4
	local unitname = ""
	local insidename = ""
	local leveldata = {}
	
	if (unitid ~= 2) then
		unit = mmf.newObject(unitid)
		x,y,dir = unit.values[XPOS],unit.values[YPOS],unit.values[DIR]
		unitname = unit.strings[UNITNAME]
		insidename = getname(unit)
	else
		x,y = x_,y_
		unitname = "empty"
		insidename = "empty"
	end
	
	--x = math.floor(x)
	--y = math.floor(y)
	
	if inbounds(x,y,1) then
		if (unitid == 2) then
			dir = emptydir(x,y)
		else
			leveldata = {unit.strings[U_LEVELFILE],unit.strings[U_LEVELNAME],unit.flags[MAPLEVEL],unit.values[VISUALLEVEL],unit.values[VISUALSTYLE],unit.values[COMPLETED],unit.strings[COLOUR],unit.strings[CLEARCOLOUR]}
		end
		
		inside(insidename,x,y,dir,unitid,leveldata)
	end
end

function block(small_)
	local delthese = {}
	local doned = {}
	local unitsnow = #units
	local removalsound = 1
	local removalshort = ""
	
	local small = small_ or false
	
	local doremovalsound = false
	
	if (small == false) then
		if (generaldata2.values[ENDINGGOING] == 0) then
			local isdone = getunitswitheffect("done",false,delthese)
			
			for id,unit in ipairs(isdone) do
				table.insert(doned, unit)
			end
			
			if (#doned > 0) then
				setsoundname("turn",10)
			end
			
			for i,unit in ipairs(doned) do
				updateundo = true
				
				local ufloat = unit.values[FLOAT]
				local ded = unit.flags[DEAD]
				
				unit.values[FLOAT] = 2
				unit.values[EFFECTCOUNT] = math.random(-10,10)
				unit.values[POSITIONING] = 7
				unit.flags[DEAD] = true
				
				local x,y = unit.values[XPOS],unit.values[YPOS]
				
				if (spritedata.values[VISION] == 1) and (unit.values[ID] == spritedata.values[CAMTARGET]) then
					updatevisiontargets()
				end
				
				if (ufloat ~= 2) and (ded == false) then
					addundo({"done",unit.strings[UNITNAME],unit.values[XPOS],unit.values[YPOS],unit.values[DIR],unit.values[ID],unit.fixed,ufloat,unit.originalname})
				end
				
				delunit(unit.fixed)
				dynamicat(x,y)
			end
		end
		
		local ismore = getunitswitheffect("more",false,delthese)
		
		for id,unit in ipairs(ismore) do
			local x,y = unit.values[XPOS],unit.values[YPOS]
			local name = unit.strings[UNITNAME]
			local doblocks = {}
			
			for i=1,4 do
				local drs = ndirs[i]
				ox = drs[1]
				oy = drs[2]
				
				local valid = true
				local obs = findobstacle(x+ox,y+oy)
				local tileid = (x+ox) + (y+oy) * roomsizex
				
				if (#obs > 0) then
					for a,b in ipairs(obs) do
						if (b == -1) then
							valid = false
						elseif (b ~= 0) and (b ~= -1) then
							local bunit = mmf.newObject(b)
							local obsname = bunit.strings[UNITNAME]
							
							local obsstop = hasfeature(obsname,"is","stop",b,x+ox,y+oy)
							local obspush = hasfeature(obsname,"is","push",b,x+ox,y+oy)
							local obspull = hasfeature(obsname,"is","pull",b,x+ox,y+oy)
							
							if (obsstop ~= nil) or (obspush ~= nil) or (obspull ~= nil) or (obsname == name) then
								valid = false
								break
							end
						end
					end
				else
					local obsstop = hasfeature("empty","is","stop",2,x+ox,y+oy)
					local obspush = hasfeature("empty","is","push",2,x+ox,y+oy)
					local obspull = hasfeature("empty","is","pull",2,x+ox,y+oy)
					
					if (obsstop ~= nil) or (obspush ~= nil) or (obspull ~= nil) then
						valid = false
					end
				end
				
				if valid then
					local newunit = copy(unit.fixed,x+ox,y+oy)
				end
			end
		end
	end
	
	local isplay = getunitswithverb("play",delthese)
	
	for id,ugroup in ipairs(isplay) do
		local sound_freq = ugroup[1]
		local sound_units = ugroup[2]
		local sound_name = ugroup[3]
		
		if (#sound_units > 0) then
			local ptunes = play_data.tunes
			local pfreqs = play_data.freqs
			
			local tune = "beep"
			local freq = pfreqs[sound_freq] or 24000
			
			if (ptunes[sound_name] ~= nil) then
				tune = ptunes[sound_name]
			end
			
			-- MF_alert(sound_name .. " played at " .. tostring(freq) .. " (" .. sound_freq .. ")")
			
			MF_playsound_freq(tune,freq)
			setsoundname("turn",11,nil)
			
			if (sound_name ~= "empty") then
				for a,unit in ipairs(sound_units) do
					local x,y = unit.values[XPOS],unit.values[YPOS]
					
					MF_particles("music",unit.values[XPOS],unit.values[YPOS],1,0,3,3,1)
				end
			end
		end
	end
	
	if (generaldata.strings[WORLD] == "museum") then
		local ishold = getunitswitheffect("hold",false,delthese)
		local holders = {}
		
		for id,unit in ipairs(ishold) do
			local x,y = unit.values[XPOS],unit.values[YPOS]
			local tileid = x + y * roomsizex
			holders[unit.values[ID]] = 1
			
			if (unitmap[tileid] ~= nil) then
				local water = findallhere(x,y)
				
				if (#water > 0) then
					for a,b in ipairs(water) do
						if floating(b,unit.fixed,x,y) then
							if (b ~= unit.fixed) then
								local bunit = mmf.newObject(b)
								addundo({"holder",bunit.values[ID],bunit.holder,unit.values[ID],},unitid)
								bunit.holder = unit.values[ID]
							end
						end
					end
				end
			end
		end
		
		for i,unit in ipairs(units) do
			if (unit.holder ~= nil) and (unit.holder ~= 0) then
				if (holders[unit.holder] ~= nil) then
					local unitid = getunitid(unit.holder)
					local bunit = mmf.newObject(unitid)
					local x,y = bunit.values[XPOS],bunit.values[YPOS]
					
					update(unit.fixed,x,y,unit.values[DIR])
				else
					addundo({"holder",unit.values[ID],unit.holder,0,},unitid)
					unit.holder = 0
				end
			else
				unit.holder = 0
			end
		end
	end
	
	local issink = getunitswitheffect("sink",false,delthese)
	
	for id,unit in ipairs(issink) do
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local tileid = x + y * roomsizex
		
		if (unitmap[tileid] ~= nil) then
			local water = findintersect(x,y)
			local sunk = false
			
			if (#water > 0) then
				for a,b in ipairs(water) do
					if floating(b,unit.fixed,x,y) then
						if (b ~= unit.fixed) then
							local dosink = true
							
							for c,d in ipairs(delthese) do
								if (d == unit.fixed) or (d == b) then
									--dosink = false
								end
							end
							
							local safe1 = issafe(b)
							local safe2 = issafe(unit.fixed)
							
							if safe1 and safe2 then
								dosink = false
							end
							
							if dosink then
								generaldata.values[SHAKE] = 3
								
								if (safe1 == false) then
									table.insert(delthese, b)
								end
								
								local pmult,sound = checkeffecthistory("sink")
								removalshort = sound
								removalsound = 3
								local c1,c2 = getcolour(unit.fixed)
								MF_particles("destroy",x,y,15 * pmult,c1,c2,1,1)
								
								if (b ~= unit.fixed) and (safe2 == false) then
									sunk = true
								end
							end
						end
					end
				end
			end
			
			if sunk then
				table.insert(delthese, unit.fixed)
			end
		end
	end
	
	delthese,doremovalsound = handledels(delthese,doremovalsound)
	
	local isboom = getunitswitheffect("boom",false,delthese)
	
	for id,unit in ipairs(isboom) do
		local ux,uy = unit.values[XPOS],unit.values[YPOS]
		local sunk = false
		local doeffect = true
		
		if (issafe(unit.fixed) == false) then
			sunk = true
		else
			doremovalsound = true
		end
		
		local name = unit.strings[UNITNAME]
		local count = hasfeature_count(name,"is","boom",unit.fixed,ux,uy)
		local dim = math.min(count - 1, math.max(roomsizex, roomsizey))
		
		local locs = {}
		if (dim <= 0) then
			table.insert(locs, {0,0})
		else
			for g=-dim,dim do
				for h=-dim,dim do
					table.insert(locs, {g,h})
				end
			end
		end
		
		for a,b in ipairs(locs) do
			local g = b[1]
			local h = b[2]
			local x = ux + g
			local y = uy + h
			local tileid = x + y * roomsizex
			
			if (unitmap[tileid] ~= nil) and inbounds(x,y,1) then
				local water = findintersect(x,y)
				
				if (#water > 0) then
					for e,f in ipairs(water) do
						if floating(f,unit.fixed,x,y) then
							if (f ~= unit.fixed) then
								local doboom = true
								
								for c,d in ipairs(delthese) do
									if (d == f) then
										doboom = false
									elseif (d == unit.fixed) then
										sunk = false
									end
								end
								
								if doboom and (issafe(f) == false) then
									table.insert(delthese, f)
									MF_particles("smoke",x,y,4,0,2,1,1)
								end
							end
						end
					end
				end
			end
		end
		
		if doeffect then
			generaldata.values[SHAKE] = 6
			local pmult,sound = checkeffecthistory("boom")
			removalshort = sound
			removalsound = 1
			local c1,c2 = getcolour(unit.fixed)
			MF_particles("smoke",ux,uy,15 * pmult,c1,c2,1,1)
		end
		
		if sunk then
			table.insert(delthese, unit.fixed)
		end
	end
	
	delthese,doremovalsound = handledels(delthese,doremovalsound)
	
	local isweak = getunitswitheffect("weak",false,delthese)
	
	for id,unit in ipairs(isweak) do
		if (issafe(unit.fixed) == false) and (unit.new == false) then
			local x,y = unit.values[XPOS],unit.values[YPOS]
			local stuff = findintersect(x,y)
			
			if (#stuff > 0) then
				for i,v in ipairs(stuff) do
					if floating(v,unit.fixed,x,y) then
						local vunit = mmf.newObject(v)
						local thistype = vunit.strings[UNITTYPE]
						if (v ~= unit.fixed) then
							local pmult,sound = checkeffecthistory("weak")
							MF_particles("destroy",x,y,5 * pmult,0,3,1,1)
							removalshort = sound
							removalsound = 1
							generaldata.values[SHAKE] = 4
							table.insert(delthese, unit.fixed)
							break
						end
					end
				end
			end
		end
	end
	
	delthese,doremovalsound = handledels(delthese,doremovalsound,true)
	
	local ismelt = getunitswitheffect("melt",false,delthese)
	
	for id,unit in ipairs(ismelt) do
		local hot = findfeature(nil,"is","hot")
		local x,y = unit.values[XPOS],unit.values[YPOS]
		
		if (hot ~= nil) then
			for a,b in ipairs(hot) do
				local lava = findtype(b,x,y,0)
			
				if (#lava > 0) and (issafe(unit.fixed) == false) then
					for c,d in ipairs(lava) do
						if floating(d,unit.fixed,x,y) then
							local pmult,sound = checkeffecthistory("hot")
							MF_particles("smoke",x,y,5 * pmult,0,1,1,1)
							generaldata.values[SHAKE] = 5
							removalshort = sound
							removalsound = 9
							table.insert(delthese, unit.fixed)
							break
						end
					end
				end
			end
		end
	end
	
	delthese,doremovalsound = handledels(delthese,doremovalsound,true)
	
	local isyou = getunitswitheffect("you",false,delthese)
	local isyou2 = getunitswitheffect("you2",false,delthese)
	local isyou3 = getunitswitheffect("3d",false,delthese)
	
	for i,v in ipairs(isyou2) do
		table.insert(isyou, v)
	end
	
	for i,v in ipairs(isyou3) do
		table.insert(isyou, v)
	end
	
	for id,unit in ipairs(isyou) do
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local defeat = findfeature(nil,"is","defeat")
		
		if (defeat ~= nil) then
			for a,b in ipairs(defeat) do
				if (b[1] ~= "empty") then
					local skull = findtype(b,x,y,0)
					
					if (#skull > 0) and (issafe(unit.fixed) == false) then
						for c,d in ipairs(skull) do
							local doit = false
							
							if (d ~= unit.fixed) then
								if floating(d,unit.fixed,x,y) then
									local kunit = mmf.newObject(d)
									local kname = kunit.strings[UNITNAME]
									
									local weakskull = hasfeature(kname,"is","weak",d)
									
									if (weakskull == nil) or ((weakskull ~= nil) and issafe(d)) then
										doit = true
									end
								end
							else
								doit = true
							end
							
							if doit then
								local pmult,sound = checkeffecthistory("defeat")
								MF_particles("destroy",x,y,5 * pmult,0,3,1,1)
								generaldata.values[SHAKE] = 5
								removalshort = sound
								removalsound = 1
								table.insert(delthese, unit.fixed)
							end
						end
					end
				end
			end
		end
	end
	
	delthese,doremovalsound = handledels(delthese,doremovalsound)
	
	local isshut = getunitswitheffect("shut",false,delthese)
	
	for id,unit in ipairs(isshut) do
		local open = findfeature(nil,"is","open")
		local x,y = unit.values[XPOS],unit.values[YPOS]
		
		if (open ~= nil) then
			for i,v in ipairs(open) do
				local key = findtype(v,x,y,0)
				
				if (#key > 0) then
					local doparts = false
					for a,b in ipairs(key) do
						if (b ~= 0) and floating(b,unit.fixed,x,y) then
							if (issafe(unit.fixed) == false) then
								generaldata.values[SHAKE] = 8
								table.insert(delthese, unit.fixed)
								doparts = true
								online = false
							end
							
							if (b ~= unit.fixed) and (issafe(b) == false) then
								table.insert(delthese, b)
								doparts = true
							end
							
							if doparts then
								local pmult,sound = checkeffecthistory("unlock")
								setsoundname("turn",7,sound)
								MF_particles("unlock",x,y,15 * pmult,2,4,1,1)
							end
							
							break
						end
					end
				end
			end
		end
	end
	
	delthese,doremovalsound = handledels(delthese,doremovalsound)
	
	local iseat = getunitswithverb("eat",delthese)
	local iseaten = {}
	
	for id,ugroup in ipairs(iseat) do
		local v = ugroup[1]
		
		if (ugroup[3] ~= "empty") then
			for a,unit in ipairs(ugroup[2]) do
				local x,y = unit.values[XPOS],unit.values[YPOS]
				local things = findtype({v,nil},x,y,unit.fixed)
				
				if (#things > 0) then
					for a,b in ipairs(things) do
						if (issafe(b) == false) and floating(b,unit.fixed,x,y) and (b ~= unit.fixed) and (iseaten[b] == nil) then
							generaldata.values[SHAKE] = 4
							table.insert(delthese, b)
							
							iseaten[b] = 1
							
							local pmult,sound = checkeffecthistory("eat")
							MF_particles("eat",x,y,5 * pmult,0,3,1,1)
							removalshort = sound
							removalsound = 1
						end
					end
				end
			end
		end
	end
	
	delthese,doremovalsound = handledels(delthese,doremovalsound,true)
	
	if (small == false) then
		local ismake = getunitswithverb("make",delthese)
		
		for id,ugroup in ipairs(ismake) do
			local v = ugroup[1]
			
			for a,unit in ipairs(ugroup[2]) do
				local x,y,dir,name = 0,0,4,""
				
				local leveldata = {}
				
				if (ugroup[3] ~= "empty") then
					x,y,dir = unit.values[XPOS],unit.values[YPOS],unit.values[DIR]
					name = getname(unit)
					leveldata = {unit.strings[U_LEVELFILE],unit.strings[U_LEVELNAME],unit.flags[MAPLEVEL],unit.values[VISUALLEVEL],unit.values[VISUALSTYLE],unit.values[COMPLETED],unit.strings[COLOUR],unit.strings[CLEARCOLOUR]}
				else
					x = math.floor(unit % roomsizex)
					y = math.floor(unit / roomsizex)
					name = "empty"
					dir = emptydir(x,y)
				end
				
				if (dir == 4) then
					dir = fixedrandom(0,3)
				end
				
				local exists = false
				
				if (v ~= "text") and (v ~= "all") then
					for b,mat in pairs(objectlist) do
						if (b == v) then
							exists = true
						end
					end
				else
					exists = true
				end
				
				if exists then
					local domake = true
					
					if (name ~= "empty") then
						local thingshere = findallhere(x,y)
						
						if (#thingshere > 0) then
							for a,b in ipairs(thingshere) do
								local thing = mmf.newObject(b)
								local thingname = thing.strings[UNITNAME]
								
								if (thing.flags[CONVERTED] == false) and ((thingname == v) or ((thing.strings[UNITTYPE] == "text") and (v == "text"))) then
									domake = false
								end
							end
						end
					end
					
					if domake then
						if (findnoun(v,nlist.short) == false) then
							create(v,x,y,dir,x,y,nil,nil,leveldata)
						elseif (v == "text") then
							if (name ~= "text") and (name ~= "all") then
								create("text_" .. name,x,y,dir,x,y,nil,nil,leveldata)
								updatecode = 1
							end
						elseif (string.sub(v, 1, 5) == "group") then
							--[[
							local mem = findgroup(v)
							
							for c,d in ipairs(mem) do
								local thishere = findtype({d},x,y,nil,true)
								
								if (#thishere == 0) then
									create(d,x,y,dir,x,y,nil,nil,leveldata)
								end
							end
							]]--
						end
					end
				end
			end
		end
	end
	
	delthese,doremovalsound = handledels(delthese,doremovalsound)
	
	isyou = getunitswitheffect("you",false,delthese)
	isyou2 = getunitswitheffect("you2",false,delthese)
	isyou3 = getunitswitheffect("3d",false,delthese)
	
	for i,v in ipairs(isyou2) do
		table.insert(isyou, v)
	end
	
	for i,v in ipairs(isyou3) do
		table.insert(isyou, v)
	end
	
	for id,unit in ipairs(isyou) do
		if (unit.flags[DEAD] == false) and (delthese[unit.fixed] == nil) then
			local x,y = unit.values[XPOS],unit.values[YPOS]
			
			if (small == false) then
				local bonus = findfeature(nil,"is","bonus")
				
				if (bonus ~= nil) then
					for a,b in ipairs(bonus) do
						if (b[1] ~= "empty") then
							local flag = findtype(b,x,y,0)
							
							if (#flag > 0) then
								for c,d in ipairs(flag) do
									if floating(d,unit.fixed,x,y) then
										local pmult,sound = checkeffecthistory("bonus")
										MF_particles("bonus",x,y,10 * pmult,4,1,1,1)
										removalshort = sound
										removalsound = 2
										MF_playsound("bonus")
										MF_bonus(1)
										addundo({"bonus",1})
										
										if (issafe(d,x,y) == false) then
											generaldata.values[SHAKE] = 5
											table.insert(delthese, d)
										end
									end
								end
							end
						end
					end
				end
				
				local ending = findfeature(nil,"is","end")
				
				if (ending ~= nil) then
					for a,b in ipairs(ending) do
						if (b[1] ~= "empty") then
							local flag = findtype(b,x,y,0)
							
							if (#flag > 0) then
								for c,d in ipairs(flag) do
									if floating(d,unit.fixed,x,y) and (generaldata.values[MODE] == 0) then
										if (generaldata.strings[WORLD] == generaldata.strings[BASEWORLD]) then
											MF_particles("unlock",x,y,10,1,4,1,1)
											MF_end(unit.fixed,d)
											break
										elseif (editor.values[INEDITOR] ~= 0) then
											local pmult = checkeffecthistory("win")
									
											MF_particles("win",x,y,10 * pmult,2,4,1,1)
											--donutz override
											--MF_end_single()
											MF_win()
											break
										else
											local pmult = checkeffecthistory("win")
											
											local mods_run = do_mod_hook("levelpack_end", {})
											
											if (mods_run == false) then
												MF_particles("win",x,y,10 * pmult,2,4,1,1)
												MF_end_single()
												MF_win()
												MF_credits(1)
											end
											break
										end
									end
								end
							end
						end
					end
				end
			end
			
			local win = findfeature(nil,"is","win")
			
			if (win ~= nil) then
				for a,b in ipairs(win) do
					if (b[1] ~= "empty") then
						local flag = findtype(b,x,y,0)
						if (#flag > 0) then
							for c,d in ipairs(flag) do
								if floating(d,unit.fixed,x,y) and (hasfeature(b[1],"is","done",d,x,y) == nil) and (hasfeature(b[1],"is","end",d,x,y) == nil) then
									local pmult = checkeffecthistory("win")
									
									MF_particles("win",x,y,10 * pmult,2,4,1,1)
									MF_win()
									break
								end
							end
						end
					end
				end
			end
		end
	end
	
	delthese,doremovalsound = handledels(delthese,doremovalsound)
	
	for i,unit in ipairs(units) do
		if (inbounds(unit.values[XPOS],unit.values[YPOS],2) == false) then
			--MF_alert("DELETED!!!")
			table.insert(delthese, unit.fixed)
		end
	end
	
	delthese,doremovalsound = handledels(delthese,doremovalsound)
	
	if (small == false) then
		local iscrash = getunitswitheffect("crash",false,delthese)
		
		if (#iscrash > 0) then
			HACK_INFINITY = 200
			destroylevel("infinity")
			return
		end
	end
	
	if doremovalsound then
		setsoundname("removal",removalsound,removalshort)
	end
end

function moveblock(onlystartblock_)
	local onlystartblock = onlystartblock_ or false
	
	local isshift,istele = {},{}
	local isfollow = findfeature(nil,"follow",nil,true)
	
	if (onlystartblock == false) then
		isshift = findallfeature(nil,"is","shift",true)
		istele = findallfeature(nil,"is","tele",true)
	end
	
	local doned = {}
	
	if (isfollow ~= nil) then
		for h,j in ipairs(isfollow) do
			local allfollows = findall(j)
			
			if (#allfollows > 0) then
				for k,l in ipairs(allfollows) do
					if (issleep(l) == false) then
						local unit = mmf.newObject(l)
						local x,y,name,dir = unit.values[XPOS],unit.values[YPOS],unit.strings[UNITNAME],unit.values[DIR]
						local unitrules = {}
						local followedfound = false
						
						if (unit.strings[UNITTYPE] == "text") then
							name = "text"
						end
						
						if (featureindex[name] ~= nil) then					
							for a,b in ipairs(featureindex[name]) do
								local baserule = b[1]
								local conds = b[2]
								
								local verb = baserule[2]
								
								if (verb == "follow") then
									if testcond(conds,l) then
										table.insert(unitrules, b)
									end
								end
							end
						end
						
						local follow = xthis(unitrules,name,"follow")
						
						if (#follow > 0) and (unit.flags[DEAD] == false) then
							local distance = 9999
							local targetdir = -1
							local stophere = false
							local highesttarget = false
							local counterclockwise = false
							
							local priorityfollow = -1
							local priorityfollowdir = -1
							
							local highpriorityfollow = -1
							local highpriorityfollowdir = -1
							
							for i,v in ipairs(follow) do
								local these = findall({v})
								
								if (#these > 0) and (stophere == false) then
									for a,b in ipairs(these) do
										if (b ~= unit.fixed) and (stophere == false) then
											local funit = mmf.newObject(b)
											
											local fx,fy = funit.values[XPOS],funit.values[YPOS]
											
											local xdir = fx-x
											local ydir = fy-y
											local dist = math.abs(xdir) + math.abs(ydir)
											local fdir = -1
											
											if (math.abs(xdir) <= math.abs(ydir)) then
												if (ydir >= 0) then
													fdir = 3
												else
													fdir = 1
												end
											else
												if (xdir > 0) then
													fdir = 0
												else
													fdir = 2
												end
											end
											
											if (dist <= distance) and (dist > 0) then
												distance = dist
												targetdir = fdir
												
												--MF_alert(name .. ": suggested dir " .. tostring(targetdir))
												
												if (dist == 1) then
													if (unit.followed ~= funit.values[ID]) then
														local ndrs = ndirs[dir + 1]
														local ox,oy = ndrs[1],ndrs[2]
														
														priorityfollow = funit.values[ID]
														priorityfollowdir = targetdir
														
														if (x + ox == fx) and (y + oy == fy) then
															highpriorityfollow = funit.values[ID]
															highpriorityfollowdir = targetdir
															highesttarget = true
															--MF_alert(tostring(unit.fixed) .. " moves forward: " .. tostring(dir) .. ", " .. tostring(targetdir))
														elseif (highesttarget == false) then
															local turnl = (dir + 1 + 4) % 4
															local ndrsl = ndirs[turnl + 1]
															local oxl,oyl = ndrsl[1],ndrsl[2]
															
															if (x + oxl == fx) and (y + oyl == fy) then
																highpriorityfollow = funit.values[ID]
																highpriorityfollowdir = targetdir
																counterclockwise = true
																--MF_alert(tostring(unit.fixed) .. " turns left: " .. tostring(dir) .. ", " .. tostring(turnl) .. ", " .. tostring(targetdir))
															elseif (counterclockwise == false) then
																local turnr = (dir - 1 + 4) % 4
																local ndrsr = ndirs[turnr + 1]
																local oxr,oyr = ndrsr[1],ndrsr[2]
																
																if (x + oxr == fx) and (y + oyr == fy) then
																	highpriorityfollow = funit.values[ID]
																	highpriorityfollowdir = targetdir
																	--MF_alert(tostring(unit.fixed) .. " turns right: " .. tostring(dir) .. ", " .. tostring(turnr) .. ", " .. tostring(targetdir))
																end
															end
														end
													else
														followedfound = true
														stophere = true
														break
													end
												end
											end
										end
									end
									
									if stophere then
										break
									end
								end
								
								if stophere then
									break
								end
							end
							
							if (followedfound == false) then
								if (highpriorityfollow > -1) then
									if (onlystartblock == false) then
										addundo({"followed",unit.values[ID],unit.followed,highpriorityfollow,unit.strings[UNITNAME]},unit.fixed)
									end
									unit.followed = highpriorityfollow
									targetdir = highpriorityfollowdir
									stophere = true
									followedfound = true
								elseif (priorityfollow > -1) then
									if (onlystartblock == false) then
										addundo({"followed",unit.values[ID],unit.followed,priorityfollow,unit.strings[UNITNAME]},unit.fixed)
									end
									unit.followed = priorityfollow
									targetdir = priorityfollowdir
									stophere = true
									followedfound = true
								elseif (unit.followed > -1) then
									if (onlystartblock == false) then
										addundo({"followed",unit.values[ID],unit.followed,0,unit.strings[UNITNAME]},unit.fixed)
									end
									unit.followed = -1
								end
							end
			
							if (targetdir >= 0) then
								--MF_alert(unit.strings[UNITNAME] .. " faces to " .. tostring(targetdir))
								updatedir(unit.fixed,targetdir,onlystartblock)
							end
						end
					end
				end
			end
		end
	end
	
	if (onlystartblock == false) then
		local isback = findallfeature(nil,"is","back",true)
		
		for i,unitid in ipairs(isback) do
			local unit = mmf.newObject(unitid)
			
			local undooffset = #undobuffer - unit.back_init
			
			local undotargetid = undooffset * 2 + 1
			
			if (undotargetid <= #undobuffer) and (unit.back_init > 0) and (unit.flags[DEAD] == false) then
				local currentundo = undobuffer[undotargetid]
				
				particles("wonder",unit.values[XPOS],unit.values[YPOS],1,{3,0})
				
				updateundo = true
				
				if (currentundo ~= nil) then
					for a,line in ipairs(currentundo) do
						local style = line[1]
						
						if (style == "update") and (line[9] == unit.values[ID]) then
							local uid = line[9]
							
							if (paradox[uid] == nil) then
								local ux,uy = unit.values[XPOS],unit.values[YPOS]
								local oldx,oldy = line[6],line[7]
								local x,y,dir = line[3],line[4],line[5]
								
								local ox = x - oldx
								local oy = y - oldy
								
								--[[
								Enable this to make the Back effect relative to current position
								]]
								--x = ux + ox
								--y = uy + oy
								--[[
								]]--
								
								--MF_alert(unit.strings[UNITNAME] .. " is being updated from " .. tostring(ux) .. ", " .. tostring(uy) .. ", offset " .. tostring(ox) .. ", " .. tostring(oy))
								
								if (ox ~= 0) or (oy ~= 0) then
									addaction(unitid,{"update",x,y,dir})
								else
									addaction(unitid,{"updatedir",dir})
								end
								updateundo = true
								
								if (objectdata[unitid] == nil) then
									objectdata[unitid] = {}
								end
								
								local odata = objectdata[unitid]
								
								odata.tele = 1
							else
								particles("hot",line[3],line[4],1,{1, 1})
								updateundo = true
							end
						elseif (style == "create") and (line[3] == unit.values[ID]) then
							local uid = line[4]
							
							--MF_alert(unit.strings[UNITNAME] .. " back: " .. tostring(uid) .. ", " .. tostring(line[3]))
							
							if (paradox[uid] == nil) then
								local name = unit.strings[UNITNAME]
								
								local delname = {}
								
								for b,bline in ipairs(currentundo) do
									--MF_alert(" -- " .. bline[1] .. ", " .. tostring(bline[6]))
									
									if (bline[1] == "remove") and (bline[6] == uid) then
										local x,y,dir,levelfile,levelname,vislevel,complete,visstyle,maplevel,colour,clearcolour,followed,back_init = bline[3],bline[4],bline[5],bline[8],bline[9],bline[10],bline[11],bline[12],bline[13],bline[14],bline[15],bline[16],bline[17]
										
										local newname = bline[2]
										
										local newunitname = ""
										local newunitid = 0
										
										local ux,uy = unit.values[XPOS],unit.values[YPOS]
										
										newunitname = unitreference[newname]
										newunitid = MF_emptycreate(newunitname,ux,uy)
										
										local newunit = mmf.newObject(newunitid)
										newunit.values[ONLINE] = 1
										newunit.values[XPOS] = ux
										newunit.values[YPOS] = uy
										newunit.values[DIR] = dir
										newunit.values[ID] = bline[6]
										newunit.flags[9] = true
										
										newunit.strings[U_LEVELFILE] = levelfile
										newunit.strings[U_LEVELNAME] = levelname
										newunit.flags[MAPLEVEL] = maplevel
										newunit.values[VISUALLEVEL] = vislevel
										newunit.values[VISUALSTYLE] = visstyle
										newunit.values[COMPLETED] = complete
										
										newunit.strings[COLOUR] = colour
										newunit.strings[CLEARCOLOUR] = clearcolour
										
										if (newunit.className == "level") then
											MF_setcolourfromstring(newunitid,colour)
										end
										
										addunit(newunitid,true)
										addunitmap(newunitid,x,y,newunit.strings[UNITNAME])
										dynamic(unitid)
										
										newunit.followed = followed
										newunit.back_init = back_init
										
										if (newunit.strings[UNITTYPE] == "text") then
											updatecode = 1
										end
										
										local undowordunits = currentundo.wordunits
										local undowordrelatedunits = currentundo.wordrelatedunits
										
										if (#undowordunits > 0) then
											for a,b in ipairs(undowordunits) do
												if (b == bline[6]) then
													updatecode = 1
												end
											end
										end
										
										if (#undowordrelatedunits > 0) then
											for a,b in ipairs(undowordrelatedunits) do
												if (b == bline[6]) then
													updatecode = 1
												end
											end
										end
										
										table.insert(delname, {newunit.strings[UNITNAME], bline[6], newunit.values[XPOS], newunit.values[YPOS], newunit.values[DIR]})
									end
								end
								
								addundo({"remove",unit.strings[UNITNAME],unit.values[XPOS],unit.values[YPOS],unit.values[DIR],unit.values[ID],unit.values[ID],unit.strings[U_LEVELFILE],unit.strings[U_LEVELNAME],unit.values[VISUALLEVEL],unit.values[COMPLETED],unit.values[VISUALSTYLE],unit.flags[MAPLEVEL],unit.strings[COLOUR],unit.strings[CLEARCOLOUR],unit.followed,unit.back_init,unit.originalname,unit.strings[UNITSIGNTEXT]})
								
								for a,b in ipairs(delname) do
									MF_alert("added undo for " .. b[1] .. " with ID " .. tostring(b[2]))
									addundo({"create",b[1],b[2],b[2],"back",b[3],b[4],b[5]})
								end
								
								delunit(unitid)
								dynamic(unitid)
								MF_specialremove(unitid,2)
							end
						end
					end
				end
			end
		end
		
		doupdate()
		
		for i,unitid in ipairs(istele) do
			if (isgone(unitid) == false) then
				local unit = mmf.newObject(unitid)
				-- METATEXT
				local name = getname(unit)
				local x,y = unit.values[XPOS],unit.values[YPOS]
			
				local targets = findintersect(x,y)
				local telethis = false
				local telethisx,telethisy = 0,0
				
				if (#targets > 0) then
					for i,v in ipairs(targets) do
						local vunit = mmf.newObject(v)
						local thistype = vunit.strings[UNITTYPE]
						local vname = vunit.strings[UNITNAME]
						
						local targetvalid = isgone(v)
						local targetstill = hasfeature(vname,"is","still",v,x,y)
						-- Luultavasti ei väliä onko kohde tuhoutumassa?
						
						if (targetstill == nil) and floating(v,unitid,x,y) and (vunit.flags[DEAD] == false) then
							local targetname = getname(vunit)
							if (objectdata[v] == nil) then
								objectdata[v] = {}
							end
							
							local odata = objectdata[v]
							
							if (odata.tele == nil) then
								if (targetname ~= name) and (v ~= unitid) then
									local teles = istele
									
									if (#teles > 1) then
										local teletargets = {}
										local targettele = 0
										
										for a,b in ipairs(teles) do
											local tele = mmf.newObject(b)
											local telename = getname(tele)
											
											if (b ~= unitid) and (telename == name) and (tele.flags[DEAD] == false) then
												table.insert(teletargets, b)
											end
										end
										
										if (#teletargets > 0) then
											local randomtarget = fixedrandom(1, #teletargets)
											targettele = teletargets[randomtarget]
											local limit = 0
											
											while (targettele == unitid) and (limit < 10) do
												randomtarget = fixedrandom(1, #teletargets)
												targettele = teletargets[randomtarget]
												limit = limit + 1
											end
											
											odata.tele = 1
											
											local tele = mmf.newObject(targettele)
											local tx,ty = tele.values[XPOS],tele.values[YPOS]
											local vx,vy = vunit.values[XPOS],vunit.values[YPOS]
										
											update(v,tx+(vx-x),ty+(vy-y))
											
											local pmult,sound = checkeffecthistory("tele")
											
											MF_particles("glow",vx,vy,5 * pmult,1,4,1,1)
											MF_particles("glow",tx,ty,5 * pmult,1,4,1,1)
											setsoundname("turn",6,sound)
										end
									end
								end
							end
						end
					end
				end
			end
		end
		
		for a,unitid in ipairs(isshift) do
			if (unitid ~= 2) and (unitid ~= 1) then
				local unit = mmf.newObject(unitid)
				local x,y,dir = unit.values[XPOS],unit.values[YPOS],unit.values[DIR]
				
				local things = findallhere(x,y,unitid)
				
				if (#things > 0) and (isgone(unitid) == false) then
					for e,f in ipairs(things) do
						if floating(unitid,f,x,y) and (issleep(unitid,x,y) == false) then
							local newunit = mmf.newObject(f)
							local name = newunit.strings[UNITNAME]
							
							if (featureindex["reverse"] ~= nil) then
								local turndir = unit.values[DIR]
								turndir = reversecheck(newunit.fixed,unit.values[DIR],x,y)
							end
							
							if (newunit.flags[DEAD] == false) then
								addundo({"update",name,x,y,newunit.values[DIR],x,y,unit.values[DIR],newunit.values[ID]})
								newunit.values[DIR] = unit.values[DIR]
							end
						end
					end
				end
			end
		end
		
		doupdate()
	end
end

function fallblock()
	local checks = {}
	
	local isfall = findallfeature(nil,"is","fall",true)
	local isfall_r = findallfeature(nil,"is","fallright",true)
	local isfall_u = findallfeature(nil,"is","fallup",true)
	local isfall_l = findallfeature(nil,"is","fallleft",true)
	
	local flist = {}
	flist.down = {}
	flist.right = {}
	flist.up = {}
	flist.left = {}
	
	local fd,fr,fu,fl = flist.down,flist.right,flist.up,flist.left
	
	local fdl = #isfall
	local frl = #isfall_r
	local ful = #isfall_u
	local fll = #isfall_l
	
	if (featureindex["reverse"] ~= nil) then
		for a,unitid in ipairs(isfall) do
			if (a <= fdl) and (reversecheck(unitid,0) > 0) then
				table.insert(isfall_u, unitid)
				isfall[a] = -1
			end
		end
		
		for a,unitid in ipairs(isfall_r) do
			if (a <= frl) and (reversecheck(unitid,0) > 0) then
				table.insert(isfall_l, unitid)
				isfall_r[a] = -1
			end
		end
		
		for a,unitid in ipairs(isfall_u) do
			if (a <= ful) and (reversecheck(unitid,0) > 0) then
				table.insert(isfall, unitid)
				isfall_u[a] = -1
			end
		end
		
		for a,unitid in ipairs(isfall_l) do
			if (a <= fll) and (reversecheck(unitid,0) > 0) then
				table.insert(isfall_r, unitid)
				isfall_l[a] = -1
			end
		end
	end

	for a,unitid in ipairs(isfall) do
		if (unitid ~= -1) then
			table.insert(checks, {unitid, 3})
			
			if (fd[unitid] == nil) then
				fd[unitid] = 1
			else
				fd[unitid] = fd[unitid] + 1
			end
		end
	end
	
	for a,unitid in ipairs(isfall_r) do
		if (unitid ~= -1) then
			table.insert(checks, {unitid, 0})
			
			if (fr[unitid] == nil) then
				fr[unitid] = 1
			else
				fr[unitid] = fr[unitid] + 1
			end
		end
	end
	
	for a,unitid in ipairs(isfall_u) do
		if (unitid ~= -1) then
			table.insert(checks, {unitid, 1})
			
			if (fu[unitid] == nil) then
				fu[unitid] = 1
			else
				fu[unitid] = fu[unitid] + 1
			end
			
			if (fd[unitid] ~= nil) and (fd[unitid] > 0) and (fu[unitid] > 0) then
				fd[unitid] = fd[unitid] - 1
				fu[unitid] = fu[unitid] - 1
			end
		end
	end
	
	for a,unitid in ipairs(isfall_l) do
		if (unitid ~= -1) then
			table.insert(checks, {unitid, 2})
			
			if (fl[unitid] == nil) then
				fl[unitid] = 1
			else
				fl[unitid] = fl[unitid] + 1
			end
			
			if (fr[unitid] ~= nil) and (fr[unitid] > 0) and (fl[unitid] > 0) then
				fr[unitid] = fr[unitid] - 1
				fl[unitid] = fl[unitid] - 1
			end
		end
	end
	
	local done = false
	local objdatalist = {}
	
	local limiter = 0
	local limit = 6000
	
	while (done == false) and (limiter < limit) do
		local settled = true
		
		if (#checks > 0) then
			for a,data in pairs(checks) do
				local unitid = data[1]
				local falldir = data[2]
				
				if (objectdata[unitid] == nil) then
					objectdata[unitid] = {}
				end
				
				local unit = mmf.newObject(unitid)
				local x,y,dir = unit.values[XPOS],unit.values[YPOS],unit.values[DIR]
				local name = unit.strings[UNITNAME]
				
				local drs = ndirs[falldir + 1]
				local ox,oy = drs[1],drs[2]
				local onground = false
				
				local valid = false
				
				local flistnames = {"right", "up", "left", "down"}
				local flist_ = flist[flistnames[falldir + 1]]
				
				if (flist_[unitid] ~= nil) and (flist_[unitid] > 0) then
					valid = true
				end
				
				local odata = objectdata[unitid]
				if (odata.fallen ~= nil) and (odata.fallen ~= falldir) then
					valid = false
					onground = true
				end
				
				if (odata.fallen == nil) then
					table.insert(objdatalist, {unitid, falldir})
				end
				
				if unit.flags[DEAD] or cantmove(name,unitid,falldir,x,y) then
					valid = false
				end
				
				if valid then
					while (onground == false) and (limiter < limit) and inbounds(x+ox,y+oy) do
						local below,below_,specials = check(unitid,x,y,falldir,false,"fall")
						local deletethese = {}
						local firstcontact = nil
						
						local result = 0
						for c,d in pairs(below) do
							if (d ~= 0) then
								result = 1
								local theid = below_[c]
								if theid > 2 then
									local theunit = mmf.newObject(theid)
									local thex,they = theunit.values[XPOS],theunit.values[YPOS]

									--really inefficient method might fix later
									if firstcontact == nil then
										if oy ~= 0 then
											firstcontact = they - oy
										elseif ox ~= 0 then
											firstcontact = thex - ox
										end
									elseif oy == 1 and they - oy < firstcontact then
										firstcontact = they - oy
									elseif oy == -1 and they - oy > firstcontact then
										firstcontact = they - oy
									elseif ox == 1 and they - ox < firstcontact then
										firstcontact = they - ox
									elseif ox == -1 and they - ox > firstcontact then
										firstcontact = they - ox
									end
								end
							else
								if (below_[c] ~= 0) and (result ~= 1) then
									if (result ~= 0) then
										result = 2
									else
										for e,f in ipairs(specials) do
											if (f[1] == below_[c]) then
												result = 2
											end
											
											if (f[2] == "weak") then
												table.insert(deletethese, f[1])
											end
										end
									end
								end
							end
							--MF_alert(tostring(y) .. " -- " .. tostring(d) .. " (" .. tostring(below_[c]) .. ")")
						end
						
						--MF_alert(tostring(y) .. " -- result: " .. tostring(result))
						
						if (inbounds(x+ox,y+oy) == false) then
							result = 1
						end
						
						if (result ~= 1) then
							local gone = false
							
							if (result == 0) then
								update(unitid,x + ox,y + oy)
							elseif (result == 2) then
								gone = move(unitid,ox,oy,dir,specials,true,true,x,y)
							end
							
							-- Poista tästä kommenttimerkit jos haluat, että fall tsekkaa juttuja per pudottu tile
							if (gone == false) then
								x = x + ox
								y = y + oy
								settled = false
								
								for a,b in ipairs(deletethese) do
									delete(b,x,y)
						
									local pmult,sound = checkeffecthistory("weak")
									setsoundname("removal",1,sound)
									generaldata.values[SHAKE] = 3
									MF_particles("destroy",x,y,5 * pmult,0,3,1,1)
								end
								
								if unit.flags[DEAD] then
									onground = true
									settled = true
									table.remove(checks, a)
								else
									update(unitid,x,y)
									--[[
									local stillgoing = hasfeature(name,"is","fall",unitid,x,y)
									if (stillgoing == nil) then
										onground = true
										table.remove(checks, a)
									end
									]]--
								end
							else
								onground = true
							end
						else
							onground = true
							if firstcontact ~= nil then
								if ox ~= 0 then
									update(unitid,firstcontact,y)
								elseif oy ~= 0 then
									update(unitid,x,firstcontact)
								end
							end
						end
						
						limiter = limiter + 1
					end
				else
					onground = true
				end
			end
			
			if settled then
				done = true
			end
		else
			done = true
		end
	end
	
	if (limiter >= limit) then
		HACK_INFINITY = 200
		destroylevel("infinity")
		return
	end
	
	for i,v in ipairs(objdatalist) do
		local unitid = v[1]
		local falldir = v[2]
		
		if (objectdata[unitid] == nil) then
			objectdata[unitid] = {}
		end
		
		local odata = objectdata[unitid]
		
		if (odata.fallen == nil) then
			odata.fallen = falldir
		end
	end
end

function dynamictile(unitid,x,y,name,extra_)
	local ox,oy = 0,0
	local result = 0
	local exclude = 0
	local layer = map[0]
	
	local extra = {name,"edge","level"}
	
	if (extra_ ~= nil) then
		for a,b in ipairs(extra_) do
			table.insert(extra, b)
		end
	end
	
	local i_ = 4
	local sdirs = {}
	local sresult = true
	local sresult2 = false
	if (unitreference[name] ~= nil) and (specialtiling[unitreference[name]] ~= nil) and specialtiling[unitreference[name]] then
		i_ = 8
	end
	
	for i=1,i_ do
		local v = dirs_diagonals_[i]
		ox = v[1]
		oy = v[2]
		
		sdirs[i] = 0
		
		local tileid = (x+ox) + (y+oy) * roomsizex
		local maptile = 255
		local found = false
		
		if inbounds(x+ox,y+oy) then
			for c,d in ipairs(extra) do
				if intersectobj(d,x+ox,y+oy,{0,0},2) then
					if (d ~= "level") or (generaldata.strings[WORLD] == generaldata.strings[BASEWORLD]) then
						found = true
						break
					else
						if (unitid < 0) or (unitid > 2) then
							local unit = mmf.newObject(unitid)
							
							if (unit.values[COMPLETED] > 0) then
								found = true
								break
							end
						end
							
						local sect = findallhere(x+ox,y+oy)
						
						for e,f in ipairs(sect) do
							local funit = mmf.newObject(f)
							
							if (funit.strings[UNITNAME] == "level") and (funit.visible and (funit.values[COMPLETED] > 0)) then
								found = true
								break
							end
						end
					end
				end
			end
		end
		
		if (x+ox == 0) or (y+oy == 0) or (x+ox == roomsizex-1) or (y+oy == roomsizey-1) then
			maptile = 1
		end
		
		if found or (maptile ~= 255) then
			sdirs[i] = 1
			
			--MF_alert(tostring(i))
			
			if (i < 5) then
				result = result + 2 ^ (i - 1)
			else
				sresult = true
			end
		end
	end
	
	if sresult then
		result = handlespecialtiling(sdirs,result)
		
		if (result > 31) then
			sresult2 = true
			result = result % 32
		end
	end
	
	return result,sresult2
end

function dynamic(id,extra_)
	local unit = mmf.newObject(id)
	
	if (unit.values[TILING] == 1) then
		local x,y = unit.values[XPOS],unit.values[YPOS]
		local ox,oy = 0,0
		local name = unit.strings[UNITNAME]
		
		local extra = {name,"edge","level"}
	
		if (extra_ ~= nil) then
			for a,b in ipairs(extra_) do
				table.insert(extra, b)
			end
		end
		
		unit.direction,unit.flags[SPECIALTILING] = dynamictile(unit.fixed,x,y,name,extra)
		unit.values[VISUALDIR] = unit.direction
		
		local i_ = 4
		if (specialtiling.exists ~= nil) then
			i_ = 8
		end
		
		for i=1,i_ do
			local v = dirs_diagonals_[i]
			ox = v[1]
			oy = v[2]
			
			local tileid = (x+ox) + (y+oy) * roomsizex

			local sect = findallhere(x+ox,y+oy)
			
			if inbounds(x+ox,y+oy) then
				for a,b in ipairs(sect) do
					local tile = mmf.newObject(b)
					
					if (tile.strings[UNITNAME] == name) and (tile.values[TILING] == 1) then
						tile.direction,tile.flags[SPECIALTILING] = dynamictile(b,x+ox,y+oy,name,extra_)
						tile.values[VISUALDIR] = tile.direction
					end
				end
			end
		end
	end
end

table.insert(mod_hook_functions["level_start"],
	function()
		local specialcount = tonumber(MF_read("level","general","specials"))
		for i=0,specialcount-1 do
			local ii = tostring(i)
			local fulldata = MF_read("level","specials",ii.."data")
			local x = tonumber(MF_read("level","specials",ii.."X"))
			local y = tonumber(MF_read("level","specials",ii.."Y"))

			if string.sub(fulldata,1,7) == "offset=" then
				local offset = string.sub(fulldata,8,-1)
				local datas = {""}

				for k=1,string.len(offset) do
					local let = string.sub(offset,k,k)
					if let == "," then
						table.insert(datas,"")
					else
						datas[#datas] = datas[#datas] .. let
					end
				end
				local offx = tonumber(datas[1])
				local offy = tonumber(datas[2])

				if offx ~= nil and offy ~= nil then
					local items = findallhere(x,y)
					for j,id in ipairs(items) do
						local unit = mmf.newObject(id)
						unit.values[XPOS] = unit.values[XPOS] + offx
						unit.values[YPOS] = unit.values[YPOS] + offy
					end
				end
			end
		end
	end
)