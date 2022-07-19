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

        if (dashObj:GetEase()) then
            cycle = dashObj:GetEase()(cycle)
        end

        local ori = mv:GetOrigin()
        local target = LerpVector(cycle, dashObj.startPos, dashObj.startPos + dashObj:GetDirection() * dashObj.distance) //ori + dashObj:GetDirection() * dashObj.speed * FrameTime()
        local tr = util.TraceHull({
            start = ori + Vector(0, 0, 2),
            endpos = target + Vector(0, 0, 2),
            filter = ply,
            mins = Vector(-16, -16, -0),
            maxs = Vector(16, 16, 72),
            mask = MASK_PLAYERSOLID
        })

        debugoverlay.Cross(tr.HitPos, 64, 5, SERVER and Color(61, 145, 255) or Color(255, 100, 0), true)

        if (IsValid(tr.Entity) and dashObj.OnCollide) then
            dashObj:OnCollide(tr.Entity)
        end

        if tr.HitWorld then
            ply.dashObject = nil
            return
        end

        mv:SetOrigin(tr.HitPos)
        mv:SetVelocity(dashObj:GetDirection() * dashObj.distance)

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
        elseif (ply == LocalPlayer()) then
            ply.dashObject.dashEnd = ply.dashObject.dashEnd + (LocalPlayer():Ping() / 1000)
            ply.dashObject.time = (s.time or .5) + (LocalPlayer():Ping() / 1000)
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
        net.WriteFloat(s.dashEnd)
        net.WriteNormal(s:GetDirection())
        net.SendPVS(s:GetOwner():GetPos())
    end
}

dashMeta.__index = __index
AccessorFunc(dashMeta, "direction", "Direction", FORCE_VECTOR)
AccessorFunc(dashMeta, "ease", "Ease")

function Dash(target)
    local newDash = table.Copy(dashMeta)
    newDash:Init(target)
    return newDash
end

net.Receive("NebulaRP.DashSync", function(l)
    local owner = net.ReadEntity()
    if not IsValid(owner) then return end
    if (owner.dashObject) then return end

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