if SERVER or
   file.Exists ("gcomputex/gcompute.lua", "LUA") or
   file.Exists ("gcomputex/gcompute.lua", "LCL") and GetConVar ("sv_allowcslua"):GetBool () then
	include ("gcomputex/gcompute.lua")
end