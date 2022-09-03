local meta = FindMetaTable("Player")

local vipgroups = {
    ["admin"] = true,
    ["superadmin"] = true,
    ["owner"] = true,
    ["cosmic"] = true,
    ["vip+"] = true,
}
function meta:isVip()
    return vipgroups[self:GetUserGroup()] != nil
end

hook.Add("OnPortalEntered", "NebulaArenaChecker", function(ply, ent, exit)
end)

hook.Add("PlayerDeath", "NebulaArenaChecker", function(ply)

end)
