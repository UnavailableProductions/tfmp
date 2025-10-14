keys.IS_WORD_GLOSSARY_PRESENT = true
keys.WORD_GLOSSARY_VERSION = "2.1"

local word_glossary_credit = string.format("$0,1Word Glossary Mod V%s - by Plasmaflare", keys.WORD_GLOSSARY_VERSION)

local TEXT_TYPE_MAPPING = {
    [0] = "noun",
    [1] = "verb",
    [2] = "property",
    [3] = "prefix condition",
    [4] = "not",
    [5] = "letter",
    [6] = "and",
    [7] = "infix condition",
}

local DISPLAY_CONFIG = {
    [1] = {
        scale = 5,
        offsets = {{0,0}}
    },
    [2] = {
        scale = 3,
        offsets = {{-1.5,-1.5}, {1.5,1.5}}
    },
    [3] = {
        scale = 3,
        offsets = {{-1.5,-1.8}, {2,0}, {-1.5,1.8}}
    },
    [4] = {
        scale = 2.5,
        offsets = {{-1.5,-1.5}, {1.5, -1.5}, {-1.5, 1.5}, {1.5, 1.5}}
    },
    [5] = {
        scale = 2,
        offsets = {{0,0}, {-2,-2}, {2,2}, {2, -2}, {-2,2}}
    },
    [9] = 16,
    [10] = 16,
    [11] = 16,
    [12] = 16,
    [13] = 16,
    [14] = 16,
    [15] = 16,
    [16] = {
        scale = 1,
        offsets = {
            {-2.5,-2},    {-0.83,-2},    {0.83,-2},    {2.5, -2},
            {-2.5,-0.33}, {-0.83,-0.33}, {0.83,-0.33}, {2.5, -0.33},
            {-2.5,1.33},  {-0.83,1.33},  {0.83,1.33},  {2.5, 1.33},
            {-2.5,3},     {-0.83,3},     {0.83,3},     {2.5, 3},
        }
    },
}

local BABA_FONT_CONSTS = {
    letter_w = 8,
    letter_h = 24,
    letter_spacing = 2,
    total_letter_w = 10,
    button_w = 24,
}

local FIELDS_TO_CHECK_IF_NO_BASE_OBJ = {"text_type", "thumbnail", "display_name"}

local DISPLAY_X = 4.25
local DISPLAY_Y = 5
local TEXT_DISPLAY_X_OFFSET1 = f_tilesize * 8.50
local TEXT_DISPLAY_X_OFFSET = TEXT_DISPLAY_X_OFFSET1 + f_tilesize * 7.75
local NAME_DISPLAY_LINE_LEN = 17
local MAX_LINES = 8
local MAX_LINE_LEN = 40
local MAX_COLS = 16
local MAX_ROWS = 4
local MAX_ITEMS = MAX_COLS * MAX_ROWS
local GLOSSARY_PREFIX = "_glossary_"
local LETTERCLEAR_TYPE = "glossary_info"
local DESC_CLEAR_TYPE = "glossary_desc"
local BUTTONID = "WordGlossary"

local min_page = 1
local max_page = 1 -- will be set in compile_word_glossary()
local obj_display_units = {}
local curr_entry_index = nil
local curr_page = 1
local start_line_index = 0
local scrollup_button_unitid = nil
local scrolldown_button_unitid = nil

local compile_word_entry

local word_glossary = {}
local authors = {}
local custom_text_types = {}

keys.WORD_GLOSSARY_FUNCS = {
    add_entries_to_word_glossary = function(entries)
        for _, entry in ipairs(entries) do
            table.insert(word_glossary, entry)
            entry_index = #word_glossary
            compile_word_entry(entry)
        end

        max_page = math.floor(#word_glossary / MAX_ITEMS)
        if #word_glossary % MAX_ITEMS ~= 0 then
            max_page = max_page + 1
        end
    end,

    register_author = function(author, color, custom_display)
        color = color or {0,3}
        if custom_display ~= nil then
            authors[author] = custom_display
        else
            authors[author] = "$"..color[1]..","..color[2]..author
        end
    end,

    register_custom_text_type = function(text_type, display)
        custom_text_types[text_type] = display
    end,
}

local function clear_display_units()
    if #obj_display_units > 0 then
        for _, unit in ipairs(obj_display_units) do
            MF_cleanremove(unit)
        end
    end
    obj_display_units = {}
end

local function make_plasma_button(buttonfunc, name, buttonid, label, x, y, selected, tooltip, icon)
    local width = (#label + 4) * BABA_FONT_CONSTS.total_letter_w
    local scale = width / BABA_FONT_CONSTS.button_w
    local final_x = x + width / 2
    local button = createbutton(buttonfunc,final_x,y,2,scale,1,label,name,3,2,buttonid, nil, selected, tooltip, icon)
end

local old_currobjlist_func = menufuncs.currobjlist.enter
menufuncs.currobjlist.enter = function(...)
    old_currobjlist_func(...)

    local buttonstring = "Word Glossary"
    local x = screenw-( (#buttonstring + 5) * BABA_FONT_CONSTS.total_letter_w)
    local y = f_tilesize * 14

    createbutton("word_glossary", screenw - f_tilesize * 5, f_tilesize * 14, 2, 8,1, buttonstring, "currobjlist",3,2, menufuncs.currobjlist.button)
end

local function get_text_ref(name)
    local text_ref_index = editor_objlist_reference[name]
    if text_ref_index == nil then
        return nil
    end
    return editor_objlist[text_ref_index]
end

--[[
    This function is for a specific case where if base_obj is unset, certain other fields
    defined in FIELDS_TO_CHECK_IF_NO_BASE_OBJ have to be set. If this check fails, it raises
    a detailed error message for the user.
]]
local function check_required_fields_on_unset_base_obj(entry)
    local unset_fields = nil
    for _, field in ipairs(FIELDS_TO_CHECK_IF_NO_BASE_OBJ) do
        if entry[field] == nil and (field ~= "text_type" or entry["custom_type"] == nil) then
            if unset_fields == nil then
                unset_fields = '"'..field..'"'
            else
                unset_fields = unset_fields..',"'..field..'"'
            end

            if field == "text_type" then
                unset_fields = unset_fields.." or \"custom_type\""
            end
        end
    end

    if unset_fields ~= nil then
        local entry_str = "{"
        local kv_count = 0
        for k,v in pairs(entry) do
            if type(v) == "table" then
                v = "<table>"
            end
            entry_str = entry_str..string.format("\n    %s: %s", k, v)

            kv_count = kv_count + 1
            if kv_count > 10 then
                -- Just to avoid flooding the error window
                entry_str = entry_str.."\n    ..."
                break
            end
        end
        entry_str = entry_str.."\n}"

        local err_msg = string.format([[
(Word Glossary Error): Found a word entry with "base_obj" unset and missing fields. Either set "base_obj" or fill in the missing fields.

The missing fields are: %s

The word entry is:
%s
]], unset_fields, entry_str)

        error(err_msg)
    end
end

-- local
function compile_word_entry(entry)
    if entry.base_obj == nil then
        if entry.thumbnail_obj ~= nil then
            entry.base_obj = entry.thumbnail_obj
        elseif entry.name ~= nil then
            entry.base_obj = "text_"..entry.name
        else
            check_required_fields_on_unset_base_obj(entry)
        end
    end

    -- If display is not defined, make it <entry.name>
    if entry.display_name == nil then
        entry.display_name = entry.base_obj
    end

    truncate_text_prefix_in_display_name = entry.truncate_text_prefix_in_display_name or true

    -- Special case for handling when the display_name has "text_". Made it an option in case you want to display metatext
    if truncate_text_prefix_in_display_name then
        while string.sub(entry.display_name, 1,5) == "text_" do
            entry.display_name = string.sub(entry.display_name, 6, string.len(entry.display_name))
        end
    end

    if entry.thumbnail == nil then
        if entry.thumbnail_obj ~= nil then
            entry.thumbnail = entry.thumbnail_obj
        else
            entry.thumbnail = entry.base_obj
        end
    end

    -- If no description was provided, provide a placeholder text
    if entry.description == nil or entry.description == "" then
        entry.description = "(No description was found)"
    end

    -- by default, display the base object
    if entry.display_sprites == nil then
        
        entry.display_sprites = {entry.base_obj}
    end

    -- Compile entry.description to entry.desc_lines. Splits the description to list of lines, implementing word wrapping
    local desc_lines = {}
    local last_line_index = 1
    local last_space_index = nil
    local num_ignore_chars = 0

    -- These two vars are for the sole purpose of appending the color code to a new line if the color code isn't yellow
    local curr_color = "$0,3"
    local color_to_insert_to_front = ""

    local i = 1
    local entry_description = entry.description
    while i <= #entry_description do
        local char = string.sub(entry_description, i, i)

        if char == "\t" then
            -- Handle tabs not being handled from rendering text by replacing the character with a space
            entry_description = string.sub(entry_description, 1, i-1).." "..string.sub(entry_description, i+1, #entry_description)
            char = " "
        end

        --[[ 
            Baba special syntax reference:
            - $ handles color codes.
                - Format: "$<X>,<Y>" where X and Y are numbers in pallete grid.
                - Ex: $0,3 refers to what is typically white in most palettes
            - @ handles special control icon sprites (i.e controller or keyboard buttons).
                - Format: "@<control icon name>".
                - There isn't a complete reference for the control icon names, but you can find examples of it littered in Data/Languages/lang_en.txt
            - # handles lang texts, or showing different words based on the current language selected.
                - Format: "#<lang text key>"
                - Ex: "#pause_returnmap" gives you "Return to map" in lang_en.txt if selected english, or "paluu kartalle" in lang_fi.txt if selected finnish
        ]]
        if char == "$" then
            local data = string.sub(entry_description, i, i+3)
            local first_char = string.sub(data,2,2)
            local second_char = string.sub(data,3,3)
            local third_char = string.sub(data,4,4)

            if tonumber(first_char) ~= nil and second_char == "," and tonumber(third_char) ~= nil then
                i = i + 3
                num_ignore_chars = num_ignore_chars + 4
                curr_color = data
                goto continue
            end
        elseif char == "@" then
            -- Determine how many characters to ignore when considering word wrapping
            local forward_index = i + 1
            while forward_index <= #entry_description do
                local forward_char = entry_description:sub(forward_index, forward_index)
                if forward_char == " " or forward_char == ":" or forward_char == "\n" then
                    break
                else
                    forward_index = forward_index + 1
                end
            end

            num_ignore_chars = num_ignore_chars + (forward_index - i - 1)
            goto continue
        elseif char == "#" then
            local forward_index = i + 1
            while forward_index <= #entry_description do
                local forward_char = entry_description:sub(forward_index, forward_index)
                if forward_char == " " or forward_char == "\n" then
                    break
                else
                    forward_index = forward_index + 1
                end
            end

            local command = entry_description:sub(i + 1, forward_index - 1)
            local lang = langtext(command)

            entry_description = entry_description:sub(1, i-1)..lang..entry_description:sub(i + #command + 1, #entry_description)

            goto continue_no_incriment
        end

        if char == " " or char == "\n" then
            last_space_index = i
        end

        do -- Make a new scope so that goto continue calls don't jump into new local variable's scope
            local lines = {}
            if i - last_line_index - num_ignore_chars >= MAX_LINE_LEN then
                if last_space_index == nil then
                    -- Skip characters until we meet another space or end of string
                    last_space_index = i
                    while i < #entry_description do
                        char = string.sub(entry_description, i, i)
                        if char == " " or char == "\n" then
                            break
                        end 
                        i = i + 1
                        last_space_index = i
                    end
                end
    
                table.insert(lines, color_to_insert_to_front..string.sub(entry_description, last_line_index, last_space_index - 1))
                color_to_insert_to_front = ""

                num_ignore_chars = 0
                last_line_index = last_space_index + 1
                last_space_index = last_line_index

                if curr_color ~= "$0,3" then
                    color_to_insert_to_front = curr_color
                end
            end
            if i == #entry_description then
                if char == "\n" then
                    table.insert(lines, color_to_insert_to_front..string.sub(entry_description, last_line_index, #entry_description - 1))
                    color_to_insert_to_front = ""
                    last_line_index = #entry_description + 1

                    if curr_color ~= "$0,3" then
                        color_to_insert_to_front = curr_color
                    end
                else
                    table.insert(lines, color_to_insert_to_front..string.sub(entry_description, last_line_index, #entry_description))
                    color_to_insert_to_front = ""
                    last_line_index = #entry_description + 1

                    if curr_color ~= "$0,3" then
                        color_to_insert_to_front = curr_color
                    end
                end
            elseif char == "\n" then
                table.insert(lines, color_to_insert_to_front..string.sub(entry_description, last_line_index, i - 1))
                color_to_insert_to_front = ""
                last_line_index = i + 1
                last_space_index = last_line_index

                if curr_color ~= "$0,3" then
                    color_to_insert_to_front = curr_color
                end
            end
    
            if #lines > 0 then
                for _, line in ipairs(lines) do
                    table.insert(desc_lines, line)
                end
            end
        end

        ::continue::

        i = i + 1
        ::continue_no_incriment::
    end

    entry.desc_lines = desc_lines
end

local function display_description(entry_index, start_line)
    if entry_index == nil then
        return
    end

    MF_letterclear(DESC_CLEAR_TYPE)
    MF_clearcontrolicons(0)

    local word_entry = word_glossary[entry_index]
    local i = start_line

    local line_num = 1
    while i <= #word_entry.desc_lines and i < start_line + MAX_LINES do
        writetext(word_entry.desc_lines[i], -1, TEXT_DISPLAY_X_OFFSET, f_tilesize * (line_num + 0.5), DESC_CLEAR_TYPE)
        i = i + 1
        line_num = line_num + 1
    end

    local scrollup_disabled = start_line <= 1
    local scrolldown_disabled = start_line + MAX_LINES > #word_entry.desc_lines

    if scrollup_button_unitid then
        local button = mmf.newObject(scrollup_button_unitid)
        if scrollup_disabled then
            button.values[BUTTON_DISABLED] = 1
        else
            button.values[BUTTON_DISABLED] = 0
            MF_setcolour(scrollup_button_unitid, 3,2) -- Apparently 
        end
    end
    if scrolldown_button_unitid then
        local button = mmf.newObject(scrolldown_button_unitid)
        if start_line + MAX_LINES > #word_entry.desc_lines then
            button.values[BUTTON_DISABLED] = 1
        else
            button.values[BUTTON_DISABLED] = 0
            MF_setcolour(scrolldown_button_unitid, 3,2)
        end
    end

    local max_line_page = math.max(#word_entry.desc_lines - MAX_LINES  + 1, 1)
    local line_page_display = "("..start_line.."/"..max_line_page..")"
    writetext(line_page_display, -1, screenw - gettextwidth(line_page_display) - f_tilesize * 0.5, f_tilesize * 9.4, DESC_CLEAR_TYPE)
end

local NAME_Y = 2
local NAME_MARGIN = 1.5
local VALUE_MARGIN = 0.85
local FIELD_MARGIN = 1.23

local function display_word_info(entry_index)
    if entry_index == curr_entry_index then
        return
    end

    local err_msg = nil

    MF_letterclear(LETTERCLEAR_TYPE)
    
    local word_entry = word_glossary[entry_index]

    local yOffset = NAME_Y

    print(#word_entry.display_name)
    if #word_entry.display_name <= NAME_DISPLAY_LINE_LEN then
        writetext(word_entry.display_name, -1, TEXT_DISPLAY_X_OFFSET1, f_tilesize * yOffset, LETTERCLEAR_TYPE)
    else
        -- This whole block deals with an edge case where the display name is long enough to touch the description.
        local breakpoint = NAME_DISPLAY_LINE_LEN + 1

        while breakpoint >= 1 do
            local char = word_entry.display_name:sub(breakpoint,breakpoint)
            if char == " " then -- Try to make a newline at a space if possible
                break
            end

            breakpoint = breakpoint - 1
        end

        local add_hyphen = false
        if breakpoint == 0 then
            breakpoint = NAME_DISPLAY_LINE_LEN
            add_hyphen = true -- If cannot make a newline, use a hyphen to break a word
        end

        if add_hyphen then
            writetext(word_entry.display_name:sub(1, breakpoint).."-", -1, TEXT_DISPLAY_X_OFFSET1, f_tilesize * (yOffset - 0.50), LETTERCLEAR_TYPE)
        else
            writetext(word_entry.display_name:sub(1, breakpoint), -1, TEXT_DISPLAY_X_OFFSET1, f_tilesize * (yOffset - 0.50), LETTERCLEAR_TYPE)
        end

        writetext(word_entry.display_name:sub(breakpoint + 1), -1, TEXT_DISPLAY_X_OFFSET1, f_tilesize * (yOffset + 0.25), LETTERCLEAR_TYPE)
    end
    

    yOffset = yOffset + NAME_MARGIN/2

    -- Separator
    for xOff = 8.5, 15.3, 0.2 do
        writetext("$3,2-", -1, f_tilesize * xOff, f_tilesize * yOffset, LETTERCLEAR_TYPE)
    end

    yOffset = yOffset + NAME_MARGIN/2

    -- Determine the value to show under "Type:"
    local text_type_desc
    if word_entry.custom_type then
        text_type_desc = word_entry.custom_type
    else
        local get_text_type = nil
        if word_entry.text_type then -- If user specifies a word type, honor their request
            get_text_type = word_entry.text_type
        else
            local text_ref = get_text_ref(word_entry.base_obj)

            if text_ref == nil then
                if word_entry.base_obj == nil then
                    err_msg = "error: Specify base_obj or a text/object type for this entry."
                else
                    err_msg = "error: \""..tostring(word_entry.base_obj).."\" is not registered in objlist"
                end
            else
                if text_ref.unittype ~= "text" then
                    text_type_desc = "object"
                else
                    get_text_type = text_ref.type
                end
            end
        end

        if get_text_type then
            text_type_desc = custom_text_types[get_text_type] or TEXT_TYPE_MAPPING[get_text_type] or "other ("..get_text_type..")"
        end
    end

    if text_type_desc then
        writetext("$0,2Type:$0,3 ", -1, TEXT_DISPLAY_X_OFFSET1, f_tilesize * yOffset, LETTERCLEAR_TYPE)
        yOffset = yOffset + VALUE_MARGIN
        writetext(text_type_desc, -1, TEXT_DISPLAY_X_OFFSET1, f_tilesize * yOffset, LETTERCLEAR_TYPE)
    else
        yOffset = yOffset + VALUE_MARGIN
    end

    yOffset = yOffset + FIELD_MARGIN


    local author_text = authors[word_entry.author] or word_entry.author or "N/A"

    writetext("$0,2Author:$0,3", -1, TEXT_DISPLAY_X_OFFSET1, f_tilesize * yOffset, LETTERCLEAR_TYPE)
    yOffset = yOffset + VALUE_MARGIN

    writetext(author_text, -1, TEXT_DISPLAY_X_OFFSET1, f_tilesize * yOffset, LETTERCLEAR_TYPE)
    yOffset = yOffset + FIELD_MARGIN


    if word_entry.group then
        writetext("$0,2Part of:$0,3", -1, TEXT_DISPLAY_X_OFFSET1, f_tilesize * yOffset, LETTERCLEAR_TYPE)
        yOffset = yOffset + VALUE_MARGIN
    
        writetext(word_entry.group, -1, TEXT_DISPLAY_X_OFFSET1, f_tilesize * yOffset, LETTERCLEAR_TYPE)
        yOffset = yOffset + FIELD_MARGIN
    end

    -- Write the description
    start_line_index = 1
    display_description(entry_index, start_line_index)

    clear_display_units()
    local display_sprites = word_entry.display_sprites

    local num_sprites_to_display = #display_sprites
    while DISPLAY_CONFIG[num_sprites_to_display] == nil and num_sprites_to_display > 0 do
        num_sprites_to_display = num_sprites_to_display - 1
    end

    -- If the display config is a number, treat it as a redirect to the appropriate config
    local display_config = DISPLAY_CONFIG[num_sprites_to_display]
    if type(display_config) == "number" then
        display_config = DISPLAY_CONFIG[display_config]
    end

    local scale = display_config.scale

    for i = 1, num_sprites_to_display do
        local sprite_name
        local sprite_in_root
        local color

        if type(display_sprites[i]) == "table" then
            sprite_name = display_sprites[i].sprite
            sprite_in_root = display_sprites[i].sprite_in_root
            color = display_sprites[i].colour or display_sprites[i].color or {0,3}
        else
            -- 
            sprite_name = display_sprites[i]

            local sprite_ref = get_text_ref(sprite_name)
            if sprite_ref == nil then
                sprite_name = "error_0"
                sprite_in_root = true
                color = {0,3}
            else
                sprite_name = sprite_name.."_0"
                if sprite_ref.sprite ~= nil then
                    -- Special case where the text ref has a specified sprite
                    sprite_name = sprite_ref.sprite.."_0"
                end
                color = sprite_ref.colour_active or sprite_ref.colour
    
                if sprite_ref.sprite_in_root == nil then
                    sprite_in_root = true
                else    
                    sprite_in_root = sprite_ref.sprite_in_root
                end
            end
        end

        local display_unit = MF_specialcreate("customsprite")

        local offset = display_config.offsets[i]

        MF_loadsprite(display_unit,sprite_name,i, not sprite_in_root)
        MF_setcolour(display_unit, color[1], color[2])
        local unit = mmf.newObject(display_unit)
        unit.values[XPOS] = f_tilesize * (DISPLAY_X + offset[1])
        unit.values[YPOS] = f_tilesize * (DISPLAY_Y + offset[2])
        unit.scaleX = scale
        unit.scaleY = scale
        unit.direction = i
        unit.layer = 2
        unit.visible = true
        unit.values[ONLINE] = 1

        table.insert(obj_display_units, display_unit)
    end

    curr_entry_index = entry_index

    if err_msg then
        writetext(err_msg, -1, f_tilesize * 0.5, f_tilesize * 9.4, LETTERCLEAR_TYPE)
    end
end

local old_buttonclicked = buttonclicked
function buttonclicked(name,unitid)
    if generaldata.values[MODE] == 5 and string.sub(name, 1, #GLOSSARY_PREFIX) == GLOSSARY_PREFIX then
        local entry_index = tonumber(string.sub(name, #GLOSSARY_PREFIX+1))
        display_word_info(entry_index)
    end
    old_buttonclicked(name,unitid)
end

buttonclick_list["word_glossary"] = function()
    changemenu("word_glossary")
end
buttonclick_list["word_glossary_return"] = function()
    MF_letterclear(LETTERCLEAR_TYPE)
    MF_letterclear(DESC_CLEAR_TYPE)
    clear_display_units()
    changemenu("currobjlist")
    curr_entry_index = nil
end
buttonclick_list["word_glossary_random"] = function()
    if #word_glossary == 0 then
        return
    end

    local entry_index = math.random(1, #word_glossary)
    display_word_info(entry_index)
end
buttonclick_list["word_glossary_next_page"] = function()
    curr_page = curr_page + 1
    changemenu("word_glossary", curr_page)

    display_description(curr_entry_index, start_line_index)
end
buttonclick_list["word_glossary_prev_page"] = function()
    curr_page = curr_page - 1
    changemenu("word_glossary", curr_page)

    display_description(curr_entry_index, start_line_index)
end
buttonclick_list["word_glossary_scrollup"] = function()
    start_line_index = start_line_index - 1
    display_description(curr_entry_index, start_line_index)
end
buttonclick_list["word_glossary_scrolldown"] = function()
    start_line_index = start_line_index + 1
    display_description(curr_entry_index, start_line_index)
end

menufuncs.word_glossary = {
    button = BUTTONID,
    escbutton = "word_glossary_return",
    enter = function(parent,name,buttonid,extra)
        local dynamic_structure = {}
        MF_clearthumbnails(BUTTONID)

        writetext(word_glossary_credit, -1, screenw - gettextwidth(word_glossary_credit) - f_tilesize * 0.1, f_tilesize * 0.45, name)

        if #word_glossary == 0 then
            local msg = "No glossary entries were initialized for this level/levelpack."
            writetext(msg, -1, screenw/2 - gettextwidth(msg)/2, screenh/2, name)
        end

        if extra == nil or curr_page == nil then
            curr_page = 1
        end

        local disable_scrollup = start_line_index <= 1
        local disable_scrolldown = true
        if curr_entry_index and word_glossary[curr_entry_index] then
            disable_scrolldown = start_line_index + MAX_LINES >= #word_glossary[curr_entry_index].desc_lines
        end

        scrollup_button_unitid = createbutton("word_glossary_scrollup",screenw - f_tilesize * 1.3,f_tilesize * 4,2,1.5,1.5,"",name,3,2,buttonid, disable_scrollup, false, nil, bicons.u_arrow)
        scrolldown_button_unitid = createbutton("word_glossary_scrolldown",screenw - f_tilesize * 1.3,f_tilesize * 6,2,1.5,1.5,"",name,3,2,buttonid, disable_scrolldown, false, nil, bicons.d_arrow)

        local start_index = (MAX_ITEMS * (curr_page - 1)) + 1
        local end_index = start_index + MAX_ITEMS -1
        local x = 1
        local y = 1

        local dynamic_structure_row = {}
        local has_errored = false
        for entry_index = start_index, end_index do
            if entry_index > #word_glossary then
                break
            end

            local entry = word_glossary[entry_index]

            local thumbnail_sprite = "error"
            local color = {0,3}
            local sprite_in_root = true

            if entry == nil then
                local msg = "Word Glossary Error: \""..tostring(entry_index).."\" is not defined in the word glossary"
                timedmessage(msg)
                print(msg)
                has_errored = true
            else
                if type(entry.thumbnail) == "table" then
                    thumbnail_sprite = entry.thumbnail.sprite
                    sprite_in_root = entry.thumbnail.sprite_in_root
                    color = entry.thumbnail.colour or entry.thumbnail.color or {0,3}
                else
                    thumbnail_sprite = entry.thumbnail

                    local text_ref = get_text_ref(thumbnail_sprite)
                    if text_ref == nil then
                        print("Word Glossary Error: \""..tostring(thumbnail_sprite).."\" is not a valid object.")
                        thumbnail_sprite = "error"
                        has_errored = true
                    else
                        color = text_ref.colour_active or text_ref.colour

                        if text_ref.sprite then
                            -- Special case where the text ref has a specified sprite
                            thumbnail_sprite = text_ref.sprite
                        end

                        sprite_in_root = text_ref.sprite_in_root
                    end
                end
            end

            local path = "Sprites/"
            if not sprite_in_root then
                local world = generaldata.strings[WORLD]
                path = "Worlds/" .. world .. "/Sprites/"
            end

            
            local buttonfunc = GLOSSARY_PREFIX..entry_index
            local button = createbutton_objlist(buttonfunc,(f_tilesize * 2) * (x + 0.35), (f_tilesize * 2) * (y + 4.4),
            "word_glossary_"..entry_index,3,2,BUTTONID,nil,false)
            MF_thumbnail(path,thumbnail_sprite.."_0_1",entry_index-1,0,0,button,color[1],color[2],0,0,BUTTONID,buttonfunc)
            
            table.insert(dynamic_structure_row, {buttonfunc,"cursor"})
            x = x + 1
            if x > MAX_COLS then
                y = y + 1
                x = 1

                table.insert(dynamic_structure, dynamic_structure_row)
                dynamic_structure_row = {}
            end
        end
        if #dynamic_structure_row > 0 then
            table.insert(dynamic_structure, dynamic_structure_row)
        end

        make_plasma_button("word_glossary_return", name, buttonid, langtext("return"), f_tilesize * 1.5, screenh - f_tilesize, false, "")
        createbutton("word_glossary_prev_page",screenw / 2 - f_tilesize * 5,screenh - f_tilesize * 1.25,2,2,2,"",name,3,2,buttonid, curr_page <= min_page, false, nil, bicons.l_arrow)
        createbutton("word_glossary_next_page",screenw / 2 + f_tilesize * 5,screenh - f_tilesize * 1.25,2,2,2,"",name,3,2,buttonid, curr_page >= max_page, false, nil, bicons.r_arrow)
        make_plasma_button("word_glossary_random", name, buttonid, "Random", screenw - f_tilesize * 5.5, screenh - f_tilesize, false, "")

        table.insert(dynamic_structure, 
            {
                {"word_glossary_return"}, 
                {"word_glossary_prev_page", "cursor"},
                {"word_glossary_next_page", "cursor"},
                {"word_glossary_random"}
            }
        )
        table.insert(dynamic_structure, {{"word_glossary_scrollup", "cursor"}})
        table.insert(dynamic_structure, {{"word_glossary_scrolldown", "cursor"}})

        writetext(langtext("editor_levellist_page") .. " " .. tostring(curr_page) .. "/" .. tostring(max_page),0,screenw * 0.5,screenh - f_tilesize * 1.25,name,true,2)
        
        buildmenustructure(dynamic_structure)
    end,
    leave = function(parent,name)
        MF_clearthumbnails(BUTTONID)
    end,
}