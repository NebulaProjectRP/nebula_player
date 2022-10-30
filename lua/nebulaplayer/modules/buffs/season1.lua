

buff = {
    Name = "Ghosting"
}

local screams = {"vo/npc/male01/no01.wav", "vo/npc/male01/no02.wav", "vo/npc/male01/ohno.wav", "vo/npc/male01/help01.wav",}

function buff:OnCreate(ply)
    local duration = self:GetDuration()
    local timerName = ply:SteamID64() .. "_ghost"
    ply:SetNWBool("IsGhosted", true)

    if SERVER then
        ply:EmitSound(table.Random(screams), 110, 100, 1, CHAN_AUTO)
    elseif (LocalPlayer() == ply) then
        util.ScreenShake(EyePos(), 10, 20, duration, 32)
    end


    local remaining = duration
    hook.Add("StartCommand", timerName, function(p, cmd)
        if p ~= ply then return end

        local scaredof = self:GetAttacker()
        if not IsValid(ply) or not IsValid(scaredof) or remaining <= 0 or not ply:hasBuff("ghost") then
            hook.Remove("StartCommand", timerName)

            return
        end

        remaining = remaining - FrameTime()
        cmd:ClearMovement()
        cmd:ClearButtons()
        cmd:SetViewAngles((scaredof:EyePos() - ply:EyePos()):Angle())
        cmd:SetForwardMove(-50)
    end)

    timer.Remove(timerName)

    ply:Wait(duration, function()
        hook.Remove("StartCommand", timerName)
        ply:SetNWBool("IsGhosted", false)
    end)
end

NebulaBuffs:Register("ghost", buff)

buff = {
    Name = "Poison",
    TickInterval = 1
}

function buff:OnCreate(ply)
    ply:SetNWBool("IsPoison", true)
end

function buff:Tick(ply)
    if CLIENT then return end
    local dmg = DamageInfo()
    dmg:SetDamage(math.min(ply:Health() * .1, 100))
    dmg:SetDamageType(DMG_POISON)
    dmg:SetAttacker(IsValid(self:GetAttacker()) or self:GetAttacker() or ply)
    dmg:SetDamageForce(Vector(0, 0, 0))
    dmg:SetInflictor(ply)
    ply:TakeDamageInfo(dmg)
    local eff = EffectData()
    eff:SetEntity(ply)
    util.Effect("eff_poison", eff, true, true)

    if (ply:IsPlayer()) then
        ply:ScreenFade(SCREENFADE.OUT, Color(75, 255, 75), .5, 0)
    end
end

function buff:OnRemove(ply)
    ply:SetNWBool("IsPoison", false)
end

NebulaBuffs:Register("poison", buff)

buff = {
    Name = "Confetti"
}

function buff:OnCreate(ply)
    ply:SetNWBool("HauntedConfetti", true)
end

function buff:TakeDamage(ply, dmg)
    ent.DamageDealt = ent.DamageDealt + dmg:GetDamage() * .3
    dmg:SetDamage(0)

    if (ent.DamageDealt > ent:Health()) then
        dmg:SetDamage(ent:Health() * 5)
        ent:SetNWBool("IsFrozen", false)
        ent.DamageDealt = 0
    end
    return true
end

function buff:OnRemove(ply)
    ply:SetNWBool("HauntedConfetti", false)
end

NebulaBuffs:Register("conffeti", buff)

buff = {
    Name = "Healing Defficiency"
}

NebulaBuffs:Register("healing", buff)

hook.Add("ScalePlayerDamage", "NebulaBuffs.OnFireMadness", function(ply, hit, dmg)
    if (ply:IsFlagSet(FL_ONFIRE) and dmg:IsBulletDamage()) then
        dmg:ScaleDamage(1.25)
    end
end)

hook.Add("EntityFireBullets", "NebulaBuffs.Confetti", function(ply, bul)
    if (ply:GetNWBool("HauntedConfetti")) then
        local eff = EffectData()
        eff:SetOrigin(bul.Src)
        eff:SetEntity(ply)
        eff:SetNormal(ply:GetAngles():Forward())
        util.Effect("eff_debug_decoy", eff, true, true)

        return false
    end
end)
