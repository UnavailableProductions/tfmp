local msgtimer = 5
local msgframe = 0
local msgshown = false
local definitions = {"baba", "keke","icely","something","book","spring","sulsul","beepy","helichoper","stisti","shifty","devious","ember","noelle","iterate"}
definitions["baba"] = "that is a baba"
definitions["keke"] = "get keke'd lmao"
definitions["icely"] = "chess battle advanced"
definitions["something"] = "no shit sherlock"
definitions["book"] = "The Fitness Gram Pacer Test"
definitions["spring"] = "the one responsible for many hours of suffering trying to patch stuff"
definitions["sulsul"] = "made by spring"
definitions["beepy"] = "made by spring"
definitions["helichoper"] = "made by devious"
definitions["stisti"] = "made by ember"
definitions["shifty"] = "made by ember and spring"
definitions["devious"] = "The one who conceptualised many of the dumb ideas"
definitions["ember"] = "the main maker of this pack"
definitions["iterate"] = "project: iterate provided the effect layer_5 used in the crumbling, thanks anactualcat!!!!"
definitions["noelle"] = "significant other of ember and main coder and composer"
table.insert(mod_hook_functions["effect_always"],
	function()
		if (generaldata.strings[CURRLEVEL] == "503level") then
			if featureindex["something"] ~= nil and not msgshown then
				for k,v in pairs(definitions) do
					if hasfeature(k,"is","something",1) then 
						writetext(v, -1, screenw - ((9*#v)+(24*7)), screenh - 24*18, "lore")
						msgframe = msgframe + 1
					end
				end
			else
				MF_letterclear("lore")
				msgframe = 0
				msgtimer = 5
				msgshown = false
			end
			if msgframe >= 60 then
				if msgtimer <= 1 then
					msgtimer = msgtimer - 1
				else
					msgshown = true
				end
				msgframe = 0
			end
		end
	end
)
--[[
while true, do -- the comma here isn't needed, and neither is this while loop
	do_mod_hook("effect_always")
end
]]--