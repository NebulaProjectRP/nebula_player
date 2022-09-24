local meta = FindMetaTable("Player")

local vipgroups = {
    ["admin"] = true,
    ["superadmin"] = true,
    ["owner"] = true,
    ["cosmic"] = true,
    ["vip+"] = true,
}

function meta:isVip()
    return vipgroups[self:GetUserGroup()] ~= nil
end

local bn, ba = bit.bnot(IN_JUMP), bit.band
local function AutoHop(ply, data)
    if ply:IsBot() then return end

    if ba(data:GetButtons(), 2) > 0 and not ply:IsOnGround() and ply:WaterLevel() < 2 and ply:GetMoveType() == MOVETYPE_WALK then
        data:SetButtons(ba(data:GetButtons(), bn))
    end
end

hook.Add("SetupMove", "DoAutoHop", AutoHop)
hook.Add("OnPortalEntered", "NebulaArenaChecker", function(ply, ent, exit) end)
hook.Add("PlayerDeath", "NebulaArenaChecker", function(ply) end)