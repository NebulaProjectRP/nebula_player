local ETERNAL = {}
ETERNAL.Name = "Crafter"
ETERNAL.Type = ETERNAL_RESOURCES
ETERNAL.Help = "Craft items with mining resources"
ETERNAL.Titles = {
    [1] = "Handy",
    [5] = "Crafter lobster",
    [10] = "Built Different",
    [15] = "Chinese Corp",
    [20] = "Made In China",
    [25] = "Crafter of Bitches",
    [30] = "Amazon Prime"
}

function ETERNAL:CanLevelUp(level)
    return math.Round(10 + ((level - 1) ^ 1.2) * 15)
end
NebulaEternals:Register("crafter", ETERNAL)

ETERNAL = {}
ETERNAL.Name = "Minery"
ETERNAL.Type = ETERNAL_RESOURCES
ETERNAL.Help = "Mine large amount of ores"
ETERNAL.Titles = {
    [1] = "ROCK",
    [5] = "Gold Digger",
    [10] = "Titanium Sniffer",
    [15] = "Diamond Dog",
    [20] = "Minecrafter",
    [25] = "Mining some bitches",
    [30] = "Where does babys come from"
}

function ETERNAL:CanLevelUp(level)
    return math.Round(10000 + ((level - 1) ^ 1.3) * 15000)
end
NebulaEternals:Register("mining", ETERNAL)

ETERNAL = {}
ETERNAL.Name = "Trashman"
ETERNAL.Type = ETERNAL_RESOURCES
ETERNAL.Help = "Recycle trash from anywhere"
ETERNAL.Titles = {
    [1] = "Stinky boi",
    [5] = "Look at me Trash",
    [10] = "Smelly Puppy Poop",
    [15] = "You're Trash",
    [20] = "You Stink",
    [25] = "Trash King",
    [30] = "TRASH ENJOYER"
}

function ETERNAL:CanLevelUp(level)
    return math.Round(10 + ((level - 1) ^ 1.3) * 15)
end
NebulaEternals:Register("trash", ETERNAL)

ETERNAL = {}
ETERNAL.Name = "Control Points"
ETERNAL.Type = ETERNAL_RESOURCES
ETERNAL.Help = "Capture for your gangs control points"
ETERNAL.Titles = {
    [1] = "Follow me dipshit!",
    [5] = "ZoOoOmEeR",
    [10] = "STAND WITH ME",
    [15] = "Get the fuck out my points",
    [20] = "My Gang needs you!",
    [25] = "King of the Hill",
    [30] = "I'm the Captain now"
}

function ETERNAL:CanLevelUp(level)
    return math.Round(3 + ((level - 1) ^ 1.3) * 5)
end
NebulaEternals:Register("controlpoints", ETERNAL)