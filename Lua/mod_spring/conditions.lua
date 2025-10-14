local currslot = generaldata2.values[SAVESLOT] -- For the stupid your/my thing
local slotname_unf = string.lower(MF_read("settings","slotnames",tostring(currslot)))
slotname = string.gsub(slotname_unf, "%s+", "")
slotname = string.gsub(slotname, "!", "")
slotname = string.gsub(slotname, "@", "")
slotname = string.gsub(slotname, "#", "")
slotname = string.gsub(slotname, "$", "")
--slotname = string.gsub(slotname, "%", "")
slotname = string.gsub(slotname, "^", "")
slotname = string.gsub(slotname, "&", "")
slotname = string.gsub(slotname, "*", "")
--slotname = string.gsub(slotname, "(", "")
--slotname = string.gsub(slotname, ")", "")
slotname = string.gsub(slotname, "?", "")

local introstart = tonumber(MF_read("save", "introstart", "winamt")) or 0

condlist["nocba"] = function(params,checkedconds,checkedconds_,cdata)
    local unitid,x,y = cdata.unitid,cdata.x,cdata.y

    -- Calculate whether the unit fulfils this condition, checking each name in the list "params" if this is an infix condition
    local result = false
    
    if MF_keydown("f") then
        result = true
    else
        result = false
    end
    
    -- Return whether the unit has fulfilled the condition
    return result,checkedconds
end
condlist["keked"] = function(params,checkedconds,checkedconds_,cdata)
    local unitid,x,y = cdata.unitid,cdata.x,cdata.y

    -- Calculate whether the unit fulfils this condition, checking each name in the list "params" if this is an infix condition
    local result = false
    
    if MF_keydown("k") then
        result = true
    else
        result = false
    end
    
    -- Return whether the unit has fulfilled the condition
    return result,checkedconds
end
condlist["your"] = function(params,checkedconds,checkedconds_,cdata)
    HACK_INFINITY = HACK_INFINITY + 1
    if HACK_INFINITY >= 200 then
    destroylevel("infinity")
    return
    end
    local unitid,x,y = cdata.unitid,cdata.x,cdata.y
    local yous = findallfeature(nil, "is", "you") 
    anyyou = #yous > 0 
    local result = false 
    if anyyou == true then
        result = true
    else
	result = false
    end
    return result,checkedconds
end
condlist["pointed"] = function(params,checkedconds,checkedconds_,cdata) -- line no 49
	local unitid,x,y = cdata.unitid,cdata.x,cdata.y
	local unit = mmf.newObject(unitid) 
	mx, my = MF_mouse()
	local result = false 
	if mx ~= nil or my ~= nil then
		if mx >= unit.x-14 and mx <= unit.x+14 then
			if my >= unit.y-14 and my <= unit.y+14 then
			result = true
			else
			result = false
			end
		else
		result = false
		end
	else
	result = false
	end
	return result,checkedconds
end
condlist["my"] = function(params,checkedconds,checkedconds_,cdata)
	local unitid,x,y = cdata.unitid,cdata.x,cdata.y
	local unit = mmf.newObject(unitid)
   	if unitlists[slotname] ~= nil and #unitlists[slotname] > 0 and cdata.name == slotname then
        result = true
	else
	result = false
	end
	return result,checkedconds
end
condlist["shocked"] = function(params,checkedconds,checkedconds_,cdata)
	local unitid,x,y = cdata.unitid,cdata.x,cdata.y
	local unit = mmf.newObject(unitid)
    local target = cdata.name
    local shocker = MF_read("world", "shockunits", target)
    if tonumber(shocker) == 1 then
        result = true
    elseif tonumber(shocker) == 0 or shocker == "" then
        result = false
	end
	return result,checkedconds
end
table.insert(mod_hook_functions["effect_always"],
    function()
        local level = generaldata.strings[CURRLEVEL]
        if level == "1169level" then
		MF_disablebuttons(1)
	elseif level == "671level" then
		MF_disablebuttons(1)
        end
    end
)
table.insert(mod_hook_functions["level_start"],
    function()
        local level = generaldata.strings[CURRLEVEL]
        if level == "2level" then
		if introstart < 1 then
			MF_intro()
            		introstart = introstart + 1
                	MF_store("save", "introstart", "winamt", introstart)
            	end
        end
    end
)
function shocking()
    if featureindex["shock"] ~= nil then
        for a, rule in ipairs(featureindex["shock"]) do
            local target = rule[1][1]
                MF_store("world", "shockunits", target, 1)
        end
    end
    if featureindex["not shock"] ~= nil then
        for a, rule in ipairs(featureindex["not shock"]) do
            local target = rule[1][1]
                MF_store("world", "shockunits", target, "")
        end
    end
end
table.insert(mod_hook_functions["turn_end"], shocking)
function finishing()
    if featureindex["finish"] ~= nil then
         for a, rule in ipairs(featureindex["finish"]) do
            local target = rule[1][1]
            local fin = findallfeature(target, "is", "finish") 
            anyfin = #fin > 0 
            if anyfin == true then
            MF_win()
            end
        end
    end
end
table.insert(mod_hook_functions["turn_end"], finishing)
function leaving()
    if featureindex["leave"] ~= nil then
         for a, rule in ipairs(featureindex["leave"]) do
            local target = rule[1][1]
            local swed = findallfeature(target, "is", "leave") 
            anyswed = #swed > 0 
            if anyswed == true then
            for _,unitid in pairs(unitlists[target]) do
             delete(unitid)  
             setundo(1)
            end
            end
        end
    end
end
table.insert(mod_hook_functions["effect_always"],leaving)
CBASTYLE = 4

-- CBASTYLE = 0 - Characters Become Anything
--      After erroring, the level icons will become the first slot of whatever you have set as
--      your map icons. I suggest setting it to the error sprite.

-- CBASTYLE = 1 - Constant Bothersome Annoyance
--      The game will throw constant errors and the player will have to close the game,
--      reopen it, and revert their edits of the level back to stop it from erroring.

-- CBASTYLE = 2 - Change Back the Alphabet 
--      After erroring, the level icons will change back to the order of ABC. (This will,
--      however, not move the levels back, just change the letters.)

-- CBASTYLE = 3 - Discretely Change Back Arrangement
--      Does the same thing as CBASTYLE 2 except it will not throw an error beforehand.

-- CBASTYLE = 4 - Destroy Completely Because       ...               A
--      After erroring, the entire level will destroy itself. The player will have to
--      go back into the editor and revert their changes.

mod_hook_functions["effect_always"]["cba_detector"] = function()
    for a,unit in ipairs(units) do
        if (unit.values[VISUALSTYLE] == 1) and (unit.values[VISUALLEVEL] == 1) then
            local x = unit.values[XPOS]
            local y = unit.values[YPOS]
            local cbafound = false
            local cbaunits = {unit.fixed}

            local all_left = findallhere(x-1,y)
            local all_right = findallhere(x+1,y)
            local leftfound = false

            for k,unitid in ipairs(all_left) do
                local unit2 = mmf.newObject(unitid)
                if (unit2.values[VISUALSTYLE] == 1) and (unit2.values[VISUALLEVEL] == 2) then
                    leftfound = true
                    cbaunits.c = unitid
                    break
                end
            end

            if (leftfound) then
                for k,unitid in ipairs(all_right) do
                    local unit2 = mmf.newObject(unitid)
                    if (unit2.values[VISUALSTYLE] == 1) and (unit2.values[VISUALLEVEL] == 0) then
                        cbafound = true
                        cbaunits.a = unitid
                        break
                    end
                end
            end

            if (cbafound) then
                cbaerror(cbaunits)
            else
                cbaunits = {unit.fixed}

                local all_up = findallhere(x,y-1)
                local all_down = findallhere(x,y+1)
                local upfound = false

                for k,unitid in ipairs(all_up) do
                    local unit2 = mmf.newObject(unitid)
                    if (unit2.values[VISUALSTYLE] == 1) and (unit2.values[VISUALLEVEL] == 2) then
                        upfound = true
                        cbaunits.c = unitid
                    end
                end

                if (upfound) then
                    for k,unitid in ipairs(all_down) do
                        local unit2 = mmf.newObject(unitid)
                        if (unit2.values[VISUALSTYLE] == 1) and (unit2.values[VISUALLEVEL] == 0) then
                            cbaunits.a = unitid
                            cbaerror(cbaunits)
                            break
                        end
                    end
                end
            end
        end
    end
end
function cbaerror(cbaunits)
    if (CBASTYLE == 0) then
        for a,b in pairs(cbaunits) do
            local unit = mmf.newObject(b)
            unit.values[VISUALSTYLE] = -1
            unit.values[VISUALLEVEL] = 0
        end
    elseif (CBASTYLE == 2) or (CBASTYLE == 3) then
        local cunit = mmf.newObject(cbaunits.c)
        local aunit = mmf.newObject(cbaunits.a)

        cunit.values[VISUALLEVEL] = 0
        aunit.values[VISUALLEVEL] = 2
    elseif (CBASTYLE == 4) then
        destroylevel_check = true
        destroylevel_do()
    end

    if (CBASTYLE ~= 3) then
        error("Data/Worlds/embaba/lua/cba_detector.lua:255: bad argument 'advanced' to 'chess' (battle expected, got souvey)\nCheck the toads for more poking.",999)
    end
end