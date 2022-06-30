----------------
-- Initialize --
----------------
local effCount = 0

function EFFECT:Init(data)
    self.Entity = data:GetEntity()
    local emitter = ParticleEmitter(data:GetOrigin())
    local particle = emitter:Add("particles/smokey", data:GetOrigin())

    if particle then
        local dir = data:GetNormal()
        particle:SetDieTime(math.Rand(.5, 1.5))
        particle:SetColor(255, 125, 255)
        particle:SetRoll(math.random(0, 360))
        particle:SetVelocity(dir)
        particle:SetLifeTime(.5)
        particle:SetStartSize(8)
        particle:SetEndSize(16)
    end

    local fps = 1 / FrameTime()
    local rand = fps > 60 and 20 or fps > 30 and 10 or 1

    for k = 1, rand do
        local bit = emitter:Add("particles/balloon_bit", data:GetOrigin() + data:GetNormal() * 4 + VectorRand() * 4)

        if bit then
            local dir = data:GetNormal()
            local ang = dir:Angle()
            bit:SetDieTime(math.Rand(.5, 1.5))
            local clr = HSVToColor(math.random(0, 360), .7, 1)
            bit:SetColor(clr.r, clr.g, clr.b)
            bit:SetRollDelta(math.random(0, 75))
            bit:SetVelocity(dir * 64 + ang:Forward() * math.Rand(0, 8) * 8 + ang:Right() * math.Rand(-4, 4) * 8 + ang:Up() * math.Rand(-4, 4) * 8)
            bit:SetLifeTime(.5)
            bit:SetStartSize(4)
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

-------------------
-- Render Effect --
-------------------
function EFFECT:Render()
end