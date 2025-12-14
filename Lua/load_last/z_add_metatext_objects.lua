local layers = 3
local meta_objs = {}
local c_objs = {}
tag_objs = {}


for num = 1, layers do
    table.insert(objlistdata.alltags, "metatext (" .. num .. ")")
    for i, v in pairs(editor_objlist_order) do
        if string.sub(v, 1, 5) == "text_" then
            local data = editor_objlist_reference[v]
            if data ~= nil then
                v = editor_objlist[data]
                local rootcheck = true
                local thissprite = nil
                if v.sprite == nil then v.sprite = v.name end
                if v.sprite ~= nil then
                    thissprite = v.sprite
                    if MF_findsprite(v.sprite .. "_0_1.png", true) then
                        rootcheck = true
                    end
                    if MF_findsprite(v.sprite .. "_0_1.png", false) then
                        rootcheck = false
                    end
                    if MF_findsprite(string.rep("text_", num) .. v.sprite .. "_0_1.png", false) then
                        thissprite = string.rep("text_", num) .. v.sprite
                        rootcheck = false
                    end
                end
                local new = {
                    name = string.rep("text_", num) .. v.name,
                    sprite = thissprite,
                    sprite_in_root = rootcheck,
                    unittype = "text",
                    tags = { "text", "abstract", "metatext (" .. num .. ")" },
                    tiling = v.tiling,
                    type = 0,
                    layer = v.layer,
                    colour = v.colour,
                    colour_active = v.colour_active,
                }
                table.insert(meta_objs, new)
            end
        end
    end
end


for i, v in pairs(editor_objlist_order) do
    if string.sub(v, 1, 5) == "text_" then
        local data = editor_objlist_reference[v]
        if data ~= nil then
            v = editor_objlist[data]
            if v.type == 2 then
                local rootcheck = true
                local thissprite = nil
                if v.sprite == nil then v.sprite = v.name end
                if v.sprite ~= nil then
                    thissprite = v.sprite
                    if MF_findsprite(v.sprite .. "_0_1.png", true) then
                        rootcheck = true
                    end
                    if MF_findsprite(v.sprite .. "_0_1.png", false) then
                        rootcheck = false
                    end
                    if MF_findsprite(string.rep("text_c_", 1) .. string.gsub(v.sprite, "text_", "") .. "_0_1.png", false) then
                        thissprite = string.rep("text_c_", 1) .. string.gsub(v.sprite, "text_", "")
                        rootcheck = false
                    end
                end
                local new = {
                    name = string.rep("text_c_", 1) .. string.gsub(v.name, "text_", ""),
                    sprite = thissprite,
                    sprite_in_root = rootcheck,
                    unittype = "text",
                    tags = { "text", "abstract", "half text" },
                    tiling = -1,
                    type = 0,
                    layer = v.layer,
                    colour = v.colour,
                    colour_active = v.colour_active,
                }
                table.insert(c_objs, new)
            end
        end
    end
end

for i, v in pairs(editor_objlist_order) do
    if string.sub(v, 1, 5) == "text_" then
        local data = editor_objlist_reference[v]
        if data ~= nil then
            v = editor_objlist[data]
            if v.type == 2 then
                local thissprite = nil
                if v.sprite == nil then v.sprite = v.name end
                if v.sprite ~= nil then
                    thissprite = "tags_blankprop"
                    if MF_findsprite(string.rep("tags_", 1) .. string.gsub(v.sprite, "text_", "") .. "_0_1.png", false) then
                        thissprite = string.rep("tags_", 1) .. string.gsub(v.sprite, "text_", "")
                    end
                end
                local new = {
                    name = string.rep("tags_", 1) .. string.gsub(v.name, "text_", ""),
                    sprite = thissprite,
                    sprite_in_root = false,
                    unittype = "object",
                    tags = { "abstract", "tag objects" },
                    tiling = -1,
                    type = 0,
                    layer = v.layer,
                    colour = v.colour_active,
                }
                table.insert(tag_objs, new)
            end
        end
    end
end

for i, v in ipairs(c_objs) do
    table.insert(editor_objlist_order, v.name)
    editor_objlist[v.name] = v
end

for i, v in ipairs(tag_objs) do
    table.insert(editor_objlist_order, v.name)
    editor_objlist[v.name] = v
end

for i, v in ipairs(meta_objs) do
    table.insert(editor_objlist_order, v.name)
    editor_objlist[v.name] = v
end

formatobjlist()
