MF_setfile("save",tostring(generaldata2.values[SAVESLOT]) .. "ba.ba")
local winTimes = tonumber(MF_read("save", "watercooler", "winamt")) or 0
table.insert(mod_hook_functions["level_win"],
    function()
        local level = generaldata.strings[CURRLEVEL]
    if level == "1169level" then
            winTimes = winTimes + 1
            if winTimes <= 19 then
                MF_store("save", "watercooler", "winamt", winTimes)
            else
                error()
            end
	elseif level == "671level" then
            winTimes = winTimes + 1
            if winTimes <= 39 then
                MF_store("save", "watercooler", "winamt", winTimes)
            else
                error()
            end
    elseif level == "1283level" then
            winTimes = winTimes + 1
            if winTimes <= 59 then
                MF_store("save", "watercooler", "winamt", winTimes)
            else
                error()
            end
	elseif level == "2level" then
		winTimes = 0 
		MF_store("save", "watercooler", "winamt", winTimes)
        end
    end
)
table.insert(mod_hook_functions["level_start"],
function()
    local level = generaldata.strings[CURRLEVEL]
    if winTimes >= 58 then
        if level == "1283level" then
            MF_store("save",generaldata.strings[WORLD],"watercoolerfinal","1")
        end
        if level == "matthew" then
            MF_store("save",generaldata.strings[WORLD],"matthewgaming","1")
        end
    end
end
)
table.insert(mod_hook_functions["turn_end"],
function()
    local level = generaldata.strings[CURRLEVEL]
    if level == "1338level" then
        local levlist1 = {"cri1level","cri2level","cri3level","cri4level"}
        leveltransition_change(levlist1[math.random(1, #levlist1)] ,0,0)
    end
    if level == "1339level" then
        local levlist1 = {"cri5level","cri6level","cri7level","cri8level"}
        leveltransition_change(levlist1[math.random(1, #levlist1)] ,0,0)
    end
end
)