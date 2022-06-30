

buff = {
    Name = "Shadow Blind"
}

local runtime = 0
local cache
local tab = {
    ["$pp_colour_addr"] = 0,
    ["$pp_colour_addg"] = 0,
    ["$pp_colour_addb"] = 0,
    ["$pp_colour_brightness"] = -.5,
    ["$pp_colour_contrast"] = .4,
    ["$pp_colour_colour"] = .6,
    ["$pp_colour_mulr"] = 0,
    ["$pp_colour_mulg"] = 0,
    ["$pp_colour_mulb"] = 0
}

local function createPuff()
    if (runtime <= 0) then return end
    local dir = math.random(1, 2) == 1 and -1 or 1
    local size = math.random(1024, 2048)

    local tbl = {
        x = dir < 0 and ScrW() + size / 2 + math.random(16, 256) or -size / 2 - math.random(16, 256),
        y = math.random(-size / 2, size / 2),
        variation = math.random(1, 9),
        size = size, --math.random(256, 512),
        speed = math.random(10, 16) * dir
    }

    table.insert(cache, tbl)
end

function buff:OnCreate(ply)
    local eff = EffectData()
    eff:SetEntity(ply)
    util.Effect("eff_darkned", eff, true, true)
    ply:SetNWBool("IsBlind", true)

    if CLIENT then
        runtime = self:GetDuration()
        cache = {}

        for k = 1, 32 do
            createPuff()
        end

        tab = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = -.5,
            ["$pp_colour_contrast"] = .4,
            ["$pp_colour_colour"] = .6,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }
    end
end

function buff:OnRemove(ply)
    if CLIENT then
        runtime = 0
    end
    ply:SetNWBool("IsBlind", false)
end

NebulaBuffs:Register("shadow", buff)

if SERVER then return end

local deg = surface.GetTextureID("vgui/gradient-u")
local smokes = {}
for k = 1, 9 do
    smokes[k] = surface.GetTextureID("particle/smokesprites_000" .. k)
end

hook.Add("HUDPaint", "NebulaRP.ShowBlind", function()
    if (runtime < 0) then return end
    if not cache then return end
    surface.SetTexture(deg)
    surface.SetDrawColor(0, 0, 0, runtime > 1 and 100 or 100 * runtime)
    surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
    surface.DrawTexturedRectRotated(ScrW() / 2, ScrH() / 2, ScrW(), ScrH(), 180)

    for k, v in pairs(cache) do
        v.x = v.x + v.speed

        if (math.abs(v.x) > ScrW() + v.size) then
            table.remove(cache, k)
            createPuff()
            continue
        end

        surface.SetTexture(smokes[v.variation])
        surface.SetDrawColor(75, 75, 75, 100)
        surface.DrawTexturedRect(v.x, v.y, v.size, v.size / 1.5, 0)
    end

    runtime = runtime - FrameTime()
end)

hook.Add("RenderScreenspaceEffects", "DarkSphere", function()
    if (runtime <= 0) then return end
    if (runtime < 1) then
        tab["$pp_colour_brightness"] = Lerp(1 - runtime, -.5, 0)
        tab["$pp_colour_contrast"] = Lerp(1 - runtime, .4, 1)
        tab["$pp_colour_colour"] = Lerp(1 - runtime, .6, 1)
    end

    DrawColorModify(tab)
end)