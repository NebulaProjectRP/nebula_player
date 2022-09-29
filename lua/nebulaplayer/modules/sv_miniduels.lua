local stalemate = CreateConVar("nebula_stalemate_timer", "90", {FCVAR_ARCHIVE, FCVAR_REPLICATED})
util.AddNetworkString("NebulaDuels.MiniDuel")

local maxDist = (1024 * 3) ^ 2
local function testDistance(pl, at)
    local dist = pl:GetPos():DistToSqr(pl.duelCenter) / maxDist
    if (dist > 1) then
        if (pl.duelLives > 0) then
            pl.duelLives = pl.duelLives - 1
            DarkRP.notify(pl, 1, 4, "Return back, you have " .. pl.duelLives .. " lives left!")
            return
        end

        local dmg = DamageInfo()
        dmg:SetDamage(5000)
        dmg:SetAttacker(at)
        dmg:SetInflictor(at)
        dmg:SetDamageType(DMG_CRUSH)
        pl:TakeDamageInfo(dmg)
        return
    end
end

function StartMiniDuel(att, ply)
    local canDuel = hook.Call("NebulaDuels.CanDuel", nil, att, ply)
    if (canDuel == false) then return end

    ply:Freeze(true)
    att:Freeze(true)

    hook.Run("OnMiniduelsStart", att, ply)

    if ply:GetNWInt("DuelsWins", -1) == -1 then
        ply:SetNWInt("DuelsWins", ply:GetPData("DuelsWins", 0))
    end
    if att:GetNWInt("DuelsWins", -1) == -1 then
        att:SetNWInt("DuelsWins", att:GetPData("DuelsWins", 0))
    end

    ply.duelCenter = ply:GetPos()
    att.duelCenter = ply:GetPos()
    local diff = (att:GetPos() - ply:GetPos()):GetNormalized() * Vector(1, 1, 0)
    ply:SetPos(ply:GetPos() + Vector(0, 0, 2))
    ply:SetLocalVelocity(-diff * 400 + Vector(0, 0, 200))
    att:SetPos(att:GetPos() + Vector(0, 0, 2))
    att:SetLocalVelocity(diff * 400 + Vector(0, 0, 200))

    timer.Simple(4, function()
        ply:Freeze(false)
        att:Freeze(false)
    end)

    ply:SetNW2String("IsDueling", true)
    ply.miniDuel = att
    att:SetNW2String("IsDueling", true)
    att.miniDuel = ply
    net.Start("NebulaDuels.MiniDuel")
    net.WriteEntity(att)
    net.WriteEntity(ply)
    net.Send({ply, att})

    ply.duelLives = 3
    ply:SetHealth(ply:GetMaxHealth())
    att.duelLives = 3
    att:SetHealth(att:GetMaxHealth())

    ply.timerTag = "NebulaDuels.MiniDuel." .. ply:SteamID64() .. "." .. att:SteamID64()
    att.timerTag = ply.timerTag
    timer.Create(ply.timerTag .. "_to", stalemate:GetInt(), 0, function()
        if not IsValid(ply) or not IsValid(att) then
            return
        end
        local dead = ply:Health() > att:Health() and att or ply
        DarkRP.notify({ply, att}, 1, 8, "STALEMATE! " .. dead:Nick() .. " got obliterated!")
        local dmg = DamageInfo()
        dmg:SetDamage(5000)
        dmg:SetAttacker(dead == ply and att or ply)
        dmg:SetInflictor(dmg:GetAttacker())
        dmg:SetDamageType(DMG_CRUSH)
        dead:TakeDamageInfo(dmg)
    end)
    timer.Create(ply.timerTag, 3, 0, function()
        if not IsValid(ply) or not IsValid(att) then
            return
        end

        testDistance(ply, att)
        testDistance(att, ply)
    end)
end

hook.Add("PlayerDisconnected", "NebulaDuesl.SolveMini", function(ply)
    if (IsValid(ply.miniDuel)) then
        DarkRP.notify(ply.miniDuel, 1, 4, "Your duel partner has disconnected.")
        timer.Remove(ply.timerTag .. "_to")
        timer.Remove(ply.timerTag)
        ply.miniDuel:SetNWString("IsDueling", false)
        ply.miniDuel.miniDuel = nil
        ply.miniDuel = nil
    end
end)

hook.Add("DoPlayerDeath", "NebulaDuels.MiniDuel", function(ply, att, dmg)
    if not IsValid(att) then
        att = ply
    end
    if att == ply or (ply.miniDuel and ply.miniDuel == att) then
        if (att == ply) then
            att = ply.miniDuel
            DarkRP.notify(ply.miniDuel, 0, 4, "Your duel partner has suicided, so you won.")
            DarkRP.notify(ply, 1, 4, "So clumsy, you don't deserve to win!")
        else
            DarkRP.notify(att, 0, 4, "You've killed your duel enemy.")
            DarkRP.notify(ply, 1, 4, "You lost the duel!")
        end

        ply.miniDuel = nil
        att.miniDuel = nil
        ply:SetNW2String("IsDueling", false)
        att:SetNW2String("IsDueling", false)

        timer.Remove(ply.timerTag .. "_to")
        timer.Remove(ply.timerTag)

        local total = ply:getDarkRPVar("money") * .05
        ply:addMoney(-total)
        att:addMoney(total)
        DarkRP.notify(att, 0, 5, "You've won " .. DarkRP.formatMoney(total) .. " for winning the duel.")

        hook.Run("OnMiniduelsWin", att, ply, total)
        att:SetPData("DuelsWins", att:GetNWInt("DuelsWins", 0) + 1)
        att:SetNWInt("DuelsWins", att:GetNWInt("DuelsWins", 0) + 1)

        if (not ply.hasFool and ply:hasSuit()) then
            att:giveItem("suit_" .. ply:hasSuit(), 1)
            for k, v in pairs(ply._loadout) do
                if string.StartWith(k, "weapon") then
                    att:giveItem(v.id, 1, v.data)
                end
            end
        end
    end
end)

hook.Add("PlayerShouldTakeDamage", "NebulaMiniDuels", function(ply, att)
    if (not att:IsPlayer()) then return end
    local wep = att:GetActiveWeapon()
    if (ply:IsDueling() or ply:InArena()) then return end
    if (att:IsDueling() or att:InArena()) then return end
    if (wep:GetClass() != "weapon_fists") then return end

    if (att.hasBeenWarned and att.hasBeenWarned == ply) then
        StartMiniDuel(att, ply)
        return
    end

    if not ply.hasBeenWarned then
        DarkRP.notify(ply, 1, 5, "You are about to start a mini duel with " .. att:Nick() .. ".")
        DarkRP.notify(ply, 1, 5, "Equip your fist and fight back.")
    end

    ply.hasBeenWarned = att
    timer.Create(ply:UniqueID() .. "NebulaMiniDuels", 5, 1, function()
        if (IsValid(ply)) then
            ply.hasBeenWarned = nil
        end
    end)
end)