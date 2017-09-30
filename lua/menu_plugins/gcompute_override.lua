require "roc"

hook.Add("RunOnClient","GComputeOverride",function(path,code)
    if path:match("autorun/gcompute.lua$") then
        return [[
            -- will only work on sv_allowcslua 1 servers
            include "autorun/gcomputex.lua"
        ]]
    end
end)
