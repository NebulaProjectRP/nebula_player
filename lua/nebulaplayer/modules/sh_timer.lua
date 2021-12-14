if CLIENT then
    NebulaPlayer.PlayTime = NebulaPlayer.PlayTime or {
        time = 0,
        week = 0,
        record = 0
    }
end
local meta = FindMetaTable("Player")

function meta:getPlayTime()
    if CLIENT then
        return CurTime() - NebulaPlayer.PlayTime.session + NebulaPlayer.PlayTime.time
    else
        return CurTime() - self.startTime + self.playTime.time
    end
end

function meta:hasHours(amount)
    return self:getPlayTime() / 3600 >= amount
end

if CLIENT then
    net.Receive("NebulaRP.Playtime:Sync", function(l, ply)
        NebulaPlayer.PlayTime = {
            time = net.ReadUInt(32),
            week = net.ReadUInt(32),
            record = net.ReadUInt(32),
            session = CurTime()
        }
    end)
end