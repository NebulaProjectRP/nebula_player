local meta = FindMetaTable("Player")

function meta:getLevel()
    return (self.levelSystem or {}).level or 1
end

function meta:getXP()
    return (self.levelSystem or {}).experience or 1
end

function NebulaPlayer.XPFormula(level)
    return level * 100 + ((level - 1) ^ 1.25) * 50
end

if CLIENT then

net.Receive("NebulaPlayer:SyncLevel", function()
    local level = net.ReadUInt(16)
    local xp = net.ReadUInt(32)

    local function setupLevel()
        if not IsValid(LocalPlayer()) then
            timer.Simple(0.1, setupLevel)
            return
        end

        LocalPlayer().levelSystem = {
            level = level,
            experience = xp,
        }
    end
end)

end