-- add double row letters
table.insert(editor_objlist_order, "text_b$b")
table.insert(editor_objlist_order, "text_a$a")

-- add special symbols
table.insert(editor_objlist_order, "text_comma")
table.insert(editor_objlist_order, "text_insert_mrl")

-- define double row letters
editor_objlist["text_b$b"] = 
{
	name = "text_b$b",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","abstract"},
	tiling = -1,
	type = 5,
	layer = 20,
	colour = {4, 0},
	colour_active = {4, 1},
}
editor_objlist["text_a$a"] = 
{
	name = "text_a$a",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","abstract"},
	tiling = -1,
	type = 5,
	layer = 20,
	colour = {4, 0},
	colour_active = {4, 1},
}

-- define special symbols
editor_objlist["text_comma"] = 
{
	name = "text_comma",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","abstract"},
	tiling = -1,
	type = 5,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 3},
}
editor_objlist["text_insert_mrl"] = 
{
	name = "text_insert_mrl",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","abstract"},
	tiling = -1,
	type = 5,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 3},
}

formatobjlist()