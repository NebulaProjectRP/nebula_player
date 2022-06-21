if SERVER then
    util.AddNetworkString("NebulaRP.DashSync")
end

hook.Add("Move", "NebulaRP.MoveDash", function(ply, mv)
    local dashObj = ply.dashObject
    if (dashObj) then
        local cycle = math.Clamp(1 - (dashObj.dashEnd - CurTime()) / dashObj.time, 0, 1)
        if (cycle == 1) then
            ply.dashObject = nil
            return
        end

        if (dashObject:GetEase()) then
            cycle = dashObject:GetEase()(cycle)
        end

        local ori = mv:GetOrigin()
        local target = ori + dasbObj:GetDirection() * dashObj.speed * FrameTime()
        local tr = util.TraceHull({
            start = target + Vector(0, 0, 8),
            endpos = target + Vector(0, 0, 16),
            filter = ply,
            mins = Vector(-16, -16, -0),
            maxs = Vector(16, 16, 72),
            mask = MASK_PLAYERSOLID
        })

        if (IsValid(tr.Entity) and dashObj.OnCollide) then
            dashObj:OnCollide(tr.Entity)
        end

        mv:SetOrigin(tr.HitPos)
        mv:SetVelocity(dashObj:GetDirection() * dashObj.speed)

        return true
    end
end)

local dashMeta = {
    Start = function(s, replicated)
        local ply = s:GetOwner()
        s.dashEnd = CurTime() + (s.time or .5)
        s.startPos = ply:GetPos()
        ply.dashObject = s
        if SERVER then
            s:Network()
        end
    end,
    GetOwner = function(s)
        return s.owner
    end,
    Init = function(s, ply)
        s.owner = ply
    end,
    SetDistance = function(s, val, time)
        s.distance = val
        s.time = time
        s.speed = val / time
    end,
    Network = function(s)
        if CLIENT then return end
        net.Start("NebulaRP.DashSync")
        net.WriteEntity(s:GetOwner())
        net.WriteFloat(s.distance)
        net.WriteFloat(s:GetOwner().dashEnd)
        net.WriteNormal(s:GetDirection())
        net.SendPVS(s:GetOwner():GetPos())
    end
}

dashMeta.__index = __index
AccessorFunc(dashMeta, "direction", "Direction", FORCE_VECTOR)
AccessorFunc(dashMeta, "ease", "Ease")

function Dash(target)
    local newDash = setmetatable({}, dashMeta)
    newDash:Init(target)
end

net.Receive("NebulaRP.DashSync", function(l)
    local owner = net.ReadEntity()
    if not IsValid(owner) then return end

    local distance = net.ReadFloat()
    local time = net.ReadFloat()
    local direction = net.ReadNormal()
    local dash = Dash(owner)
    dash.distance = distance
    dash.time = time - CurTime()
    dash:SetDirection(direction)
    dash:Start(true)
    dash.dashEnd = time
end)