local SHOW_BOXES = false
CCSprites = {}

function donutz_loadsprite(name,bank,x,y,thebool,stick)
    local sprite_id = MF_create("customsprite")
    local sprite = mmf.newObject(sprite_id)

    sprite.values[ONLINE] = 1
    sprite.layer = 2
    sprite.direction = bank
    sprite.values[ZLAYER] = 23
    MF_loadsprite(sprite_id,name,bank,thebool)
    MF_setcolour(sprite_id,5,2)

    --timedmessage(tostring(spritedata.values[TILEMULT]))

    local totalzoom = (generaldata2.values[ZOOM] * spritedata.values[TILEMULT])

    local objunit = mmf.newObject(stick)
    sprite.x = tonumber(objunit.x)
    sprite.y = tonumber(objunit.y)

    --timedmessage(tostring(objunit.values[XPOS]))
    sprite.values[XPOS] = objunit.x
    sprite.values[YPOS] = objunit.y
    sprite.scaleX = totalzoom
    sprite.scaleY = totalzoom

    table.insert(CCSprites, {sprite_id,stick})
end

function resetsprites()
    for i,v in ipairs(CCSprites) do
        MF_cleanremove(v[1])
    end
    CCSprites = {}

    if SHOW_BOXES then
        for i,unit in ipairs(units) do
            local x,y = unit.values[XPOS],unit.values[YPOS]

            donutz_loadsprite("gridsquare_0", 26, x, y, true, unit.fixed)
        end
    end
end

function updatesprites()
    for i,v in ipairs(CCSprites) do
        local objunit = mmf.newObject(v[2])
        local sprite = mmf.newObject(v[1])
        --sprite.x = objunit.x
        --sprite.y = objunit.y

        local totalzoom = (generaldata2.values[ZOOM] * spritedata.values[TILEMULT])
    
        --timedmessage(tostring(objunit.values[XPOS]))
        sprite.values[XPOS] = objunit.x
        sprite.values[YPOS] = objunit.y
        sprite.scaleX = totalzoom
        sprite.scaleY = totalzoom
    end
end


table.insert(mod_hook_functions["level_start"], 
    function()
        CCSprites = {}
        if MF_read("settings","settings","boxes") == "1" then
            SHOW_BOXES = true
        end

        resetsprites()
    end
)
table.insert(mod_hook_functions["turn_end"], resetsprites)
table.insert(mod_hook_functions["undoed_after"], resetsprites)

table.insert(mod_hook_functions["always"],
    function()
        if (SHOW_BOXES) and (generaldata.values[MODE] == 0) then
            updatesprites()
        end
    end
)
buttonclick_list["boxes"] = function(unitid)
    local boxtoggle = MF_read("settings","settings","boxes")
    local newvalue = nil

    if boxtoggle == "1" then
        newvalue = "0"
        SHOW_BOXES = false
    else
        newvalue = "1"
        SHOW_BOXES = true
    end
    MF_store("settings","settings","boxes",newvalue)
    updatebuttoncolour(unitid,newvalue)

    MF_playsound("good")
    resetsprites()
end


menufuncs.settings = {
    button = "SettingsButton",
    enter = 
        function(parent,name,buttonid)
            local x = screenw * 0.5
            local y = 1.5 * f_tilesize
            
            local disable = MF_unfinished()
            local build = generaldata.strings[BUILD]
            
            local extrasize = 0
            local sliderxoffset = 0
            local slideryoffset = 0
            local delaytext = "settings_repeat"
            
            if (build ~= "m") then
                writetext(langtext("settings_colon"),0,x,y,name,true,2,true)
                y = y + f_tilesize * 2
            else
                extrasize = f_tilesize * 1.5
                sliderxoffset = 0 - f_tilesize * 4
                slideryoffset = 0 - f_tilesize * 0.6
                delaytext = "settings_repeat_m"
            end
            
            x = screenw * 0.5 - f_tilesize * 1
            
            writetext(langtext("settings_music"),0,x - f_tilesize * 11.5 + sliderxoffset,y + slideryoffset,name,false,2,true)
            local mvolume = MF_read("settings","settings","music")
            slider("music",x + f_tilesize * 5 + sliderxoffset * 1.5,y + slideryoffset,8,{1,3},{1,4},buttonid,0,100,tonumber(mvolume))
            
            y = y + f_tilesize + extrasize * 0.5
            
            writetext(langtext("settings_sound"),0,x - f_tilesize * 11.5 + sliderxoffset,y + slideryoffset,name,false,2,true)
            local svolume = MF_read("settings","settings","sound")
            slider("sound",x + f_tilesize * 5 + sliderxoffset * 1.5,y + slideryoffset,8,{1,3},{1,4},buttonid,0,100,tonumber(svolume))
            
            y = y + f_tilesize + extrasize * 0.5
            
            writetext(langtext(delaytext),0,x - f_tilesize * 11.5 + sliderxoffset,y + slideryoffset,name,false,2,true)
            local delay = MF_read("settings","settings","delay")
            slider("delay",x + f_tilesize * 5 + sliderxoffset * 1.5,y + slideryoffset,8,{1,3},{1,4},buttonid,7,20,tonumber(delay))
            
            x = screenw * 0.5
            y = y + f_tilesize * 2 + extrasize
            
            local s,c,icon = 0,{0,3},""
            
            if (build ~= "m") then
                createbutton("language",x,y,2,18,1,langtext("settings_language"),name,3,2,buttonid)
            
                y = y + f_tilesize
            end
            
            if (build ~= "n") and (build ~= "m") then
                createbutton("controls",x,y,2,18,1,langtext("controls"),name,3,2,buttonid)
            
                y = y + f_tilesize
            
                local fullscreen = MF_read("settings","settings","fullscreen")
                s,c = gettoggle(fullscreen)
                createbutton("fullscreen",x,y,2,18,1,langtext("settings_fullscreen"),name,3,2,buttonid,nil,s)
                
                y = y + f_tilesize
            end
            
            local grid = MF_read("settings","settings","grid")
            s,c,icon = gettoggle(grid,{"m_settings_grid_no","m_settings_grid"})
            
            if (build ~= "m") then
                createbutton("grid",x,y,2,18,1,langtext("settings_grid"),name,3,2,buttonid,nil,s)
            else
                createbutton("grid",x - f_tilesize * 12.5,y,2,4,4,"",name,3,2,buttonid,nil,nil,nil,bicons[icon])
            end

            local boxes = MF_read("settings","settings","boxes")
            s,c,icon = gettoggle(boxes,{"m_settings_grid_no","m_settings_grid"})
            
            if (build ~= "m") then
                createbutton("boxes",x+(f_tilesize*12),y,2,6,1,"show boxes",name,3,2,buttonid,nil,s)
                
                y = y + f_tilesize + extrasize
            else
                y = y - f_tilesize * 0.5
                createbutton("boxes",x - f_tilesize * 12.5,y,2,4,4,"",name,3,2,buttonid,nil,nil,nil,bicons[icon])
            end
            
            local wobble = MF_read("settings","settings","wobble")
            s,c,icon = gettoggle(wobble,{"m_settings_wobble","m_settings_wobble_no"})
            
            if (build ~= "m") then
                createbutton("wobble",x,y,2,18,1,langtext("settings_wobble"),name,3,2,buttonid,nil,s)
                
                y = y + f_tilesize + extrasize
            else
                createbutton("wobble",x - f_tilesize * 7.5,y,2,4,4,"",name,3,2,buttonid,nil,nil,nil,bicons[icon])
            end
            
            local particles = MF_read("settings","settings","particles")
            s,c,icon = gettoggle(particles,{"m_settings_particles","m_settings_particles_no"})
            
            if (build ~= "m") then
                createbutton("particles",x,y,2,18,1,langtext("settings_particles"),name,3,2,buttonid,nil,s)
            else
                createbutton("particles",x - f_tilesize * 2.5,y,2,4,4,"",name,3,2,buttonid,nil,nil,nil,bicons[icon])
            end
            
            if (build == "m") then
                createbutton("language",x + f_tilesize * 2.5,y,2,4,4,"",name,3,2,buttonid,nil,nil,nil,bicons.m_settings_language)
                
                local hand = MF_read("settings","settings","m_hand")
                s,c,icon = gettoggle(hand,{"m_settings_hand_right","m_settings_hand_left"})
                
                createbutton("hand",x + f_tilesize * 7.5,y,2,4,4,"",name,3,2,buttonid,nil,nil,nil,bicons[icon])
                
                local pointers = MF_read("settings","settings","m_pointers")
                s,c,icon = gettoggle(pointers,{"m_settings_pointers_on","m_settings_pointers_off"})
                
                createbutton("pointers",x + f_tilesize * 12.5,y,2,4,4,"",name,3,2,buttonid,nil,nil,nil,bicons[icon])
            
                y = y + f_tilesize
            end
            
            local shake = MF_read("settings","settings","shake")
            s,c,icon = gettoggle(shake)
            
            y = y + f_tilesize + extrasize
            
            if (build ~= "m") then
                createbutton("shake",x,y,2,18,1,langtext("settings_shake"),name,3,2,buttonid,nil,s)
            else
                createbutton("shake",x,y,2,32,2,langtext("settings_shake"),name,3,2,buttonid,nil,s)
            end
            
            y = y + f_tilesize + extrasize * 0.9
            
            local contrast = MF_read("settings","settings","contrast")
            s,c = gettoggle(contrast)
            
            if (build ~= "m") then
                createbutton("contrast",x,y,2,18,1,langtext("settings_palette"),name,3,2,buttonid,nil,s)
            else
                createbutton("contrast",x,y,2,32,2,langtext("settings_palette"),name,3,2,buttonid,nil,s)
                
                --y = y + f_tilesize * 0.1
            end
            
            y = y + f_tilesize + extrasize * 0.9
            
            local blinking = MF_read("settings","settings","blinking")
            s,c = gettoggle(blinking)
            
            if (build ~= "m") then
                createbutton("blinking",x,y,2,18,1,langtext("settings_blinking"),name,3,2,buttonid,nil,s)
                
                y = y + f_tilesize + extrasize * 0.9
            end
            
            local restartask = MF_read("settings","settings","restartask")
            s,c = gettoggle(restartask)
            
            if (build ~= "m") then
                createbutton("restartask",x,y,2,18,1,langtext("settings_restart"),name,3,2,buttonid,nil,s)
            else
                createbutton("restartask",x,y,2,32,2,langtext("settings_restart"),name,3,2,buttonid,nil,s)
                
                --y = y + f_tilesize * 0.1
            end
            
            y = y + f_tilesize + extrasize * 0.9
            
            --[[
            local zoom = MF_read("settings","settings","zoom")
            s,c = gettoggle(zoom)
            createbutton("zoom",x,y,2,16,1,langtext("settings_zoom"),name,3,2,buttonid,nil,s)
            ]]--
            
            if (build ~= "m") then
                writetext(langtext("settings_zoom"),0,x - f_tilesize * 15.5,y,name,false,2,true)
                
                local zoom = tonumber(MF_read("settings","settings","zoom")) or 0
                createbutton("zoom1",x - f_tilesize * 4.5,y,2,7,1,langtext("zoom1"),name,3,2,buttonid,nil)
                createbutton("zoom2",x + f_tilesize * 3.5,y,2,7,1,langtext("zoom2"),name,3,2,buttonid,nil)
                createbutton("zoom3",x + f_tilesize * 11.5,y,2,7,1,langtext("zoom3"),name,3,2,buttonid,nil)
                
                makeselection({"zoom2","zoom1","zoom3"},tonumber(zoom) + 1)
                
                y = y + f_tilesize
            end
            
            if (build == "n") and (1 == 0) then
                local disablestick = generaldata5.values[DISABLESTICK] + 1
                createbutton("disable_stick",x,y,2,18,1,langtext("controls_disablestick"),name,3,2,buttonid)
                makeselection({"","disable_stick"},disablestick)
                
                y = y + f_tilesize
            end
            
            if (build ~= "m") then
                createbutton("return",x,y,2,18,1,langtext("return"),name,3,2,buttonid)
            else
                createbutton("return",x,y,2,24,2,langtext("return"),name,3,2,buttonid)
            end
        end,
    structure =
    {
        {
            {{"music",-392},},
            {{"sound",-392},},
            {{"delay",-392},},
            {{"language"},},
            {{"controls"},},
            {{"fullscreen"},},
            {{"grid"},{"boxes"}},
            {{"wobble"},},
            {{"particles"},},
            {{"shake"},},
            {{"contrast"},},
            {{"blinking"},},
            {{"restartask"},},
            {{"zoom1"},{"zoom2"},{"zoom3"},},
            {{"return"},},
        },
        n = {
            {{"music",-392},},
            {{"sound",-392},},
            {{"delay",-392},},
            {{"language"},},
            {{"grid"},{"boxes"}},
            {{"wobble"},},
            {{"particles"},},
            {{"shake"},},
            {{"contrast"},},
            {{"blinking"},},
            {{"restartask"},},
            {{"zoom1"},{"zoom2"},{"zoom3"},},
            -- {{"disable_stick"},},
            {{"return"},},
        },
        m = {
            {{"music",-340},},
            {{"sound",-340},},
            {{"delay",-340},},
            {{"grid"},{"wobble"},{"particles"},{"language"},{"hand"},{"pointers"},},
            {{"shake"}},
            {{"contrast"}},
            {{"restartask"},},
            {{"return"},},
        },
    }
}