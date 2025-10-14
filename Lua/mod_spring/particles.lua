menudata_customscript.particleslist =
function(parent,name,buttonid)
local x = screenw * 0.5
local y = f_tilesize * 1.5

createbutton("return",x,y,2,16,1,langtext("return"),name,3,1,buttonid)

y = y + f_tilesize * 2

writetext(langtext("editor_particles_select"),0,x,y,name,true,2)

y = y + f_tilesize * 2

local world = generaldata.strings[WORLD]
local opts = {}

table.insert(opts, "none")

for i,v in pairs(particletypes) do
--if (i ~= "world") then
table.insert(opts, i)
--end
end

local count = 0
for i,v in pairs(opts) do
count = count + 1
end

if (count == 0) then
writetext(langtext("editor_particles_none"),0,x,y,name,true,2)
end

local dynamic_structure = {{{"return"}}}
local curr_dynamic_structure = {}

x = x - f_tilesize * 5
local x_ = 0
local y_ = 0

table.insert(dynamic_structure, {})
curr_dynamic_structure = dynamic_structure[#dynamic_structure]

local count_ = 0
for i,v in ipairs(opts) do
count_ = count_ + 1
local vname = langtext("particles_" .. v,true,true)
if (#vname == 0) then
vname = v
end

createbutton(v,x + x_ * f_tilesize * 10,y + y_ * f_tilesize,2,8,1,vname,name,3,2,buttonid)

table.insert(curr_dynamic_structure, {v})

x_ = x_ + 1

if (x_ > 1) and (count_ < count) then
x_ = 0
y_ = y_ + 1

table.insert(dynamic_structure, {})
curr_dynamic_structure = dynamic_structure[#dynamic_structure]
end
end

editor2.values[MENU_XPOS] = 0
editor2.values[MENU_YPOS] = 0
editor2.values[MENU_XDIM] = 1
editor2.values[MENU_YDIM] = math.floor(count / 2) + 1

buildmenustructure(dynamic_structure)
end


particletypes =
{
	bubbles =
	{
		amount = 30,
		animation = 0,
		colour = {1, 0},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.values[YVEL] = math.random(-3,-1)
				
				unit.scaleX = unit.values[YVEL] * -0.33
				unit.scaleY = unit.values[YVEL] * -0.33
			end,
	},
	soot =
	{
		amount = 30,
		animation = 1,
		colour = {0, 1},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.values[YVEL] = math.random(-3,-1)
				
				unit.scaleX = unit.values[YVEL] * -0.33
				unit.scaleY = unit.values[YVEL] * -0.33
			end,
	},
	sparks =
	{
		amount = 40,
		animation = 1,
		colour = {2, 3},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.values[YVEL] = math.random(-3,-1)
				
				unit.scaleX = unit.values[YVEL] * -0.23
				unit.scaleY = unit.values[YVEL] * -0.23
				
				local coloury = math.random(2,4)
				
				MF_setcolour(unitid,2,coloury)
				unit.strings[COLOUR] = tostring(2) .. "," .. tostring(coloury)
			end,
	},
	dust =
	{
		amount = 50,
		animation = 1,
		colour = {1, 0},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.values[YVEL] = math.random(-3,-1)
				
				unit.scaleX = unit.values[YVEL] * -0.33 * 1.1
				unit.scaleY = unit.values[YVEL] * -0.33 * 1.1
			end,
	},
	snow =
	{
		amount = 30,
		animation = 1,
		colour = {0, 3},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.values[XVEL] = math.random(-50,-10) * 0.1
				unit.values[YVEL] = math.abs(unit.values[XVEL]) * (math.random(5,15) * 0.1)
				
				unit.scaleX = math.abs(unit.values[XVEL]) * 0.2
				unit.scaleY = math.abs(unit.values[XVEL]) * 0.2
				unit.flags[INFRONT] = true
			end,
	},
	clouds =
	{
		amount = 90,
		animation = {2, 12},
		colour = {4, 3},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.scaleX = 1 + math.random(-30,30) * 0.01
				unit.scaleY = unit.scaleX * 0.9
				
				unit.values[YVEL] = 0 - unit.scaleX
				unit.values[XVEL] = 0 - unit.scaleX
			end,
	},
	smoke =
	{
		amount = 30,
		animation = 3,
		colour = {1, 0},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.angle = math.random(0,359)
				
				unit.scaleX = 1 + math.random(-30,30) * 0.01
				unit.scaleY = unit.scaleX
				
				unit.values[YVEL] = -1
				unit.values[DIR] = math.random(-25,25) * 0.05
			end,
	},
	pollen =
	{
		amount = 20,
		animation = 5,
		colour = {1, 0},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.values[XVEL] = math.random(-20,20) * 0.1
				unit.values[YVEL] = math.random(40,80) * 0.05
				
				local size = math.random(2,5)
				unit.scaleX = size * 0.2
				unit.scaleY = size * 0.2
			end,
	},
	stars =
	{
		amount = 40,
		animation = {6, 7},
		colour = {3, 2},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.values[XVEL] = ((unit.direction - 6) + math.random(0,5) * 0.1) + 0.05
				--unit.values[YVEL] = math.random(40,80) * 0.05
				
				if (unit.direction == 7) then
					MF_setcolour(unitid,1,3)
					
					unit.strings[COLOUR] = tostring(1) .. "," .. tostring(3)
				end
				
				local size = math.random(2,5)
				unit.scaleX = size * 0.2
				unit.scaleY = size * 0.2
			end,
	},
	glitter =
	{
		amount = 60,
		animation = 8,
		colour = {3, 1},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				if (math.random(1,4) == 1) then
					MF_setcolour(unitid,4,2)
					
					unit.strings[COLOUR] = tostring(4) .. "," .. tostring(1)
				end
				
				if (math.random(1,4) == 1) then
					MF_setcolour(unitid,0,3)
					
					unit.strings[COLOUR] = tostring(0) .. "," .. tostring(3)
				end
				
				local size = math.random(2,5)
				unit.scaleX = size * 0.2
				unit.scaleY = size * 0.2
			end,
	},
	leaves =
	{
		amount = 30,
		animation = {9, 10},
		colour = {6, 0},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				if (math.random(1,4) == 1) then
					MF_setcolour(unitid,6,3)
					
					unit.strings[COLOUR] = tostring(6) .. "," .. tostring(3)
				end
				
				local size = math.random(3,6)
				unit.scaleX = size * 0.2
				unit.scaleY = size * 0.2
				
				unit.values[XVEL] = math.random(-30,-10) * 0.1
				unit.values[YVEL] = math.random(0,10) * 0.05
			end,
	},
	rain =
	{
		amount = 50,
		animation = 11,
		colour = {3, 2},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				local size = math.random(3,5)
				unit.scaleX = size * 0.2
				unit.scaleY = size * 0.2
				
				unit.values[YVEL] = 80 + math.random(0,10) * 0.1
			end,
	},
	world =
	{
		amount = 40,
		animation = 13,
		colour = {4, 0},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				local scale = 0.2 + math.random(0,400) * 0.01
				
				unit.scaleX = scale
				unit.scaleY = scale
				
				unit.values[DIR] = ((math.random(0,1) * 2) - 1) * (2 - scale * 0.5)
			end,
	},
	hailstorm =
	{
		amount = 80,
		animation = 1,
		colour = {0, 3},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.values[XVEL] = math.random(-100,-50) * 1.5
				unit.values[YVEL] = math.abs(unit.values[XVEL]*2) * (math.random(5,15) * 0.03)
				
				local temp =  math.random(10,50)
				
				
				unit.flags[INFRONT] = true
				local grlevel = math.random(0,1)
				if (grlevel == 0) then
					unit.flags[INFRONT] = true
					unit.scaleX = temp * 0.05
					unit.scaleY = temp * 0.05
					unit.values[XVEL] = math.random(-100,-50) * 1.5
					unit.values[YVEL] = math.abs(unit.values[XVEL]*2) * (math.random(5,15) * 0.03)
				else
					unit.flags[INFRONT] = false
					unit.scaleX = temp * 0.02
					unit.scaleY = temp * 0.02
					unit.values[XVEL] = (math.random(-100,-50) * 1.5)*0.5
					unit.values[YVEL] = (math.abs(unit.values[XVEL]*2) * (math.random(5,15) * 0.03))*0.5
					MF_setcolour(unitid,0,1)
					unit.strings[COLOUR] = tostring(0) .. "," .. tostring(3)
				end
			end,
	},
	layer_5 =
	{
		amount = 95,
		animation = {2, 12, 9, 10, 1, 11},
		colour = {0, 0},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				local temp =  math.random(10,50)
				
				unit.scaleX = 1 + math.random(-30,30) * 0.01
				unit.scaleY = unit.scaleX * 0.9

				unit.values[YVEL] = 0 - unit.scaleX
				unit.values[XVEL] = 0 - unit.scaleX
				if (math.random(0,4) == 2) then
					temp =  math.random(1,90)
				end
				if (math.random(0,9) == 2) then
					unit.scaleX = temp * 0.05
					unit.scaleY = temp * 0.05
					unit.values[XVEL] = math.random(-70,-30) * 0.5
					unit.values[YVEL] = math.abs(unit.values[XVEL]) * (math.random(5,15) * 0.03)
				end
				if (math.random(0,3) == 2) then
					MF_setcolour(unitid,2,0)
					unit.strings[COLOUR] = tostring(2) .. "," .. tostring(0)
				end
				if (math.random(0,12) == 2) then
					unit.scaleX = unit.scaleX * 30
				end
				if (math.random(0,7) == 2) then
					local colorx = math.random(0,6)
					MF_setcolour(unitid,colorx,3)
					unit.strings[COLOUR] = tostring(colorx) .. "," .. tostring(3)
				end
				if (math.random(0,14) == 2) then
					unit.values[XVEL] = 0.1
				end
				if (math.random(0,10) == 4) then
					unit.flags[INFRONT] = true
				end
				if (math.random(0,5) == 4) then
					unit.angle = math.random(0,359)
				end
			end,
	},
	finalblossom =
	{
		amount = 10,
		animation = 13,
		colour = {4, 0},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				local scale = 0.2 + math.random(0,400) * 0.01
				
				unit.scaleX = scale
				unit.scaleY = scale
				unit.values[XVEL] = math.abs(((math.random(0,1) * 0.5) - 1) * (2 - scale * 0.5))
			end,
	},
	comets =
	{
		amount = 30,
		animation = {6,7},
		colour = {3, 2},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.values[XVEL] = math.random(300,600)*0.05
				unit.values[YVEL] = math.random(100,200) * (math.random(1,10)/100)
				unit.angle =  math.deg(math.atan(unit.values[XVEL]/unit.values[YVEL]))
				if (unit.direction == 7) then
					MF_setcolour(unitid,1,3)
               	     
					unit.strings[COLOUR] = tostring(1) .. "," .. tostring(3)
				end
				
				local size = math.random(1,3)
				unit.scaleX = size * 0.2
				unit.scaleY = size * 1
				unit.flags[INFRONT] = true
			end,
   	},
	stars2 =
	{
		amount = 160,
		animation = {6, 7},
		colour = {3, 2},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.values[XVEL] = (((unit.direction - 6) + math.random(0,5) * 0.1) + 0.05) * 2
				unit.values[YVEL] = ((math.random(100,200) * (math.random(1,10)/100)) / 10) * 2
				
				if (unit.direction == 7) then
					MF_setcolour(unitid,1,3)
					
					unit.strings[COLOUR] = tostring(1) .. "," .. tostring(3)
				end
				
				local rand = (math.random(8,18) * 0.35)
				local size = math.random(2,5)
				unit.scaleX = 0.2 * rand
				unit.scaleY = 0.2 * rand
			end,
	},
	void =
	{
		amount = 144,
		animation = 11,
		colour = {6, 4},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.values[YVEL] = math.random(-2,-1)
				unit.values[XVEL] = math.random(-15,15) * 0.01
				unit.angle = math.random(0,89)
				unit.scaleX = 8 * (unit.values[YVEL] * -0.3)
				unit.scaleY = unit.values[YVEL] * -0.3
			end,
	},
	paravoid =
	{
		amount = 132,
		animation = 11,
		colour = {0, 0},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				if math.random(1,2) == 2 then
					MF_setcolour(unitid,0,1)
						
					unit.strings[COLOUR] = "0,1"
				end
				local rand = (math.random(8,18) * 0.35)
				unit.values[YVEL] = math.random(-50,50) * 0.075
				unit.values[XVEL] = math.random(-50,50) * 0.075
				unit.scaleX = 1.6 * rand
				unit.scaleY = 0.2 * rand
				MF_setshader(unitid,"add")
			end,
	},
	crumble =
	{
		amount = 50,
		animation = {1, 3},
		colour = {1, 0},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.angle = math.random(0,359)
				
				unit.scaleX = 1 + math.random(-30,30) * 0.01
				unit.scaleY = unit.scaleX
				
				unit.values[YVEL] = 8
				unit.values[XVEL] = math.random(-5,5) * 0.25
				unit.values[DIR] = math.random(-25,25) * 0.05
			end,
	},
	supercrumble =
	{
		amount = 120,
		animation = {1, 3, 11, 6, 7},
		colour = {1, 0},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.angle = math.random(0,359)
				
				unit.scaleX = 1 + math.random(-30,30) * 0.01
				unit.scaleY = unit.scaleX
				
				unit.values[YVEL] = 40
				unit.values[XVEL] = math.random(-10,10) * 0.25
				unit.values[DIR] = math.random(-25,25) * 0.05
				unit.flags[INFRONT] = true
			end,
	},
	CherryBlossoms =
	{
		amount = 120,
			animation = 20,
			colour = {4, 2},
			extra = 
				function(unitid)
					local unit = mmf.newObject(unitid)
					
					unit.angle = math.random(0,359)
					
					unit.scaleX = 1 + math.random(-30,30) * 0.01
					unit.scaleY = unit.scaleX
					
					unit.values[YVEL] = 3
					unit.values[XVEL] = math.random(-10,10) * 0.25
					unit.values[DIR] = math.random(-25,25) * 0.05
					unit.flags[INFRONT] = false
				end,
	},
	snow2 =
	{
		amount = 120,
			animation = 6,
			colour = {0, 3},
			extra = 
				function(unitid)
					local unit = mmf.newObject(unitid)
					
					unit.angle = math.random(0,359)
					
					unit.values[YVEL] = 3
					unit.values[XVEL] = math.random(-10,10) * 0.25
					unit.values[DIR] = math.random(-25,25) * 0.05
					unit.flags[INFRONT] = true
				end,
	},
	Particle =
	{
		amount = 256,
		animation = 1,
		colour = {0, 0},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				
				unit.flags[INFRONT] = true
				
				if math.random(1,2) == 2 then
					MF_setcolour(unitid,1,2)
						
					unit.strings[COLOUR] = "1,3"
				end
				local rand = (math.random(8,18) * 0.35)
				unit.values[YVEL] = math.random(-10,10) * 0.075
				unit.values[XVEL] = math.random(-10,10) * 0.075
				
				unit.scaleX = 0.25
				unit.scaleY = 0.25
				
			end,
	},
	BigBubbles =
	{
		amount = 200,
		animation = 0,
		colour = {1, 0},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				local scale = 2.5 + math.random(0,400) * 0.01
				
				unit.scaleX = scale
				unit.scaleY = scale
				unit.values[XVEL] = math.abs(((math.random(0,1) * 0.5) - 1) * (2 - scale * 0.5))
				MF_setshader(unitid,"add")
			end,
	},
	sunrise =
	{
		amount = 95,
		animation = {-1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 20},
		colour = {0, 0},
		extra = 
			function(unitid)
				local unit = mmf.newObject(unitid)
				local temp =  math.random(10,50)
				
				unit.scaleX = 1 + math.random(-30,30) * 0.01
				unit.scaleY = unit.scaleX * 0.9

				unit.values[YVEL] = 0 - unit.scaleX
				unit.values[XVEL] = 0 - unit.scaleX
				if (math.random(0,4) == 2) then
					temp =  math.random(1,90)
				end
				if (math.random(0,9) == 2) then
					unit.scaleX = temp * 0.05
					unit.scaleY = temp * 0.05
					unit.values[XVEL] = math.random(-70,-30) * 0.5
					unit.values[YVEL] = math.abs(unit.values[XVEL]) * (math.random(5,15) * 0.03)
				end
				if (math.random(0,3) == 2) then
					MF_setcolour(unitid,2,0)
					unit.strings[COLOUR] = tostring(2) .. "," .. tostring(0)
				end
				if (math.random(0,12) == 2) then
					unit.scaleX = unit.scaleX * 30
				end
				if (math.random(0,7) == 2) then
					local colorx = math.random(0,6)
					MF_setcolour(unitid,colorx,3)
					unit.strings[COLOUR] = tostring(colorx) .. "," .. tostring(3)
				end
				if (math.random(0,14) == 2) then
					unit.values[XVEL] = 0.1
				end
				if (math.random(0,10) == 4) then
					unit.flags[INFRONT] = true
				end
				if (math.random(0,5) == 4) then
					unit.angle = math.random(0,359)
				end
			end,
	},
	sandstorm =
	{
	amount = 512,
	animation = 1,
	colour = {6, 2},
	extra = 
		function(unitid)
			local unit = mmf.newObject(unitid)
			
			unit.values[XVEL] = math.random(-80,-40) * -0.5
			unit.values[YVEL] = math.random(5,15) * 0.2
				
			unit.scaleX = math.abs(unit.values[XVEL]) * 0.025
			unit.scaleY = math.abs(unit.values[XVEL]) * 0.025
			unit.flags[INFRONT] = true
		end,
	},
	coloursmoke = 
	{
	amount = 30,
	animation = 3,
	colour = {1, 0},
	extra = 
		function(unitid)
			local unit = mmf.newObject(unitid)
			
			unit.angle = math.random(0,359)
			
			unit.scaleX = 1 + math.random(-30,30) * 0.01
			unit.scaleY = unit.scaleX
			
			unit.values[YVEL] = -1
			unit.values[DIR] = math.random(-25,25) * 0.05

			local coloury1 = (math.random(0,1) * 2) + 1
			local coloury2 = math.random(0,1)
			MF_setcolour(unitid,coloury1,coloury2)
			unit.strings[COLOUR] = tostring(coloury1) .. "," .. tostring(coloury2)
		end,
	},
}