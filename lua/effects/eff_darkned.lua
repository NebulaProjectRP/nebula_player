----------------
-- Initialize --
----------------
EFFECT.FillingTime = 9999

function EFFECT:Init(data)
    self.Entity = data:GetEntity()
    if not IsValid(self.Entity) then return end
    self.StartPos = self.Entity:GetPos()
    self.NextSmoke = 0
    local scale = 1
    self.FillingTime = CurTime() + 2.5
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
    if (not IsValid(self.Entity)) then return false end
    if (self.Entity.Alive && not self.Entity:Alive()) then return false end

    if (self.NextSmoke < CurTime()) then
        self.NextSmoke = CurTime() + math.Rand(.1, .5)
        local emitter = ParticleEmitter(self.StartPos)
        local particle = emitter:Add("sprites/mat_jack_smoke" .. math.random(1, 3), self.Entity:GetPos() + Vector(0, 0, 30) + VectorRand() * 8)

        if particle then
            particle:SetVelocity(VectorRand() * 8)
            particle:SetDieTime(math.Rand(1.1, 2.2))
            particle:SetLifeTime(0)
            particle:SetStartSize(8)
            particle:SetEndSize(64)
        end

        emitter:Finish()
    end

    if (not self.Entity:hasBuff("shadow")) then return false end

    return true
end

-------------------
-- Render Effect --
-------------------
local mat = Material("particle/mat1")
function EFFECT:Render()
    if IsValid(self.Entity) then
        render.SetMaterial(mat)
        render.DrawSprite(self.Entity:GetPos() + Vector(0, 0, 40), 42, 112, Color(0, 0, 0))
    end
end