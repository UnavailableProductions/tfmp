local str = debug.getinfo(1).source:sub(2)
local pf_lua_dir = str:match("(.*/)")
local dir = pf_lua_dir

local load_order = {
    "load_first",
    "merged",
	"mod_isin",
	"mod_spring",
	"mod_error",
	"mod_extrem",
    "mod_glitch",
	"mod_glyph",
	"mod_local",
	"mod_metatext",
	"mod_nuhuh",
	"mod_offset",
	"mod_past",
	"mod_patashu",
	"mod_persist",
	"mod_plasma",
	"mod_stringwords",
	"mod_visit",
	"mod_word_salad",
	"mod_delete",
	"mod_stick",
    "load_last",
	"mod_scripts"
}

for _, folder in ipairs(load_order) do
    print("[Mega Modpack] ---- Loading folder "..folder.."/!loadmod.lua")
    dofile(dir..folder.."/!loadmod.lua")
end