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
    end)
end)