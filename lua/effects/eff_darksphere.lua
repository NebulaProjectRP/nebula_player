
----------------
-- Initialize --
----------------
EFFECT.FillingTime = 9999
function EFFECT:Init(data)
    self.StartPos = data:GetOrigin()
    local scale = data:GetMagnitude() or 1
    self.FillingTime = CurTime() + 4 * scale
    local dlight = DynamicLight(self.Entity:EntIndex())

    if (dlight) then
        dlight.Pos = self.StartPos
        dlight.r = 255
        dlight.g = 255
        dlight.b = 255
        dlight.Brightness = -10
        dlight.Size = 256
        dlight.DieTime = CurTime() + 1
        dlight.Decay = 256
    end

    local emitter = ParticleEmitter(self.StartPos)
    local particle = emitter:Add("particle/particle_ring_wave_12_eff", self.StartPos)

    if particle then
        particle:SetVelocity(Vector(0, 0, -64))
        particle:SetDieTime(.5)
        particle:SetLifeTime(0)
        particle:SetColor(75, 255, 255, 255)
        particle:SetStartSize(4)
        particle:SetEndSize(500 * scale)
    end

    emitter:Finish()
end

------------------
-- Effect Think --
------------------
function EFFECT:Think()
    if (self.FillingTime < CurTime()) then return false end
    return true
end

-------------------
-- Render Effect --
-------------------

function EFFECT:Render()
end