util.AddNetworkString("NebulaPlayer:SyncLevel")

local meta = FindMetaTable("Player")

function meta:addXP(amount, reason)
    self.levelSystem.experience = self.levelSystem.experience + amount
    if amount > 0 then
        DarkRP.notify(self, 1, 5, "You've earned " .. amount .. "xp! " .. reason)
    end
    if (NebulaPlayer.XPFormula(self:getLevel()) <= self.levelSystem.experience) then
        self.levelSystem.level = self.levelSystem.level + 1
        DarkRP.notify(self, 1, 5, "You have leveled up to level " .. self.levelSystem.level .. "!")
        self:addXP(0)
    end

    net.Start("NebulaPlayer:SyncLevel")
    net.WriteUInt(self.levelSystem.level, 16)
    net.WriteUInt(self.levelSystem.experience, 32)
    net.Send(self)
end

hook.Add("DatabaseCreateTables", "Nebula.LevelSystem", function(fun)
    NebulaDriver:MySQLCreateTable("level", {
        level = "INT DEFAULT 0 NOT NULL",
        experience = "INT DEFAULT 0 NOT NULL",
        perks = "TEXT NOT NULL",
        steamid = "VARCHAR(22)"
    }, "steamid")

    NebulaDriver:MySQLHook("level", function(ply, data)
        data = data or {
            level = 1,
            experience = 0,
            perks = "[]"
        }

        ply.levelSystem = {
            level = data.level or 1,
            experience = data.experience or 0,
            perks = util.JSONToTable(data.perks or "[]")
        }

        if not data.level then
            NebulaDriver:MySQLInsert("level", {
                level = 1,
                experience = 0,
                perks = "[]",
                steamid = ply:SteamID64()
            })
        else
            MsgC(Color(100, 255, 200), "[Nebula]", color_white, " Loaded level data for " .. ply:Nick() .. ":" .. ply:SteamID64() .. "\n")
        end

        net.Start("NebulaPlayer:SyncLevel")
        net.WriteUInt(ply.levelSystem.level, 16)
        net.WriteUInt(ply.levelSystem.experience, 32)
        net.Send(ply)
    end)
end)