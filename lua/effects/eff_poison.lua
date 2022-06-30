----------------
-- Initialize --
----------------
EFFECT.FillingTime = 9999

function EFFECT:Init(data)
    self.Entity = data:GetEntity()
    if not IsValid(self.Entity) then return end
    local emitter = ParticleEmitter(self.Entity:GetPos())
    local particle = emitter:Add("sprites/mat_jack_smoke" .. math.random(1, 3), self.Entity:EyePos() - Vector(0, 0, 8) + VectorRand() * 8)

    if particle then
        particle:SetVelocity(VectorRand() * 8)
        particle:SetDieTime(math.Rand(1.1, 2.2))
        particle:SetLifeTime(0)
        particle:SetStartSize(8)
        particle:SetColor(100, 255, 75, 255)
        particle:SetEndSize(32)
    end

    emitter:Finish()
end

------------------
-- Effect Think --
------------------
function EFFECT:Think()
    return false
end

function EFFECT:Render()
end