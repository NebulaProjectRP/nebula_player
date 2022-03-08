local meta = FindMetaTable("Player")

local vipgroups = {
    ["admin"] = true,
    ["superadmin"] = true,
    ["owner"] = true,
    ["vip"] = true,
    ["vip+"] = true,
}
function meta:isVip()
    return vipgroups[self:GetUserGroup()] != nil
end