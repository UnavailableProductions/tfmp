function formletterunits(x,y,lettermap,dir,database_)
	local dr = dirs[dir]
	local ox,oy = dr[1],dr[2]
	local cx,cy = x,y
	
	local jumble = {}
	local jumblecombo = {}
	local totalcombos = 1
	local done = false
	
	local database = database_
	
	while (done == false) do
		local tileid = cx + cy * roomsizex
		
		if (lettermap[tileid] ~= nil) then
			table.insert(jumble, {})
			local cjumble = jumble[#jumble]
			
			for i,v in ipairs(lettermap[tileid]) do
				table.insert(cjumble, {v[1], v[2]})
			end
			
			table.insert(jumblecombo, 0)
			totalcombos = totalcombos * #cjumble
			
			cx = cx + ox
			cy = cy + oy
		else
			done = true
		end
	end
	
	local been_seen = {}
	
	if (#jumble > 0) then
		for j=1,totalcombos do
			local word = ""
			local subword = ""
			local prevword = ""
			local prevwordid = 0
			local wordids = {}
			local branches = {}
			local offset = 0
			local updatecombo = true
			local row2 = ""
			local row1 = ""
			local maxletter = #jumble
			local subrow2 = ""
			
			for i,cjumble in ipairs(jumble) do
				--babaprint(i)
				local ccombo = jumblecombo[i] + 1
				local cword = cjumble[ccombo]
				local currlet = ""
				local lethasrow2 = false
				local commafound = false
				local insertfound = false
				cword[1] = cword[1]:gsub( "comma", ",")
				cword[1] = cword[1]:gsub( "insert_mrl", "&")
				
				for l=1,#cword[1],1 do
					if (string.sub(cword[1], l, l) == "§") then
						lethasrow2 = true
						row1 = string.sub(cword[1], 1, l-1)
						row1 = row1:gsub( "§", "")
						row2 = row2 .. string.sub(cword[1], l)
						row2 = row2:gsub( "§", "")
						row1 = row1:gsub( ",", "")
						row2 = row2:gsub( ",", "")
						--babaprint("_ found")
						word = word .. row1
					elseif (string.sub(cword[1], l, l) == ",") then
						commafound = true
						word = word:gsub( ",", "")
						row1 = row1:gsub( ",", "")
						row2 = row2:gsub( ",", "")
					elseif (string.sub(cword[1], l, l) == "&") then
						insertfound = true
						word = word:gsub( "&", "")
						row1 = row1:gsub( "&", "")
						row2 = row2:gsub( "&", "")
					end
				end

				if (lethasrow2 == false) then
					word = word .. cword[1]
				end
				if insertfound then
					word = word:gsub( "&", "")
					row1 = row1:gsub( "&", "")
					row2 = row2:gsub( "&", "")
					word = word .. row2
				end
				if commafound or (i == maxletter) then
					word = word:gsub( ",", "")
					row1 = row1:gsub( ",", "")
					row2 = row2:gsub( ",", "")
					word = word .. row2
				end

				if (i > 1) then
					if lethasrow2 then
						subword = prevword .. row1
					else
						subword = prevword .. cword[1]
					end
					if insertfound then
						subword = subword:gsub( "&", "")
						row1 = row1:gsub( "&", "")
						row2 = row2:gsub( "&", "")
						subword = subword .. subrow2
					end
					if commafound or (i == maxletter) then
						subword = subword:gsub( ",", "")
						row1 = row1:gsub( ",", "")
						row2 = row2:gsub( ",", "")
						subword = subword .. subrow2
						subrow2 = ""
					end
				end
				
				if updatecombo then
					jumblecombo[i] = jumblecombo[i] + 1
					
					if (jumblecombo[i] >= #cjumble) then
						jumblecombo[i] = 0
						updatecombo = true
					else
						updatecombo = false
					end
				end


				--babaprint(word .. ", " .. i-1 .. ", " .. subword)
				local found,fullwords,partwords = findletterwords(word,i - 1,subword)
				
				for a,b in ipairs(partwords) do
					table.insert(branches, {prevword, i - 2, false, {prevwordid}})
				end
				
				if lethasrow2 then
					prevword = row1
				else
					prevword = cword[1]
				end
				if insertfound then
					prevword = prevword:gsub( "&", "")
					row1 = row1:gsub( "&", "")
					row2 = row2:gsub( "&", "")
					prevword = prevword .. row2
				end
				if commafound or (i == maxletter) then
					prevword = prevword:gsub( ",", "")
					row1 = row1:gsub( ",", "")
					row2 = row2:gsub( ",", "")
					prevword = prevword .. row2
				end
				prevwordid = cword[2]
				
				--babaprint(tostring(j) .. " Currently " .. word .. ", " .. subword .. ", " .. prevword .. ", " .. tostring(dir))
				
				for a,b in ipairs(branches) do
					local w = b[1]
					local pos = b[2]
					local dead = b[3]
					local wids = b[4]
					
					--babaprint(b[1])
					if lethasrow2 then
						w = w .. row1
					else
						w = w .. cword[1]
					end

					if insertfound then
						w = w:gsub( "&", "")
						row1 = row1:gsub( "&", "")
						row2 = row2:gsub( "&", "")
						w = w .. row2
					end
					if commafound or (i == maxletter) then
						w = w:gsub( ",", "")
						row1 = row1:gsub( ",", "")
						row2 = row2:gsub( ",", "")
						w = w .. row2
					end
					b[1] = w

					table.insert(b[4], cword[2])
					
					if (dead == false) then
						local sfound,sfullwords = findletterwords(w,i - 1,nil,false)
						
						if (sfound == false) then
							b[3] = true
							
							if (#b[4] > 0) then
								table.remove(b[4], #b[4])
							end
						else
							if (#sfullwords > 0) then
								for c,d in ipairs(sfullwords) do
									local w = d[1]
									local t = d[2]
									local wordcode = w .. tostring(pos)
									
									local fwids = {}
									for c,d in ipairs(b[4]) do
										table.insert(fwids, d)
									end
									
									if (been_seen[wordcode] == nil) then
										been_seen[wordcode] = 1
										
										table.insert(database, {w, t, x + ox * pos, y + oy * pos, dir, #fwids, fwids})
									end
								end
							end
						end
					end
				end
				
				if (found == false) then
					if (string.len(word) > 0) and (#wordids > 0) then
						word = string.sub(word, -1)
						
						local wid = wordids[#wordids]
						wordids = {wid}
						
						offset = i - 1
					end
				else
					if (#fullwords > 0) then
						for a,b in ipairs(fullwords) do
							--babaprint(b[1] .. b[2] .. b[3])
							local w = b[1]
							local t = b[2]
							local pos = b[3]
							local fulloffset = offset + pos
							local wordcode = w .. tostring(fulloffset)
							
							local fwids = {}
							for c,d in ipairs(wordids) do
								table.insert(fwids, d)
							end
							
							if (been_seen[wordcode] == nil) then
								been_seen[wordcode] = 1
								
								--MF_alert("Adding to database: " .. w .. ", " .. tostring(dir) .. ", " .. wordcode)
								table.insert(database, {w, t, x + ox * fulloffset, y + oy * fulloffset, dir, #fwids, fwids})
							end
						end
					end
				end
				if commafound or insertfound then
					subrow2 = row2
				end
				if commafound then
					row2 = ""
				end
			end
		end
	end

	return database
end