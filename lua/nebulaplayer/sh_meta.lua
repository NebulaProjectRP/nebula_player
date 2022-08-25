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

function meta:InArena()
    return self:GetNWBool("InArena", false)
end

hook.Add("OnPortalEntered", "NebulaArenaChecker", function(ply, ent, exit)
    if (ent:GetGroup() == "arena") then
        ply:SetNWBool("InArena", true)
    end

    if (ent:GetGroup() == "exit_arena") then
        ply:SetNWBool("InArena", false)
    end
end)

hook.Add("PlayerDeath", "NebulaArenaChecker", function(ply)
    if (ply:InArena()) then
        ply:SetNWBool("InArena", false)
    end
end)
