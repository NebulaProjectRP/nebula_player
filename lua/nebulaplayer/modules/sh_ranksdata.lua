NebulaRanks = {
    Ranks = {},
    Members = {}
}

RANK_LOWEST = 0
RANK_LOW = 1
RANK_MEDIUM = 2
RANK_HIGH = 3
RANK_HIGHEST = 4

NebulaRanks.Ranks["default"] = {
    Name = "",
    Props = 45,
    Perm = RANK_LOWEST,
    MaxStore = 5,
    Hidden = true,
    Color = Color( 133, 133, 133),
}

NebulaRanks.Ranks["cosmic"] = {
    Name = "Cosmic",
    Props = 60,
    MaxStore = 8,
    Perm = RANK_MEDIUM,
    Color = Color( 221, 52, 255),
}

NebulaRanks.Ranks["monke"] = {
    Name = "Monke",
    Props = 60,
    Perm = RANK_LOW,
    Color = Color( 126, 56, 34),
}

NebulaRanks.Ranks["kat"] = {
    Name = "Monke",
    Props = 200,
    Perm = RANK_HIGHEST,
    Color = Color( 252, 173, 255),
}

function NebulaRanks:GetField(ply, field)
    local rank = ply:getTitle()
    return (self.Ranks[rank] and self.Ranks[rank] or self.Ranks["default"])[field]
end