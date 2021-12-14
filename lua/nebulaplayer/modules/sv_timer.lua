util.AddNetworkString("NebulaRP.Playtime:Sync")

local meta = FindMetaTable("Player")

function meta:savePlayTime()
    local delta = math.floor(CurTime() - (self.startTime or 0))
    self.playTime.time = self.playTime.time + delta
    self.playTime.week = self.playTime.week + delta

    if (delta > self.playTime.record) then
        self.playTime.record = delta
    end
    NebulaDriver:MySQLUpdate("playtime", {
        time = self.playTime.time,
        record = self.playTime.record,
        week = self.playTime.week,
        lastWeek = os.date("%W"),
    }, "steamid = " .. self:SteamID64())
end

function meta:initPlayTime()
    self.playTime = {
        time = 0,
        week = 0,
        record = 0,
        lastWeek = 0
    }
    self.startTime = CurTime()
    NebulaDriver:MySQLSelect("playtime",
        "steamid =" .. self:SteamID64()
    , function(data)
        if data and data[1] then
            self.playTime = data[1]

            if (os.date("%W") != self.playTime.lastWeek) then
                self.playTime.lastWeek = os.date("%W")
                self.playTime.week = 0
            end
        else
            self.playTime = {
                time = 0,
                week = 0,
                record = 0,
                lastWeek = tonumber(os.date("%W")),
                steamid = self:SteamID64()
            }
            NebulaDriver:MySQLInsert("playtime", self.playTime)
        end

        net.Start("NebulaRP.Playtime:Sync")
        net.WriteUInt(self.playTime.time, 32)
        net.WriteUInt(self.playTime.week, 32)
        net.WriteUInt(self.playTime.record, 32)
        net.Send(self)
    end)

    timer.Create("Nebula.PlayTime.Update." .. self:SteamID64(), 60 * 5, 0, function()
        if self:IsValid() then
            self:savePlayTime()
        end
    end)
end

hook.Add("DatabaseCreateTables", "Nebula.PlayTime", function(fun)
    NebulaDriver:MySQLCreateTable("playtime", {
        record = "INT DEFAULT 0 NOT NULL",
        time = "INT DEFAULT 0 NOT NULL",
        week = "INT DEFAULT 0 NOT NULL",
        lastWeek = "INT DEFAULT 0 NOT NULL",
        steamid = "VARCHAR(22)"
    }, "steamid")
end)

hook.Add("PlayerInitialSpawn", "Nebula.PlayTime", function(ply)
    ply:initPlayTime()
end)

hook.Add("PlayerDisconnected", "NebulaRP.PlayTime", function(ply)
    timer.Remove("Nebula.PlayTime.Update." .. ply:SteamID64())
    ply:savePlayTime()
end)