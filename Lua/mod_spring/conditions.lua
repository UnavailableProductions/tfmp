
-- Utility Function; SPLITS a STRING using a DELIMITER --> return a LIST of the two halves of the STRING
function stringsplit(str, delimiter)
    local result = {}
    if type(str) ~= "string" or type(delimiter) ~= "string" or delimiter == "" then
        error("Invalid arguments: expected (string, non-empty string)")
    end
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    
    return result
end
-- END SECTION


-- Misc Variables
orntimer = 0
local undone = false
local undoing = false
-- END SECTION


-- Misc Lists
local iflist = {false}
agreeexist = {}
-- END SECTION


-- Utility Variable; slotname
local currslot = generaldata2.values[SAVESLOT] -- For the stupid your/my thing
local slotname_unf = string.lower(MF_read("settings","slotnames",tostring(currslot)))
MF_store("world","ifdebug","ifbool","0")
slotname = string.gsub(slotname_unf, "%s+", "")
slotname = string.gsub(slotname, "!", "")
slotname = string.gsub(slotname, "@", "")
slotname = string.gsub(slotname, "#", "")
slotname = string.gsub(slotname, "$", "")
slotname = string.gsub(slotname, "^", "")
slotname = string.gsub(slotname, "&", "")
slotname = string.gsub(slotname, "*", "")
slotname = string.gsub(slotname, "?", "")
local introstart = tonumber(MF_read("save", "introstart", "winamt")) or 0
if slotname == "intro" or slotname == "intro2" then
    introstart = 0 
end
-- END SECTION


-- IFCOND, IFRULE, THEN, NOCBA, KEKED, YOUR, POINTED, MY, SHOCKED [Ember]
function iflistreset()
    MF_store("world","ifdebug","ifbool","0")
end
table.insert(mod_hook_functions["level_start"],iflistreset)

-- IFCOND (1); condition: DOES NOT WORK ATM DO NOT USE
condlist["ifcond"] = function(params,checkedconds,checkedconds_,cdata)
    MF_store("world","ifdebug","ifbool","1")
    return false,checkedconds
end

-- IFCOND (2); effect_once: DOES NOT WORK ATM DO NOT USE
function ifcond()
    for a, rule in ipairs(featureindex["is"]) do
        MF_store("world","ifdebug","ifbool","1")
    end
end
table.insert(mod_hook_functions["effect_once"],ifcond)

-- IFRULE; condition: DOES NOT WORK ATM DO NOT USE
condlist["ifrule"] = function(params,checkedconds,checkedconds_,cdata)
    MF_store("world","ifdebug","ifbool","1")
    return false,checkedconds
end

-- THEN; condition: DOES NOT WORK ATM DO NOT USE
condlist["then"] = function(params,checkedconds,checkedconds_,cdata)
    result = false
    ifres = tonumber(MF_read("world","ifdebug","ifbool"))
    error(ifres)
    if ifres == 1 then
        result = true
    end
    return result,checkedconds
end

-- NOCBA; condition: result TRUE if "F" is pressed
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

-- KEKED; condition: result TRUE if "K" is pressed
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

-- YOUR; condition: result TRUE if theres an OBJECT with the effect "YOU"
condlist["your"] = function(params,checkedconds,checkedconds_,cdata)
    HACK_INFINITY = HACK_INFINITY + 1
    if HACK_INFINITY >= 10000 then
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

-- POINTED; condition: result TRUE if your mouse cursor is HOVERING over the TARGET OBJECT
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

-- MY; condition: result TRUE if the SLOTNAME is the same as the TARGET OBJECT
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

-- SHOCKED; condition: result true if the TARGET OBJECT has a SHOCK value of 1
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
-- END SECTION


-- Utility Function; EFFECT ALWAYS check for what LEVEL you are in
table.insert(mod_hook_functions["effect_always"],
    function()
        local level = generaldata.strings[CURRLEVEL]
    if level == "1169level" then
		MF_disablebuttons(1)
    elseif level == "1283level" then
		MF_disablebuttons(1)
	elseif level == "671level" then
		MF_disablebuttons(1)
    elseif level == "matthew" then
        MF_store("save",generaldata.strings[WORLD],"matthewgaming","1")
		MF_disablebuttons(1)
    end
    end
)
-- END SECTION


-- Utility Function; on LEVEL START run this
table.insert(mod_hook_functions["level_start"],
    function()
        local level = generaldata.strings[CURRLEVEL]
        orndebug = MF_read("save",generaldata.strings[WORLD],"baublelevels")
        orndebuglist = stringsplit(orndebug,',')
        if orndebug ~= '' then 
        ornbuffer = #orndebuglist
        else
        ornbuffer = 0
        end 
        ornbuffercap = ornbuffer 
        if level ~= "1179level" then
        if slotname == 'test' then
            leveltransition_change('1179level')
        end
        end
        if level == "2level" or slotname == "intro2" then
		if introstart < 1 then
			MF_intro()
            		introstart = introstart + 1
                	MF_store("save", "introstart", "winamt", introstart)
            	end
        end
        agreeexist = {}
    end
)
-- END SECTION


-- SHOCK [Ember] -- For SHOCKED goto line 173

-- SHOCKING; turn_end
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
-- END SECTION


-- FINISH, SWEDISH [Ember,Spring]

-- FINISHING; effect_always
function finishing()
    if featureindex["finish"] ~= nil then
        for a, rule in ipairs(featureindex["finish"]) do
            local target = rule[1][1]
            local fin = findallfeature(target, "is", "finish") 
            anyfin = #fin > 0 
            if anyfin == true then
                if testwinconds() then -- use this to detect CLEAR CONDS
                    MF_win()
                end
            end
        end
    end
end
table.insert(mod_hook_functions["effect_always"], finishing)

-- SWEDISHING; effect_always
function swedishing()
    if featureindex["swedish"] ~= nil then
        for a, rule in ipairs(featureindex["swedish"]) do
            local target = rule[1][1]
            local fin = findallfeature(target, "is", "swedish") 
            anyswe = #fin > 0 
            if anyswe == true then
                if not testwinconds() then
                    MF_win()
                end
            end
        end
    end
end
table.insert(mod_hook_functions["effect_always"], swedishing)
-- END SECTION


-- ORNAMENT, BAUBLE [EMBER]

-- ORNAMENT; effect_always
function ornament()
    if featureindex["ornament"] ~= nil then
        if orntimer == 0 then
        for a, rule in ipairs(featureindex["ornament"]) do
            local target = rule[1][1]
            mx, my = MF_mouse()
            local ghand =  generaldata.values[TILESIZE]*generaldata.values[ROOMSIZEX]
            local ghand2 =  generaldata.values[TILESIZE]*generaldata.values[ROOMSIZEY]
            local ghand3 = generaldata.values[ROOMSIZEX]/2
            local ghand4 = generaldata.values[ROOMSIZEY]/2
            if  MF_mousedown(1) then
                if MF_mousedown(2) and MF_mousedown(3) then
                    error(tostring(ornbuffer).."ornaments")
                end 
                if ornbuffer > 0 then
                    if generaldata.values[ROOMSIZEX] > generaldata.values[ROOMSIZEY] then -- long > tall
                        create(target,math.floor(mx/ghand*ghand3),math.floor(my/ghand2*ghand4),1,mx/ghand,my/ghand2,nil,nil,leveldata)
                        ornbuffer = ornbuffer -1
                        setundo(1)
                    elseif generaldata.values[ROOMSIZEX] == generaldata.values[ROOMSIZEY] then -- long = tall
                        create(target,math.floor(mx/ghand*ghand3)-math.floor(generaldata.values[ROOMSIZEX]/2.5),math.floor(my/ghand2*ghand4),1,mx/ghand,my/ghand2,nil,nil,leveldata)
                        ornbuffer = ornbuffer -1
                        setundo(1)
                    elseif generaldata.values[ROOMSIZEX] < generaldata.values[ROOMSIZEY] then -- tall > long (buggy)
                        create(target,math.floor(mx/ghand*ghand3)-math.floor(generaldata.values[ROOMSIZEX]/2.5),math.floor(my/ghand2*ghand4*2.5),1,mx/ghand,my/ghand2,nil,nil,leveldata)
                        ornbuffer = ornbuffer -1
                        setundo(1)
                    end 
                    orntimer = 5
                end
            end
        end
        else
            orntimer = orntimer - 1
        end
    end
end
table.insert(mod_hook_functions["effect_always"], ornament)

-- BAUBLE; level_win
function bauble()
    if featureindex["bauble"] ~= nil then
        found = false
        local level = generaldata.strings[CURRLEVEL]
        for _, v in ipairs(orndebuglist) do
        if v == level then
            found = true
        end
        end 
        if found == false then
            if orndebug == '' then
            MF_store("save",generaldata.strings[WORLD], "baublelevels",level)
            else
            MF_store("save",generaldata.strings[WORLD], "baublelevels",orndebug..','..level)
            end 
        end
    end
end
table.insert(mod_hook_functions["level_win"], bauble)
-- END SECTION


-- LEAVE, LEAVES [Ember]

-- LEAVING; effect_always
function leaving()
    if featureindex["leave"] ~= nil then
         for a, rule in ipairs(featureindex["leave"]) do
            local target = rule[1][1]
            if target == "level" then
                destroylevel('leave')
            end
            local leav = findallfeature(target, "is", "leave") 
            anyleav = #leav > 0 
            if anyleav == true then
            for _,unitid in pairs(unitlists[target]) do
            if target == "level" then
                destroylevel('leave')
            end
             delete(unitid)  
             setundo(1)
            end
            end
        end
    end
    if featureindex["leaves"] ~= nil then
         for a, rule in ipairs(featureindex["leaves"]) do
            local target = rule[1][1]
            if target == "level" then
                destroylevel('leave')
            end
            local subject = rule[1][3] 
            local sleav= findallfeature(target, "leaves", subject) 
            anysleav = #sleav > 0 
            if unitlists[target] ~= nil then
                if #unitlists[target] > 0 then
                    if unitlists[subject] ~= nil then
                        if #unitlists[subject] > 0 then
                            if anysleav == true then
                                for _,unitid in pairs(unitlists[target]) do
                                    delete(unitid)  
                                    setundo(1)
                                end
                             end
                        end
                    end
                end
            end
        end
    end
end
table.insert(mod_hook_functions["effect_always"],leaving)
-- END SECTION


-- NOTHING [Ember]

-- NOTH; effect_once
function noth()
    if featureindex["nothing"] ~= nil then
         for a, rule in ipairs(featureindex["nothing"]) do
            local target = rule[1][1]
            local swed = findallfeature(target, "is", "nothing")
            local anyswed = false
            anyswed = #swed > 0 
            if anyswed == true then
                for _,unitid in pairs(unitlists[target]) do
                    if target ~= "empty" then
                        delete(unitid)  
                        addundo("nothing")
                    end
                end
            end
        end
    end
end
table.insert(mod_hook_functions["effect_once"],noth)
-- END SECTION


-- MASK, REVEAL, MASKED [Spring]
unitmask = {} -- global list for getting the sprite of an object (only works when not setting a custom sprite in the editor due to how i made it btw)

-- DISGUISE; effect_once
function disguise()
    if featureindex["mask"] ~= nil then
        for a, rule in ipairs(featureindex["mask"]) do
            local target = rule[1][1]
            local subject = rule[1][3]
            local sdis= findallfeature(target, "mask", subject)
            anysdis = #sdis > 0 
            if unitlists[target] ~= nil then
                if #unitlists[target] > 0 then
                    if anysdis == true then
                        for _,unitid in pairs(unitlists[target]) do
                            if target ~= "level" and string.sub(subject, 1, 4) ~= "not " then
                                if featureindex[subject] ~= nil then
                                    for _,unitid2 in pairs(unitlists[subject]) do
                                        local c1,c2 = getcolour(unitid2)
                                        MF_setcolour(unitid,c1,c2)
                                    end
                                end
                                unitmask[target] = subject
                                MF_changesprite(unitid, subject, true)
                                MF_changesprite(unitid, subject, false)
                            end
                        end
                    end
                end
            end
        end
    end
end
table.insert(mod_hook_functions["effect_once"], disguise)

-- UNDISGUISE; effect_once
function undisguise()
    if featureindex["reveal"] ~= nil then
        for a, rule in ipairs(featureindex["reveal"]) do
            local target = rule[1][1]
            local sudis= findallfeature(target, "is", "reveal")
            anysudis = #sudis > 0 
            if unitlists[target] ~= nil then
                if #unitlists[target] > 0 then
                    if anysudis == true then
                        for _,unitid in pairs(unitlists[target]) do
                            if target ~= "level" then
                                local c1,c2 = getcolour(unitid)
                                unitmask[target] = target
                                MF_setcolour(unitid,c1,c2)
                                MF_changesprite(unitid, target, true)
                                MF_changesprite(unitid, target, false)
                            end
                        end
                    end
                end
            end
        end
    end
end
table.insert(mod_hook_functions["effect_once"], undisguise)

-- ADDMASKLIST; level_start, level_restart
function addmasklist()
    unitmask = {}
    for i,mat in pairs(objectlist) do
        table.insert(unitmask, i)
        unitmask[i] = i
    end
end
table.insert(mod_hook_functions["level_start"], addmasklist)
table.insert(mod_hook_functions["level_restart"], addmasklist)

-- MASKED; condition: result TRUE if TARGET OBJECT is MASKED as another
condlist["masked"] = function(params,checkedconds,checkedconds_,cdata)
    local unitname = cdata.name
    local result = false
    if unitmask[unitname] ~= unitname then
        result = true
    end
	return result,checkedconds
end

-- NOT MASKED; condition: result TRUE if TARGET OBJECT is NOT MASKED as another
condlist["not masked"] = function(params,checkedconds,checkedconds_,cdata)
    local unitname = cdata.name
    local result = false
    if unitmask[unitname] == unitname then
        result = true
    end
	return result,checkedconds
end
-- END SECTION


-- TWICE [Spring]

-- TWICE; condition: result TURE if you PRESS the same KEY TWICE
condlist["twice"] = function(params,checkedconds)
        local result = false
        if undobuffer[1] ~= nil then
            if last_key == undobuffer[1].key then
                result = true
            else
                result = false
            end
        end
        return result,checkedconds
    end

-- NOT TWICE; condition: result TURE if you DONT PRESS the same KEY TWICE
condlist["not twice"] = function(params,checkedconds)
        local result = false
        if undobuffer[1] ~= nil then
            if last_key ~= undobuffer[1].key then
                result = true
            else
                result = false
            end
        end
        return result,checkedconds
    end
-- END SECTION


-- UNDONE, UNDOING [Spring]

-- UNDONE; undoed_after, turn_end, level_start, level_restart; condition: result TRUE if you press UNDO
condlist["press_undone"] = function(params,checkedconds)
        return undone,checkedconds
    end

table.insert(mod_hook_functions.undoed_after, function()
    undone = true
end)
table.insert(mod_hook_functions.turn_end, function()
    undone = false
end)
table.insert(mod_hook_functions.level_start, function()
    undone = false
end)
table.insert(mod_hook_functions.level_restart, function()
    undone = false
end)

-- UNDOING; undoed, turn_end, level_start, level_restart; condition: result TRUE if you hold UNDO
condlist["undoing"] = function(params,checkedconds)
        return undoing,checkedconds
    end

table.insert(mod_hook_functions.undoed, function()
    undoing = true
end)
table.insert(mod_hook_functions.turn_end, function()
    undoing = false
end)
table.insert(mod_hook_functions.level_start, function()
    undoing = false
end)
table.insert(mod_hook_functions.level_restart, function()
    undoing = false
end)
-- END SECTION


-- TOO [Ember, Spring]

-- TOO; effect_once
function too()
    if featureindex["too"] ~= nil then
        for a, rule in ipairs(featureindex["too"]) do
            local target = rule[1][1]
            local subject = rule[1][3]
            local stoo = findallfeature(target, "too", subject)
            anystoo = #stoo > 0
            if anystoo == true then
                for b, rule2 in ipairs(featureindex[subject]) do
                    local target2 = rule2[1][1]
                    local opr = rule2[1][2]
                    local btoo = findallfeature(target2, opr, subject)
                    anybtoo = #btoo > 0
                    if anybtoo == true then
                        if target2 ~= target then
                            destroylevel("list")
                            setundo(1)
                        end
                    end
                end    
            end
        end
    end
end
table.insert(mod_hook_functions["effect_once"],too)
-- END SECTION


-- Utility Function; if TABLE has ELEMENT --> return TRUE
function tableContains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end
-- END SECTION


-- AGREES [Spring]

-- AGREE; command_given
function agree()    
    if featureindex["agrees"] ~= nil then
        for i,r in ipairs(featureindex["agrees"]) do
            table.insert(agreeexist, {r[1][1], "agrees", r[1][3]})
        end
        if agreeexist[1] ~= nil then
            for i, v in pairs(agreeexist) do
                if v[1] ~= v[3] then
                    for a, rule in ipairs(featureindex[v[3]]) do
                        local subject = rule[1][3]
                        local operator = rule[1][2]
                        local target = rule[1][1]
                        local pconds = rule[2]
                        local ids = rule[3]
                        local tags = rule[4]
                        local rule = {v[1], operator, subject}
                        if target == v[3] then
                            if tableContains(tags, "base") == false then
                                addoption(rule, pconds, ids, false, nil, {"agree"})
                            end
                        end
                    end
                end
                table.remove(agreeexist, i)
            end
        end
    end
end
table.insert(mod_hook_functions["command_given"],agree)
-- END SECTION


-- TAGS [Ember,Spring]

-- TAGS; rule_baserules
function tags()
    for i,mat in pairs(objectlist) do
        if string.sub(i, 1, 5) == "tags_" then
            if i ~= "tags_meta" then
                addbaserule_fixed(i, "is", string.sub(i, 6),{})
            else
                addbaserule_fixed(i, "is", "text_" .. string.sub(i, 6),{})
            end
        end
    end
end
table.insert(mod_hook_functions["rule_baserules"],tags)
-- END SECTION


-- MINEEFFECT [Ember,Spring]
local newslotname -- absolute cinema \o/

-- MINEEFFECT; effect_once
function mineeffect()
    if newslotname ~= slotname then
        newslotname = slotname
        for i,mat in pairs(objectlist) do
            if slotname == i then
                addbaserule_fixed(i, "is", "mineeffect",{})
            end
        end
    end
end
table.insert(mod_hook_functions["effect_once"],mineeffect)

-- RESETNEWSLOTNAME; rule_update
function resetnewslotname()
    newslotname = ""
end
table.insert(mod_hook_functions["rule_update"],resetnewslotname)
-- END SECTION


-- CBA DETECTOR [uhh idk]
CBASTYLE = 4

-- CBA DETECTOR; effect_always, cba_detector
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

-- CBAERROR; called
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
        MF_store("save",generaldata.strings[WORLD],"nocbaforyou","1")
        error("Data/Worlds/embaba/lua/cba_detector.lua:255: bad argument 'advanced' to 'chess' (battle expected, got souvey)\nCheck the toads for more poking.",999)
    end
end
-- END SECTION