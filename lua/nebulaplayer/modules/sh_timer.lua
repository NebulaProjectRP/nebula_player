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

    function string.NicePlayTime()
        local time = LocalPlayer():getPlayTime()
        local format = os.date("!*t", time)
        local str = ""
        if (format.yday > 0) then
            str = str .. string.format("%d day%s, ", format.yday, format.yday > 1 and "s" or "")
        end

        if (format.hour > 0) then
            str = str .. string.format("%d hour%s, ", format.hour, format.hour > 1 and "s" or "")
        end

        if (format.min > 0) then
            str = str .. string.format("%d minute%s", format.min, format.min > 1 and "s" or "")
        end

        return str
    end
end