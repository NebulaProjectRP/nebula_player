local enabledWeed = false

local buff = {
    Name = "Confused"
}

function buff:TakeDamage(ent, dmg, att, inf)
    ent.DamageDealt = ent.DamageDealt + dmg:GetDamage() * .5
    ent.weed_LA = dmg:GetAttacker()
    ent.weed_LI = dmg:GetInflictor()
    dmg:SetDamage(0)

    return true
end

function buff:OnCreate(ply)
    local timerName = ply:SteamID64() .. "_weed"
    timer.Remove(timerName)

    if enabledWeed then
        ply:SetNWBool("weed", true)
        return
    end

    if CLIENT then
        LocalPlayer():ScreenFade(SCREENFADE.IN, color_white, .3, 0)
        enabledWeed = true
        nebulaWeedCreate(true)
    end
    ply:SetNWBool("IsWeed", true)
    ply.DamageDealt = 0
end

function buff:OnRemove(ply, recreate)
    if recreate then return end
    if CLIENT then
        enabledWeed = false
        LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 0, 0), .3, 0)
        nebulaWeedCreate(false)
    end

    ply:SetMaterial("")
    ply:SetMoveType(MOVETYPE_WALK)
    ply:SetNWBool("IsWeed", false)
    ply:SetNWBool("SuperWeed", false)

    if ply.DamageDealt > 0 then
        local dmg = DamageInfo()
        dmg:SetAttacker(ply.weed_LA or game.GetWorld())
        dmg:SetDamage(ply.DamageDealt)
        dmg:SetInflictor(ply)
        dmg:SetDamageType(DMG_CLUB)
        ply:TakeDamageInfo(dmg)
        ply.DamageDealt = 0
    end
end

NebulaBuffs:Register("weed", buff)
if SERVER then return end
local nextTurn = 0
local lerpDir = 0
local power = 0
local direction = 0

function weedEffects()
    DrawMotionBlur(.1, .8, 0.01)
    DrawBloom(0.4, 2, 4, 4, 1, 1, 1, 1, 1)
end

function weedCalcView(ply, pos, ang, fov)
    local super = ply:GetNWBool("SuperWeed", false) and 2 or 1
    local tbl = {}
    pos = pos + ang:Up() * math.cos(RealTime()) * 12 * super
    pos = pos + ang:Right() * math.sin(RealTime()) * 12 * super
    ang = ang - Angle(math.cos(RealTime()) * 5 * super, math.sin(RealTime()) * 5 * super, math.sin(RealTime()) * 4 * super)
    tbl.origin = tbl
    tbl.angles = ang

    return tbl
end

local function weedCommander(ply, cmd)
    if nextTurn < CurTime() then
        local super = ply:GetNWBool("SuperWeed", false) and 2 or 1
        direction = math.Rand(-math.pi * 2, math.pi * 2)
        nextTurn = CurTime() + math.Rand(1, 3)
        power = math.Rand(20, 60) * super
    end

    lerpDir = Lerp(FrameTime() * 2, lerpDir, direction)
    local maxx = math.Clamp(cmd:GetSideMove(), -ply:GetWalkSpeed(), ply:GetWalkSpeed()) * .4
    local maxy = math.Clamp(cmd:GetForwardMove(), -ply:GetWalkSpeed(), ply:GetWalkSpeed()) * .4
    cmd:SetSideMove(maxx - power * math.cos(lerpDir))
    cmd:SetForwardMove(maxy - power * math.sin(lerpDir))
end

local function weedSensitivity(sens)
    return .5 - .15 * (LocalPlayer():GetNWBool("SuperWeed", false) and 2 or 1)
end

function nebulaWeedCreate(doweed)
    hook.Remove("AdjustMouseSensitivity", "NebulaRP.Weed")
    hook.Remove("StartCommand", "NebulaRP.Weed")
    hook.Remove("CalcView", "NebulaRP.Weed")
    hook.Remove("RenderScreenspaceEffects", "NebulaRP.Weed")

    if doweed then
        hook.Add("AdjustMouseSensitivity", "NebulaRP.Weed", weedSensitivity)
        hook.Add("StartCommand", "NebulaRP.Weed", weedCommander)
        hook.Add("CalcView", "NebulaRP.Weed", weedCalcView)
        hook.Add("RenderScreenspaceEffects", "NebulaRP.Weed", weedEffects)
    end
end