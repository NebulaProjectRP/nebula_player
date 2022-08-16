local meta = FindMetaTable("Player")

function meta:GetMaxProps()
    local rank = NebulaRanks.Ranks[self:getTitle()]

    if not rank then return NebulaRanks.Ranks.default.Props end

    return rank.Props
end

hook.Add("PlayerSpawnProp", "NebulaRanks:PlayerSpawnProp", function(ply, model)
    if ply:GetMaxProps() <= ply:GetCount("props") then return false end
end)

timer.Simple(10, function()
    hook.Remove("PlayerSpawnProp", "SAM.Spawning.PlayerSpawnPropprops")
end)