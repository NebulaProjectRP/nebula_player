NebulaPlayer = {}

AddCSLuaFile("nebulaplayer/sh_meta.lua")
include("nebulaplayer/sh_meta.lua")

for k, v in pairs(file.Find("nebulaplayer/modules/*.lua", "LUA")) do
    if (string.StartWith(v, "sh_")) then
        AddCSLuaFile("nebulaplayer/modules/" .. v)
        include("nebulaplayer/modules/" .. v)
    elseif (string.StartWith(v, "sv_")) then
        if SERVER then
            include("nebulaplayer/modules/" .. v)
        end
    elseif (string.StartWith(v, "cl_")) then
        if CLIENT then
            include("nebulaplayer/modules/" .. v)
        else
            AddCSLuaFile("nebulaplayer/modules/" .. v)
        end
    else
        ErrorNoHalt("Attempting to load uknown file type: " .. v .. "\n")
    end
end

MsgC(Color(255, 238, 0), "[Player Modules]", color_white, " Loaded!\n")