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
	elseif level == "2level" then
		winTimes = 0 
		MF_store("save", "watercooler", "winamt", winTimes)
        end
    end
)
