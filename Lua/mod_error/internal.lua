table.insert(editor_objlist_order, "edge")
table.insert(editor_objlist_order, "text_edge")
table.insert(editor_objlist_order, "text_become")
table.insert(editor_objlist_order, "text_never")
table.insert(editor_objlist_order, "crasher")
table.insert(editor_objlist_order, "text_crasher")
table.insert(editor_objlist_order, "text_error")
table.insert(editor_objlist_order, "text_default")
table.insert(editor_objlist_order, "text_hold")
--table.insert(editor_objlist_order, "error")

editor_objlist["text_become"] = 
{
	name = "text_become",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 1,
	layer = 20,
	colour = {0, 1},
	colour_active = {0, 3},
}

editor_objlist["text_never"] = 
{
	name = "text_never",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 3,
	layer = 20,
	colour = {2, 1},
	colour_active = {2, 2},
}

editor_objlist["text_crasher"] = 
{
	name = "text_crasher",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","danger"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {2, 1},
	colour_active = {2, 2},
}


editor_objlist["text_error"] = 
{
	name = "text_error",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","danger"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {2, 1},
	colour_active = {2, 2},
}

editor_objlist["text_edge"] = 
{
	name = "text_edge",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","danger"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {2, 1},
	colour_active = {2, 2},
}

editor_objlist["text_default"] = 
{
	name = "text_default",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text","danger"},
	tiling = -1,
	type = 0,
	layer = 20,
	colour = {2, 1},
	colour_active = {2, 2},
}

editor_objlist["crasher"] = 
{
	name = "crasher",
	sprite_in_root = false,
	unittype = "object",
	tags = {"danger"},
	tiling = -1,
	type = 0,
	layer = 30,
	colour = {0, 3},
}

editor_objlist["edge"] = 
{
	name = "edge",
	sprite_in_root = false,
	unittype = "object",
	tags = {"danger"},
	tiling = -1,
	type = 0,
	layer = 0,
	colour = {1, 0},
}

editor_objlist["text_hold"] =
{
	name = "text_hold",
	sprite_in_root = false,
	unittype = "text",
	tags = {"text"},
	tiling = -1,
	type = 2,
	layer = 20,
	colour = {2, 1},
	colour_active = {2, 2},
}

formatobjlist()