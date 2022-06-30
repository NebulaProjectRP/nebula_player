
local uistates = {}
local buff = {
    Name = "Ice"
}

function buff:OnCreate(ply)
    if CLIENT then
        uistates.freeze = {
            life = self:GetDuration(),
            ready = false,
            max = self:GetDuration(),
            progress = 0,
        }
    end

    ply:SetNWBool("IsFrozen", true)
    ply:SetMoveType(MOVETYPE_NONE)
    ply:SetMaterial("effects/freeze_overlayeffect01")
    ply.DamageDealt = 0
    ply:EmitSound("weapons/freeze" .. math.random(0, 2) .. ".wav")
end

function buff:OnRemove(ply)
    ply:SetMaterial("")
    ply:SetMoveType(MOVETYPE_WALK)
    ply:Freeze(false)
    ply:SetNWBool("IsFrozen", false)
    ply:EmitSound("weapons/shatter3.wav")

    local eff = EffectData()
    eff:SetEntity(ply)
    eff:SetOrigin(ply:EyePos())
    util.Effect("GlassImpact", eff, true, true)
    if (ply.DamageDealt == 0) then return end

    local dmg = DamageInfo()
    dmg:SetAttacker(owner or game.GetWorld())
    dmg:SetDamage(ply.DamageDealt)
    dmg:SetInflictor(wep or owner)
    dmg:SetDamageType(DMG_SHOCK)
    ply:TakeDamageInfo(dmg)
    ply.DamageDealt = 0
end

NebulaBuffs:Register("ice", buff)

if SERVER then return end

local iceScreen = surface.GetTextureID("hud/freeze_screen")

hook.Add("HUDPaint", "NebulaRP.Debuffs", function()
    local ply = LocalPlayer()
    if (not ply:Alive()) then return end

    if (uistates.freeze) then
        uistates.freeze.life = uistates.freeze.life - FrameTime()

        if (uistates.freeze.ready) then
            uistates.freeze.progress = uistates.freeze.life / uistates.freeze.max
        else
            uistates.freeze.progress = 1 - uistates.freeze.life / uistates.freeze.max
        end

        if (not uistates.freeze.ready and uistates.freeze.life <= 0) then
            uistates.freeze.ready = true
            uistates.freeze.life = .5
            uistates.freeze.max = .5
        elseif (uistates.freeze.life <= 0) then
            uistates.freeze = nil

            return
        end

        surface.SetDrawColor(0, 159, 170, 100 * uistates.freeze.progress)
        surface.DrawRect(0, 0, ScrW(), ScrH())
        surface.SetTexture(iceScreen)
        surface.SetDrawColor(255, 255, 255, 255 * uistates.freeze.progress)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    end
end)
