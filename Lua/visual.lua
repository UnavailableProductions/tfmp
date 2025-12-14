particletypes.soot =
{
	amount = 250,
	animation = 1,
	colour = {0, 0},
	extra = 
		function(unitid)
			local unit = mmf.newObject(unitid)
			
			unit.values[XVEL] = math.random(-1,1) * 0.5
			unit.values[YVEL] = math.random(-3,-1)
			
			local rand = (math.random(8,18) * 0.05)
			unit.scaleX = rand
			unit.scaleY = rand
		end,
}
