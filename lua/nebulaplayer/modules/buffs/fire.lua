local meta = FindMetaTable("Player")

local buff = {
    Name = "Fire",
    Duration = 5,
    Stack = 3
}

function buff:OnCreate(ply)
    ply:AddFlags(FL_ONFIRE)
    if IsValid(ply._fireEnt) then
        ply._fireEnt:Remove()
    end

    ply:SetNWBool("OnFire", true)

    if SERVER then
        ply.fireLooperDamage = ply:LoopTimer("FireTimerDamage", .5, function()
            if (not ply:Alive()) then
                ply:Extinguish()

                return
            end

            local dmg = DamageInfo()
            dmg:SetAttacker(self:GetAttacker() or ply)
            dmg:SetInflictor(self:GetAttacker() or ply)
            dmg:SetDamage(math.min(ply:Health() * .02, 100))
            dmg:SetDamageForce(Vector(0, 0, 0))
            dmg:SetDamageType(DMG_FALL)

            if (ply:Health() <= 25) then
                ply:Extinguish()
                dmg:SetDamage(9999)
                ply:TakeDamageInfo(dmg)
                return
            end
            ply:TakeDamageInfo(dmg)

            ply:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 50), .25, 0)
            ply:EmitSound("player/pl_burnpain" .. math.random(1, 3) .. ".wav")
        end)
    end
end

function buff:OnRemove(ply)
    ply:Extinguish()
    if (ply.fireLooperDamage and ply.fireLooperDamage.Remove) then
        ply.fireLooperDamage:Remove()
    end
end

local fire = Material("sprites/cannon_exp")
function buff:PlayerDraw(ply)
    local size = ply:GetModelRadius()
    render.SetMaterial(fire)
    render.DrawSprite(ply:GetPos() + Vector(0, 0, size / 2), size, size * 2, color_white)
end

function meta:Ignite(sec, causer)
    self:addBuff("ignite", sec, causer)
end

function meta:Extinguish()
    self:SetNWBool("OnFire", false)
    self:RemoveFlags(FL_ONFIRE)
    if (self.fireLooperDamage) then
        self.fireLooperDamage:Remove()
    end
end

NebulaBuffs:Register("ignite", buff)
