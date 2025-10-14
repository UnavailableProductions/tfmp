--[[
oh god how do i port this without the other part of the mod that sets the zoom
i guess i will just add a menu in editor
wait what's the point of having camera if level follow x doesn't exist
i guess i will make the game better
]]
local zoom = 1
local cameracenterx = 0
local cameracentery = 0
local MYMIDDLETILEX = 0
local MYMIDDLETILEY = 0
local zoombeforthemod = generaldata2.values[ZOOM]
local function MYposcorrect(unitid,rotation,zoom,offset)
	local unit = mmf.newObject(unitid)
	
	if (spritedata.values[VISION] == 0) or (unit.values[ZLAYER] >= 21) and (spritedata.values[DOPOSCORRECT] == 0) then
		if (unit ~= nil) then
			local midpointx = MYMIDDLETILEX * tilesize * spritedata.values[TILEMULT]
			local midtilex = math.floor(MYMIDDLETILEX) - 0.5
			
			if (roomsizex % 2 == 1) then
				midtilex = math.floor(MYMIDDLETILEX)
			end
			
			local midpointy = MYMIDDLETILEY * tilesize * spritedata.values[TILEMULT]
			local midtiley = math.floor(MYMIDDLETILEY) - 0.5
			
			if (roomsizey % 2 == 1) then
				midtiley = math.floor(MYMIDDLETILEY)
			end
			
			local x,y = unit.values[XPOS],unit.values[YPOS]
			local dx = x - midtilex
			local dy = y - midtiley
			
			local dir = 0 - math.atan2(dy,dx) + math.rad(rotation)
			local dist = math.sqrt((dy)^2 + (dx)^2)
			
			local newx = Xoffset + midpointx + math.cos(dir) * dist * zoom * tilesize * spritedata.values[TILEMULT]
			local newy = Yoffset + midpointy - math.sin(dir) * dist * zoom * tilesize * spritedata.values[TILEMULT]
			
			if (unit.values[FLOAT] == 0) then
				unit.x = newx
				unit.y = newy + offset * spritedata.values[TILEMULT]
			elseif (unit.values[FLOAT] == 1) then
				unit.x = newx
				--unit.y = newy + offset * spritedata.values[TILEMULT]
			end
		else
			MF_alert("Poscorrect: unitid " .. tostring(unitid) .. " isn't valid!")
		end
	end
end
local function updateall()
	for i, id in pairs(MF_getunits()) do
		local unit = mmf.newObject(id)
		--update(id,unit.values[4],unit.values[5],unit.values[6])
		--move(id,0,0,unit.values[6],specials_,true,simulate_,x_,y_)
		unit.scaleX = generaldata2.values[ZOOM] * spritedata.values[TILEMULT]
		unit.scaleY = generaldata2.values[ZOOM] * spritedata.values[TILEMULT] 
		MYposcorrect(id,generaldata2.values[ROOMROTATION],generaldata2.values[ZOOM],0)
		MYposcorrect(id,generaldata2.values[ROOMROTATION],generaldata2.values[ZOOM],0)
	end
end
local function updatezoom()
	generaldata2.values[ZOOM] = zoom or 1
	updateall()
end
local function OLDupdatecameracenter()
	local multby = generaldata2.values[ZOOM] * spritedata.values[TILEMULT]
	local offsetx = cameracenterx-spritedata.values[XMIDTILE]
	local offsety = cameracentery-spritedata.values[YMIDTILE]
	MYMIDDLETILEX = cameracenterx
	MYMIDDLETILEY = cameracentery
	local newx 
	local newy 
	if roomsizex-2<=33 and roomsizey-2<=18 then
		newx = 247-tilesize/2*(roomsizex-15)+offsetx*tilesize*multby*(-1)
		newy = 60-tilesize/2*(roomsizey-15)+offsety*tilesize*multby*(-1)
	else
		newx = 187+offsetx*tilesize*multby*(-1)
		newy = 0+offsety*tilesize*multby*(-1)
	end
	addundo({"levelupdate",Xoffset,Yoffset,newx,newy})
	MF_setroomoffset(newx,newy)
end
local defaultcenterx
local defaultcentery
local function updatecameracenter()
	local multby = generaldata2.values[ZOOM] * spritedata.values[TILEMULT]
	local offsetx = cameracenterx-spritedata.values[XMIDTILE]
	local offsety = cameracentery-spritedata.values[YMIDTILE]
	MYMIDDLETILEX = cameracenterx
	MYMIDDLETILEY = cameracentery
	local newx 
	local newy 
	newx = defaultcenterx+offsetx*tilesize*multby*(-1)
	newy = defaultcentery+offsety*tilesize*multby*(-1)
	addundo({"levelupdate",Xoffset,Yoffset,newx,newy})
	MF_setroomoffset(newx,newy)
end
local L
local function camfollow()
	--timedmessage(tostring(MF_read("level","ExperimentalSettingsOrSomething","CameraZoom")==""))
	if featureindex["level"]~=nil and #featureindex["level"]>0 then
		for i, rule in pairs(featureindex["level"]) do
			if rule[1][1] == "level" and rule[1][2] == "follow" then
				local who = rule[1][3]
				local myunitlist = unitlists[who]
				if #myunitlist == 1 then
					--[[timedmessage(tostring(myunitlist[1]))
					spritedata.values[18] = mmf.newObject(myunitlist[1]).values[ID] ]]
					--MF_setroomoffset((roomsizex/2-mmf.newObject(myunitlist[1]).values[4])*tilesize, (roomsizey/2-mmf.newObject(myunitlist[1]).values[5])*tilesize)						--MF_setroomoffset(0,(roomsizey/2-mmf.newObject(myunitlist[1]).values[5]+2)*tilesize)
					--zoom=zoom*1.05
					local unit = mmf.newObject(myunitlist[1])
					--timedmessage(L)
					cameracenterx = unit.values[4]+0.5
					cameracentery = unit.values[5]+0.5
					updatecameracenter()
				elseif #myunitlist>1 then
					local unit = mmf.newObject(myunitlist[fixedrandom(1,#myunitlist)])
					cameracenterx = unit.values[4]+0.5
					cameracentery = unit.values[5]+0.5
					updatecameracenter()
				end
			end
		end
	end
end
local def = function()
		L = tostring(Xoffset).." "..tostring(Yoffset).." "..tostring(tilesize).." "..tostring(generaldata2.values[ZOOM]).." "..tostring(spritedata.values[TILEMULT])
		defaultcenterx = Xoffset
		defaultcentery = Yoffset
		zoom = MF_read("level","ExperimentalSettingsOrSomething","CameraZoom") or "1"
		--timedmessage("WHATTHEHELLLL:"..zoom)
		zoom = tonumber(zoom)
		cameracenterx = roomsizex/2
		cameracentery = roomsizey/2
		updatezoom()
		updatecameracenter()
		camfollow()
		--MF_setroomoffset(180,180)
	end
table.insert(mod_hook_functions["level_start"],def)
table.insert(mod_hook_functions["level_end"],def)
table.insert(mod_hook_functions["effect_once"],camfollow)
local iswaitingforinput = false
local presstable = {
["h"] = false,
["1"] = false,
["2"] = false,
["3"] = false,
["4"] = false,
["5"] = false,
["6"] = false,
["7"] = false,
["8"] = false,
["9"] = false,
["0"] = false,
["."] = false
}
local oldpresstable = {
["h"] = false,
["1"] = false,
["2"] = false,
["3"] = false,
["4"] = false,
["5"] = false,
["6"] = false,
["7"] = false,
["8"] = false,
["9"] = false,
["0"] = false,
["."] = false
}
local inputrn = ""
table.insert(mod_hook_functions["always"],function()
	if generaldata.values[MODE] == 4 then
		generaldata2.values[ZOOM] = zoombeforthemod
	end
	if generaldata.values[MODE]==5 and generaldata2.values[INMENU]==0 and  generaldata2.values[INPAUSEMENU]==0 then
		for key, val in pairs(presstable) do
			presstable[key] = MF_keydown(key)
		end
		
		
		
		if presstable.h and not oldpresstable.h then
			iswaitingforinput = not iswaitingforinput
			if iswaitingforinput then
				inputrn = ""
			else
				MF_letterclear("timedmessage")
				MF_store("level","ExperimentalSettingsOrSomething","CameraZoom", inputrn )
				timedmessage("Zoom multiplier set to "..inputrn)
			end
		end
		if iswaitingforinput then
			MF_letterclear("timedmessage")
			timedmessage("Input the zoom multiplier (. for decimals)... "..inputrn)
			if presstable["1"] and not oldpresstable["1"] then
				inputrn = inputrn.."1"
			end
			if presstable["2"] and not oldpresstable["2"] then
				inputrn = inputrn.."2"
			end
			if presstable["3"] and not oldpresstable["3"] then
				inputrn = inputrn.."3"
			end
			if presstable["4"] and not oldpresstable["4"] then
				inputrn = inputrn.."4"
			end
			if presstable["5"] and not oldpresstable["5"] then
				inputrn = inputrn.."5"
			end
			if presstable["6"] and not oldpresstable["6"] then
				inputrn = inputrn.."6"
			end
			if presstable["7"] and not oldpresstable["7"] then
				inputrn = inputrn.."7"
			end
			if presstable["8"] and not oldpresstable["8"] then
				inputrn = inputrn.."8"
			end
			if presstable["9"] and not oldpresstable["9"] then
				inputrn = inputrn.."9"
			end
			if presstable["0"] and not oldpresstable["0"] then
				inputrn = inputrn.."0"
			end
			if presstable["."] and not oldpresstable["."] then
				inputrn = inputrn.."."
			end
		end
		
		
		
		for key, val in pairs(oldpresstable) do
			oldpresstable[key] = MF_keydown(key)
		end
	end
end)