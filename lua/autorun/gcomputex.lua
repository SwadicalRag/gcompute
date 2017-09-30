local __rtl = include("__rtl.lua")
debug.getregistry().__rtl = __rtl

galileo = __rtl.package.require ("../galileo/lua/init")

if SERVER or
   file.Exists ("gcomputex/gcompute.lua", "LUA") or
   file.Exists ("gcomputex/gcompute.lua", "LCL") and GetConVar ("sv_allowcslua"):GetBool () then
	include ("gcomputex/gcompute.lua")
end