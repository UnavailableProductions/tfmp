table.insert(editor_objlist_order,"text_script")
editor_objlist["text_script"] = {
    name = "text_script",
    sprite_in_root = false,
    unittype = "text",
    tags = {"text_noun","text_special"},
    tiling = -1,
    type = 0,
    layer = 20,
    colour = {5, 2},
    colour_active = {5, 3},
}

table.insert(editor_objlist_order,"text_code")
editor_objlist["text_code"] = {
    name = "text_code",
    sprite_in_root = false,
    unittype = "text",
    tags = {"text_verb","text_special"},
    tiling = -1,
    type = 1,
    argtype = {0,2},
    layer = 20,
    colour = {5, 2},
    colour_active = {5, 3},
}

table.insert(editor_objlist_order,"text_unpatch")
editor_objlist["text_unpatch"] = {
    name = "text_unpatch",
    sprite_in_root = false,
    unittype = "text",
    tags = {"text_quality","text_special"},
    tiling = -1,
    type = 2,
    layer = 20,
    colour = {5, 2},
    colour_active = {5, 3},
}

table.insert(editor_objlist_order,"text_void")
editor_objlist["text_void"] = {
    name = "text_void",
    sprite_in_root = false,
    unittype = "text",
    tags = {"text_quality","text_special"},
    tiling = -1,
    type = 2,
    layer = 20,
    colour = {5, 2},
    colour_active = {5, 3},
}

table.insert(editor_objlist_order,"text_scripted")
editor_objlist["text_scripted"] = {
    name = "text_scripted",
    sprite_in_root = false,
    unittype = "text",
    tags = {"text_conditions","text_special"},
    tiling = -1,
    type = 3,
    argtype = {0,2},
    layer = 20,
    colour = {5, 2},
    colour_active = {5, 3},
}

table.insert(nlist.full,"script")
table.insert(nlist.short,"script")
table.insert(nlist.objects,"script")

formatobjlist()

function add_script(effect)
    local scriptname = "script_"..effect
    local textname = "text_"..effect
    local textobj = editor_objlist[editor_objlist_reference[textname]]
    if textobj == nil then
        return
        error("Bro there's no text object for this script!"..effect)
    end
    local scriptobj = {
        name = scriptname,
        sprite_in_root = false,
        unittype = "object",
        tags = {"abstract"},
        tiling = -1,
        layer = 20,
        colour = textobj.colour_active,
    }
    if textobj.type ~= 2 and textobj.type ~= 0 then
        return
    else
        if not MF_findsprite(scriptname.."_0_1.png",false) then
            if textobj.type == 0 then
                scriptobj.sprite = "script_object"
            else
                return
            end
            --error("Bro there's no sprite for this script!")
        end
    end
    table.insert(editor_objlist_order,scriptname)
    editor_objlist[scriptname] = scriptobj
end

for _,v in pairs(editor_objlist_order) do
    if string.sub(v,1,5) == "text_" then
        add_script(string.sub(v,6))
    end
end
formatobjlist()

function patch_unit(unitid, prop)
    local unit = mmf.newObject(unitid)
    if hasfeature(getname(unit),"is","unpatch",unitid) then
        return
    end
    addundo({"patch",unit.values[ID],prop})
    updateundo = true
    if unit.patches == nil then unit.patches = {} end
    if unit.patches[prop] == nil then unit.patches[prop] = 0 end
    unit.patches[prop] = unit.patches[prop] + 1
    updatecode = 1
end

function get_patches(unitid)
    local result = {}
    local unit = mmf.newObject(unitid)
    if unit.patches == nil then return result end
    for k,v in pairs(unit.patches) do
        for i=1,v do
            table.insert(result,k)
        end
    end
    return result
end

function clear_patches(unit) --for unpatch
    if unit.patches == nil then return end
    local patches_copy = {}
    for k,v in pairs(unit.patches) do
        patches_copy[k] = v
    end
    addundo({"unpatch",unit.values[ID],patches_copy})
    updateundo = true
    updatecode = 1
    unit.patches = nil
    local x,y = unit.values[XPOS],unit.values[YPOS]
    local pmult,sound = checkeffecthistory("unlock")
    MF_particles("unlock",x,y,15 * pmult,2,4,1,1)
end

function add_patch_rules()
    local patch_added = false
    local needed_rules = {}
    for _,v in pairs(units) do
        if v.patches ~= nil then
            local unitname = v.strings[UNITNAME]
            for k,conut in pairs(v.patches) do
                if needed_rules[unitname] == nil then
                    needed_rules[unitname] = {}
                end
                if needed_rules[unitname][k] == nil then
                    needed_rules[unitname][k] = 0
                end
                needed_rules[unitname][k] = math.max(needed_rules[unitname][k],conut)
            end
        end
    end
    for unitname,rules in pairs(needed_rules) do
        for rule,count in pairs(rules) do
            for i=1,count do
                local condtable = {}
                for j = 1,i do
                    table.insert(condtable,rule)
                end
                addoption({unitname,"is",rule},{{"scripted",condtable}},{},false)
            end
            patch_added = true
        end
    end
    return patch_added
end

function update_patch_rules()
    local doned = {}

    if (unitlists["script"] ~= nil) then
        for _,id in ipairs(unitlists["script"]) do
            local unit = mmf.newObject(id)
            local name = getname(unit)
            local effect = string.sub(name,8)
            if string.sub(name,1,7) == "script_" then
                local x,y = unit.values[XPOS],unit.values[YPOS]
                local tileid = x + y * roomsizex
                local isdone = false

                if (unitmap[tileid] ~= nil) then
                    local things = findallhere(x,y)

                    if (#things > 0) then
                        for a,b in ipairs(things) do
                            if floating(b,unit.fixed,x,y) then
                                if (b ~= unit.fixed) and not (string.sub(mmf.newObject(b).strings[UNITNAME],1,7) == "script_") then
                                    patch_unit(b, effect)
                                    isdone = true
                                end
                            end
                        end
                    end
                end

                if isdone and (unit.flags[DEAD] == false) then
                    table.insert(doned, unit)
                end
            end
        end

        if (#doned> 0) then
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
                addundo({"done",unit.strings[UNITNAME],unit.values[XPOS],unit.values[YPOS],unit.values[DIR],unit.values[ID],unit.fixed,ufloat,nil,unit.patches})
            end

            delunit(unit.fixed)
            dynamicat(x,y)
        end

    end

    local unpatch = getunitswitheffect("unpatch")
    for _,unit in ipairs(unpatch) do
        clear_patches(unit)
    end

end

condlist["scripted"] = function(params,checkedconds,checkedconds_,cdata)
    local unitid,x,y = cdata.unitid,cdata.x,cdata.y
    local unit = mmf.newObject(unitid)

    if unit == nil then return false end

    if #params == 0 then
        if unit.patches == nil then return false end
        for _,__ in pairs(unit.patches) do
            return true, checkedconds
        end
        return false, checkedconds
    end

    local count_table = {} --count of each effect in params
    for _,v in ipairs(params) do
        if count_table[v] == nil then
            count_table[v] = 0
        end
        count_table[v] = count_table[v] + 1
    end

    local patches = unit.patches
    if patches == nil then return false end
    --comp patches w/ count_table
    for k,v in pairs(count_table) do
        if (patches[k] == nil) or (patches[k] < v) then
            return false
        end
    end
    return not (hasfeature(unit.strings[UNITNAME],"is","void",unitid)),checkedconds
end