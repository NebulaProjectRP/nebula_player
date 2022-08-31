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
        return math.Round(CurTime() - NebulaPlayer.PlayTime.session + NebulaPlayer.PlayTime.time)
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

    function string.NicePlayTime(number)
        local time = number or LocalPlayer():getPlayTime()
        local str = ""
        local days = math.floor(time / 86400)
        local hours = math.floor(time / 3600) % 24
        local minutes = math.floor(time / 60) % 60

        if (days > 0) then
            str = str .. string.format("%dd ", days)
        end

        if (hours > 0) then
            str = str .. string.format("%dh ", hours)
        end

        str = str .. string.format("%dm ", minutes)

    return str
    end
end