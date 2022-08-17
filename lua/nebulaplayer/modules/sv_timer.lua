util.AddNetworkString("NebulaRP.Playtime:Sync")

local meta = FindMetaTable("Player")

function meta:savePlayTime()
    local delta = math.floor(CurTime() - (self.startTime or 0))
    local deltaRecord = math.floor(CurTime() - (self.startTimeReal or 0))
    self.playTime.time = self.playTime.time + delta
    self.playTime.week = self.playTime.week + delta
    self.startTime = CurTime()

    if (deltaRecord > self.playTime.record) then
        self.playTime.record = deltaRecord
    end
    NebulaDriver:MySQLUpdate("playtime", {
        time = self.playTime.time,
        record = self.playTime.record,
        week = self.playTime.week,
        lastWeek = os.date("%W"),
    }, "steamid = " .. self:SteamID64())
end

function meta:initPlayTime(data)
    self.playTime = {
        time = 0,
        week = 0,
        record = 0,
        lastWeek = 0
    }

    self.startTime = CurTime()
    self.startTimeReal = CurTime()

    if data and data.time then
        self.playTime = data

        if (os.date("%W") != self.playTime.lastWeek) then
            self.playTime.lastWeek = os.date("%W")
            self.playTime.week = 0
        end

        MsgC(Color(100, 255, 200),"[Nebula]", color_white, " Loaded playtime data for " .. self:Nick() .. ":" .. self:SteamID64() .. "\n")
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

    NebulaDriver:MySQLHook("playtime", function(ply, data)
        ply:initPlayTime(data)
    end)
end)

hook.Add("PlayerDisconnected", "NebulaRP.PlayTime", function(ply)
    timer.Remove("Nebula.PlayTime.Update." .. ply:SteamID64())
    ply:savePlayTime()
end)