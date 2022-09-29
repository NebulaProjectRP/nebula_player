NebulaEternals = NebulaEternals or {
    Data = {},
    Local = {}
}

ETERNAL_BERSERKER = 1
ETERNAL_ECONOMY = 2
ETERNAL_RESOURCES = 3
ETERNAL_ADDICT = 4

local meta = FindMetaTable("Player")

function meta:getEternals()
    return SERVER and self._eternals or NebulaEternals.Local
end

function NebulaEternals:Register(id, data)
    self.Data[id] = data
end

AddCSLuaFile("eternals/berserker.lua")
AddCSLuaFile("eternals/economic.lua")
AddCSLuaFile("eternals/resources.lua")
include("eternals/berserker.lua")
include("eternals/economic.lua")
include("eternals/resources.lua")

net.Receive("NebulaEternals.Sync", function()
    local id = net.ReadString()
    local progress = net.ReadUInt(32)
    local level = net.ReadUInt(16)

    NebulaEternals.Local[id] = {
        progress = progress,
        level = level
    }
end)