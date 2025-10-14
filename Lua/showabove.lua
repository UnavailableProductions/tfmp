function cursorcheck()
    return 1
end
local old_mctf = mapcursor_tofront
function mapcursor_tofront()
  old_mctf()
  for i, unit in ipairs(getunitswitheffect("showabove")) do
    unit.moveToFront()
  end
end

table.insert(editor_objlist_order, "text_showabove")
editor_objlist["text_showabove"] = 
{
	name = "text_showabove",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","abstract"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {1, 2},
	colour_active = {1, 4},
}