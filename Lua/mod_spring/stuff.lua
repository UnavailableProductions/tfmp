local kekcheck = 0
local dskcheck = 26
MF_loadsound("vineboom")
local screenrotate = 0
local screenoffset = 0
MF_loadsound("error72")
MF_loadsound("whatisevenhappening")
MF_loadsound("uncharged1")
MF_loadsound("uncharged2")
MF_loadsound("uncharged3")
table.insert(mod_hook_functions["effect_always"],
	function()
		if hasfeature("thing","is","keith",1) then
			MF_levelrotation((math.sin(((screenrotate*0.1)/11))*3)+screenoffset*0.1)
			screenrotate = screenrotate + 2
			if (screenrotate % math.random(1,90) == 0) then
				screenoffset =  screenoffset + math.random(-50,50)
			end
		end
		if hasfeature("thing","is","green",1) then
			if (math.random(0,4) == 1) then
				generaldata.values[SHAKE] = 3
			end
			if (math.random(0,7) == 1) then
				generaldata.values[SHAKE] = 4
			end
			if (math.random(0,1) == 1) then
				MF_levelrotation((math.sin(math.random(0,60)*0.1)))
			end
			if (math.random(0,4) == 1) then
				MF_levelrotation((math.cos(math.random(0,60)*0.1)))
			end
			if (math.random(0,100) == 1) then
				MF_playsound("error72")
			end
		end	
		if hasfeature("blob","is","orange",1) then
			if (math.random(0,12) == 1) then
				MF_playsound("error72")
			end
			if (math.random(0,12) == 1) then
				MF_playsound("whatisevenhappening")
			end
		end
		if hasfeature("thing","is","nothing",1) then
			if hasfeature("nothing","is","real",1) then
				error("test \nspring",1)
			end
		end
		if hasfeature("thing","is","keke",1) then
 			if unitlists["flag"] ~= nil then
				if kekcheck == 1 then
    				if #unitlists["flag"] == 0 then
            				MF_playsound("vineboom")
					kekcheck = 0
				end
    				end
   			end 
		end
		if hasfeature("thing","is","boom",1) then
			if dskcheck == 26 then
				MF_win()
				dskcheck = 25
			elseif dskcheck > 0 then
				dskcheck = dskcheck - 1
			else
				error()
			end
		end
		if hasfeature("thing","is","crash",1) then
			MF_levelrotation((math.sin(((screenrotate*0.1)/11))*3)+screenoffset*0.1)
			screenrotate = screenrotate + 2
			if (screenrotate % math.random(1,90) == 0) then
				screenoffset =  screenoffset + math.random(-50,50)
			end
		end
	end
)

MF_loadsound("oopsallbroken")

table.insert(mod_hook_functions["turn_end"],
	function()
		if hasfeature("thing","is","fish",1) then
			if hasfeature("all","is","fish",1) then
				error("Data/fish.lua:32767: bad argument #1 to 'fish' (number expected, got fish)\nCheck the gas station for more fish.",999)
			end
			if hasfeature("belt","is","fish",1) then
				error("Data/fish.lua:32767: belt argument #1 to 'fish' (error expected, got fish)\nCheck the gas station for more fish.",999)
			end
			if hasfeature("belt","is","shit",1) then
				error("poopoo",999)
			end
		end
		if hasfeature("thing","is","keke",1) then
			kekcheck = 1
		end		
		if hasfeature("thing","play","a",1) then
			MF_playsound("uncharged1")
		end
		if hasfeature("thing","play","b",1) then
			MF_playsound("uncharged2")
		end	
		if hasfeature("thing","play","c",1) then
			MF_playsound("uncharged3")
		end		
		if hasfeature("blob","is","power4",1) then
			MF_playsound("oopsallbroken")
			--error("Data/load.lua:345: bad argument #1 to 'new' (IT WORKED, got nil)\nCheck crash.txt for more info.",1)
		end	
	end
)

function music_random()
	local temp = math.random(1,11)
	if (temp == 1) then
		return "baba"
	elseif (temp == 2) then
		return "crystal"	
	elseif (temp == 3) then
		return "factory"
	elseif (temp == 4) then
		return "stars"
	elseif (temp == 5) then
		return "garden"
	elseif (temp == 6) then
		return "rain"
	elseif (temp == 7) then
		return "float"
	elseif (temp == 8) then
		return "space"
	elseif (temp == 9) then
		return "ruin"
	elseif (temp == 10) then
		return "empty"
	else
		return "editorsong"
	end
end

MF_setfile("level","operation sand.txt")
MF_store("level","CODE","(","")

