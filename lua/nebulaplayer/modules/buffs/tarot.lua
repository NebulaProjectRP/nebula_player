local buff = {
    Name = "Judgement"
}

function buff:OnCreate(ply)
    ply.infiniteBullets = true
end

function buff:OnRemove(ply)
    ply.infiniteBullets = true
end

NebulaBuffs:Register("judgement", buff)

buff = {
    Name = "No Headshots"
}

function buff:OnCreate(ply)
    ply.noHeadShots = true
end
function buff:OnRemove(ply)
    ply.noHeadShots = true
end
NebulaBuffs:Register("noheadshots", buff)

buff = {
    Name = "Judgement"
}

function buff:OnCreate(ply)
    ply.doknock = true
end
function buff:OnRemove(ply)
    ply.doknock = true
end
NebulaBuffs:Register("strength", buff)

hook.Add("EntityFireBullets", "TarotBullets", function(wep, data)
    local attacker = data.Attacker
    if !IsValid(attacker) or !attacker:IsPlayer() then return end

    if attacker:hasBuff("judgement") then
        if (wep:IsPlayer()) then
            wep = attacker:GetActiveWeapon()
        end
        wep:SetClip1(wep:GetMaxClip1())
    end

    if attacker:hasBuff("strength") then
        data.Force = data.Force * 1.5
        return true
    end
end)

if CLIENT then return end

hook.Add("ScalePlayerDamage", "NoHeadShots", function(ply, hitgroup, dmginfo)
    if ply.noHeadShots and hitgroup == HITGROUP_HEAD then
        ply:EmitSound("nebularp/duck_pickup_neg_01.wav", 100)
        dmginfo:ScaleDamage(0)
    end
end)

hook.Add("ScalePlayerDamage", "NoHeadShots", function(ply, hitgroup, dmginfo)
    if ply.noHeadShots and hitgroup == HITGROUP_HEAD then
        ply:EmitSound("nebularp/duck_pickup_neg_01.wav", 100)
        dmginfo:ScaleDamage(0)
    end
end)
