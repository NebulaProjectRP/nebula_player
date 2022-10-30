util.AddNetworkString("NebulaEternals.Sync")
local meta = FindMetaTable("Player")

function meta:addEternalStat(id, val)
    local eternal = NebulaEternals.Data[id]
    if not eternal then
        MsgN("[ETERNALS] " .. self:Nick() .. " tried to add into a non existant eternal ", id, "!")
        return
    end

    local hadEternal = true
    if not self._eternals then
        self._eternals = {}
    end
    if not self._eternals[id] then
        hadEternal = false
        self._eternals[id] = {
            progress = 0,
            level = 0,
        }
    end

    self._eternals[id].progress = self._eternals[id].progress + val
    if (eternal:CanLevelUp(self._eternals[id].level, self._eternals[id].progress)) then
        self._eternals[id].level = self._eternals[id].level + 1
        self._eternals[id].progress = 0
        self:ChatPrint("You have leveled up <color=green>" .. eternal.Name .. "</color> to level <rainbow=3>" .. self._eternals[id].level .. "</rainbow>!")
        if (eternal.Titles[self._eternals[id].level]) then
            self:ChatPrint("You have unlocked the title <color=green>" .. eternal.Titles[self._eternals[id].level] .. "</color>!")
        end
    end

    local tag = self:UniqueID() .. "_eternals"
    timer.Create(tag, 5, 1, function()
        if (hadEternal) then
            NebulaDriver:MySQLUpdate("nebula_eternals", {progress = self._eternals[id].progress, level = self._eternals[id].level}, "steamid = " .. self:SteamID64() " and id = " .. id)
        else
            NebulaDriver:MySQLInsert("nebula_eternals", {steamid = self:SteamID64(), id = id, progress = self._eternals[id].progress, level = self._eternals[id].level})
        end
    end)

    net.Start("NebulaEternals.Sync")
    net.WriteString(id)
    net.WriteUInt(self._eternals[id].progress, 32)
    net.WriteUInt(self._eternals[id].level, 16)
    net.Send(self)
end

function NebulaEternals:KillResolver(ply, inf, att)
    if not att:IsPlayer() then return end

    if (att:Health() < 10) then
        att:addEternalStat("singledigit", 1)
    end

    att.killsMade = (att.killsMade or 0) + 1
    if (att.killsMade >= 3) then
        att:addEternalStat("rampage", 1)
    end
    att:Wait(30, function()
        att.killsMade = (att.killsMade or 0) - 1
    end)

    if (ply:LastHitGroup() == HITGROUP_HEAD) then
        att:addEternalStat("headshot", 1)
    end

    if (ply:hasSuit()) then
        att:addEternalStat("kills", 1)
    end
end

function NebulaEternals:DamageResolver(ply, dmg)
    local att = dmg:GetAttacker()
    if not IsValid(att) or not att:IsPlayer() then return end

    if (dmg:IsExplosionDamage() and dmg:GetDamage() > ply:Health()) then
        att:addEternalStat("explosives", 1)
    end

    att:addEternalStat("dps", dmg:GetDamage())
end

hook.Add("DatabaseInitialized", "NebulaEternals.AddDB", function()
    NebulaDriver:MySQLCreateTable("eternals", {
        steamid = "VARCHAR(22)",
        id = "VARCHAR(32)",
        progress = "INT DEFAULT 0",
        level = "INT DEFAULT 0",
    }, "steamid, id")

    NebulaDriver:MySQLHook("eternals", function(ply, data)
        ply._eternalsData = {}
        for k, v in pairs(data or {}) do
            ply._eternalsData[v.id] = {
                progress = v.progress,
                level = v.level,
            }
        end
    end)
end)

concommand.Add("eternals_random", function(ply, cmd)
    if (IsValid(ply)) then return end

    ply = player.GetByID(1)

    for k, v in pairs(NebulaEternals.Data) do
        if (math.random(1, 3) == 1) then
            ply:addEternalStat(k, math.random(1, 5))
        end
    end
end)

hook.Add("Hitman.HitSuccess", "NebulaEternals.Berserker", function(offered, target, hitman)
    hitman:addEternalStat("hitman", 1)
end)

hook.Add("PlayerDeath", "NebulaEternals.Berserker", function(ply, inf, att)
    NebulaEternals:KillResolver(ply, inf, att)
end)

hook.Add("PostEntityTakeDamage", "NebulaEternals.Berserker", function(ent, dmg, took)
    if (took and ent:IsPlayer()) then
        NebulaEternals:DamageResolver(ent, dmg)
    end
end)

hook.Add("ASAPPrinters.WithdrawMoney", "NebulaEternals.Economy", function(ply, _, amount)
    ply:addEternalStat("printer", amount)
end)

hook.Add("ASAPPrinters.DestroyPrinter", "NebulaEternals.Economy", function(printer, ply)
    if (not ply:IsPlayer()) then return end
    ply:addEternalStat("printer_killer", 1)
end)

hook.Add( "CH_BITMINER_PlayerWithdrawMoney", "NebulaEternals.Economy", function( ply, money_to_withdraw )
    ply:addEternalStat("bitcoin", money_to_withdraw)
end)

hook.Add( "CH_BITMINER_Destroyed", "NebulaEternals.Economy", function( printer, ply )
    if (not ply:IsPlayer()) then return end
    ply:addEternalStat("bitcoin_killer", 1)
end)

hook.Add("OnStonksBuy", "NebulaEternals.Economy", function(ply, id, price)
    ply:addEternalStat("stonks", 1)
end)

hook.Add("zmlab_OnMethSell", "NebulaEternals.Economy", function(ply, meth)
    ply:addEternalStat("meth", meth)
end)

hook.Add("zmlab_OnMethSell", "NebulaEternals.Economy", function(ply, meth)
    ply:addEternalStat("meth", meth)
end)

hook.Add("zwf_OnWeedSold", "NebulaEternals.Economy", function(ply, npc, earning, WeedBlockCount)
    ply:addEternalStat("weed", earning)
end)

hook.Add("OnItemCrafted", "NebulaEternals.Resources", function(ply)
    ply:addEternalStat("craft", 1)
end)

hook.Add("OnMiningOre", "NebulaEternals.Resources", function(ply, type, amount, credits)
    ply:addEternalStat("mining", amount)
end)

hook.Add("ztm_OnTrashBlockCreation", "NebulaEternals.Resources", function(ply, Recycler, ent)
    ply:addEternalStat("trash", 1)
end)

hook.Run("OnControlPointCaptured", "NebulaEternals.Resources", function(cp, factionContesting, ply)
    ply:addEternalStat("controlpoints", 1)
end)