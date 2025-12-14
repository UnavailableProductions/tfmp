-- watercoolest
local timedlvls = {"271level","390level","389level","391level","395level","424level","401level","425level","500level","428level","1155level",
"548level","552level","522level","626level","613level","627level","629level","673level",
"73243level","73234level","1084level","1100level","1169level","1271level","1305level","1306level","1307level"} -- add level ids here to let the game know that these levels are timed
local normallvls = {} -- DO NOT ADD ANYTHING TO THIS. non-timed levels will automatically be added here with a value of "true". timed levels will have a value of "false".
local timermsglvls = {"1169level"}
local globtickerbase = 1
local globticker = 1
local longs = 0
local shorts = 0
timedlvls["271level"] = 150 -- put the level id of the new level in the [] like this
timedlvls["390level"] = 45
timedlvls["395level"] = 80
timedlvls["424level"] = 2
timedlvls["428level"] = 15
timedlvls["389level"] = -1
timedlvls["1155level"] = -1
timedlvls["401level"] = -1
timedlvls["391level"] = -1 -- each time you add a timed level, you need to add a line like this setting its time limit (in seconds)
timedlvls["425level"] = 230
timedlvls["500level"] = 86400
timedlvls["548level"] = 60
timedlvls["552level"] = 220
timedlvls["626level"] = 10
timedlvls["627level"] = 15
timedlvls["613level"] = -1
timedlvls["522level"] = -1
timedlvls["1155level"] = -1
timedlvls["629level"] = 50
timedlvls["673level"] = -1
timedlvls["73243level"] = 12
timedlvls["73234level"] = -1
timedlvls["1084level"] = -1
timedlvls["1100level"] = 35
timedlvls["1169level"] = 86400
timedlvls["1271level"] = -1
timedlvls["1305level"] = 5
timedlvls["1306level"] = 10
timedlvls["1307level"] = 5
timermsglvls["1169level"] = "buble"
local world = generaldata.strings[WORLD]
local path = "Data/Worlds/" .. world .. "/"
local levels_ = MF_filelist(path,"*.l")
-- local tlvl = {}
local timestring = "00:00"
local tempstring = "00:"
local minute = 0
local second = 0
local lastlevel = ""
local tlimit = -1
local tframe = 0
local taunts = {"TOO SLOW", "NUH UH", "WHOOPS!", "TRY AGAIN", "NEXT TIME?", "OOF", "THAT SUCKS", "OH NO", "WELP", "WOW", "GREAT JOB", "INCREDIBLE", "AMAZING WORK", "THE SUN RISES GREEN", "YOU KNOW WHAT THAT MEANS!","YOUR TAKING TOO LONG","YOUR TOO SLOW","buble","IT GETS PROGRESSIVELY HARDER AS IT CONTINUES","UwU",">w<","why.","why arent ya winning son","116.169.166.17","00:00","stick why do player lose","Chess Battle Advanced","the room demands flesh"}
-- a random taunt is chosen to be shown when the player runs out of time, add your own by putting it in this table as a string (add it multiple times to increase its chance of appearing)
local taunt = "" -- this is automatically set to the randomly chosen taunt, do not change it as it will do absolutely nothing (hopefully)

--[[ 

NOTES:

unlike the previous version of the code, the level the player is kicked out to upon running out of time is unchangeable.
the player will always be sent to the previous level, so you should always make timed levels entered from non-timed levels to avoid exploits.

if you want to change the ticking sound, i'll leave "SOUND HERE" comments showing where all references to the sound are.
change the sound name to the desired sound's filename (without the .ogg extension), or if you don't want to change the actual code, replace Sounds/Timer.ogg with your sound. it is case-sensitive!

the Time's Up sound can be changed in the same way. its name is TimeUp.ogg

i think that's all, so happy panicking! <3

--]]

for i=1,#levels_ do
	if timedlvls[i .. "level"] == nil then
		normallvls[i .. "level"] = true
	else
		normallvls[i .. "level"] = false
	end
end

table.insert(mod_hook_functions["level_start"],
    function()
		globticker = 1
		lastlevel = generaldata2.strings[PREVIOUSLEVEL]
		MF_loadsound("Timer") -- SOUND HERE
		MF_loadsound("toolong")
		MF_loadsound("TimeUp")
		MF_loadsound("Fish")
		taunt = taunts[math.floor(math.random(0, #taunts))]
        local level = generaldata.strings[CURRLEVEL]
		for i=1,#timedlvls do
			if level == timedlvls[i] then
				-- tlvl = timedlvls[i]
				tlimit = timedlvls[level]
				if tlimit == nil then
					tlimit = -1
				end
				-- local klvl = lastlevel
				minute = math.floor(tlimit / 60)
				second = tlimit - minute * 60
				if generaldata.strings[CURRLEVEL] == "1169level" then
					timestring = "buble"
				else
					if minute <= 9 then
						tempstring = "0" .. minute .. ":" -- 09:
					else
						tempstring = minute .. ":" -- 10:
					end
					if second <= 9 then
						timestring = tempstring .. "0" .. second -- 09:09
					else
						timestring = tempstring .. second -- 10:10
					end
				end
			else
				MF_letterclear("Timer")
			end
		end
		timedmessage(level .. "'s timelimit is " .. tlimit)
	end
)

table.insert(mod_hook_functions["effect_always"],
    function()
		longs = findallfeature(nil, "is", "long")
		shorts = findallfeature(nil, "is", "short")  
		globticker = globtickerbase
		for i=1,#longs do
			 globticker = globticker*0.5
		end
		for i=1,#shorts do
			 globticker = globticker*2
		end
		pauser = findallfeature(nil, "is", "pause")  
		if #pauser > 0 then
			globticker = 0
		end
        if tlimit ~= -1 and tlimit ~= nil and not normallvls[level] and generaldata.values[MODE] ~= 5 then
			if generaldata.strings[CURRLEVEL] ~= "1169level" then
				if minute <= 9 then
					tempstring = "0" .. minute .. ":"
				else
					tempstring = minute .. ":"
				end
				if second <= 9 then
					timestring = tempstring .. "0" .. second
				else
					timestring = tempstring .. second
				end
			else
				timestring = "buble"
			end
			if minute == 0 and second == 0 then
			timestring = taunt
			end
			tframe = tframe + globticker
			if tframe > 59 then
				if second ~= 0 then
					second = second - 1
					MF_playsound("Timer") -- SOUND HERE
				else
					if minute ~= 0 then
						minute = minute - 1
						second = 59
					else
						if taunt == "YOU KNOW WHAT THAT MEANS!" then
							MF_playsound("Fish")
						else
							if taunt == "YOUR TAKING TOO LONG" then
								MF_playsound("toolong")
							else
								MF_playsound("TimeUp")
							end
						end
						local crumblevels = {"552level", "1332level", "1333level","1334level","1335level","1336level","1337level","1338level","cri1level","cri2level","cri3level","cri4level","1139level","cri5level","cri6level","cri7level","cri8level"}
						for _, value in ipairs(crumblevels) do
    						if value == generaldata.strings[CURRLEVEL] then
        						lastlevel = "391level"
       							break
    						end
						end
						sublevel(lastlevel,0,0)
						generaldata.values[TRANSITIONREASON] = 9
						generaldata.values[IGNORE] = 1
						generaldata3.values[STOPTRANSITION] = 1
						generaldata2.values[UNLOCK] = 0
						generaldata2.values[UNLOCKTIMER] = 0
						MF_loop("transition",1)
						minute = -1
						second = -1
						tlimit = -1
					end
				end
			tframe = 0
			end
			MF_letterclear("Timer")
			if generaldata.strings[CURRLEVEL] ~= "1169level" then
				writetext("$2,2" .. timestring .. "$0,3", -1, (screenw * 0.5) - (#timestring * 3), (screenh * 0.1), "Timer")
			else
				writetext("$2,2" .. "buble" .. "$0,3", -1, (screenw * 0.5) - (#timestring * 3), (screenh * 0.1), "Timer")
			end
		else
			MF_letterclear("Timer")
			timestring = "00:00"
			tempstring = "00:"
			minute = -1
			second = -1
			tlimit = -1
		end
	end
)

table.insert(mod_hook_functions["level_end"],
    function()
		MF_letterclear("Timer")
		timestring = "00:00"
		tempstring = "00:"
		minute = -1
		second = -1
		tlimit = -1
	end
)
condlist["expired"] = function(params,checkedconds,checkedconds_,cdata)
   	if second == 0 and tlimit ~= -1 and minute == 0 then
	result = true
	else
	result = false
	end
	return result,checkedconds
end