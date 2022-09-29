local ETERNAL = {}
ETERNAL.Name = "Hitman"
ETERNAL.Type = ETERNAL_BERSERKER
ETERNAL.Help = "Complete assasinations as hitman"
ETERNAL.Titles = {
    [1] = "Born Killer",
    [5] = "Crook Recruit",
    [10] = ".44 Caliber Killer",
    [15] = "Call and Kill",
    [20] = "Phone Menacer",
    [25] = "Agent 47",
    [30] = "Blood Money"
}

function ETERNAL:CanLevelUp(level)
    return math.Round(10 + ((level - 1) ^ 1.1) * 10)
end
NebulaEternals:Register("hitman", ETERNAL)

ETERNAL = {}
ETERNAL.Name = "Almost"
ETERNAL.Type = ETERNAL_BERSERKER
ETERNAL.Help = "Kill while having one single digit HP"
ETERNAL.Titles = {
    [1] = "Clover",
    [5] = "Queen of Hearts",
    [10] = "King of Hearts",
    [15] = "Unbeatable force",
    [20] = "I didn't hear no Bell",
    [25] = "Not even close BABY",
    [30] = "Cope L"
}
function ETERNAL:CanLevelUp(level)
    return math.Round(5 + ((level - 1) ^ 1.1) * 5)
end
NebulaEternals:Register("singledigit", ETERNAL)

ETERNAL = {}
ETERNAL.Name = "Rampage"
ETERNAL.Type = ETERNAL_BERSERKER
ETERNAL.Help = "Kill atleast 3 players whiting 30 seconds"
ETERNAL.Titles = {
    [1] = "Rocky",
    [5] = "Unstoppable",
    [10] = "Legendary",
    [15] = "RDMer?",
    [20] = "Spinning Bot",
    [25] = "Someone should get an Admin",
    [30] = "You're ALL DEAD"
}
function ETERNAL:CanLevelUp(level)
    return math.Round(3 + ((level - 1) ^ 1.2) * 3)
end
NebulaEternals:Register("rampage", ETERNAL)

ETERNAL = {}
ETERNAL.Name = "Aim to the Head"
ETERNAL.Type = ETERNAL_BERSERKER
ETERNAL.Help = "Kill with Headshots"
ETERNAL.Titles = {
    [1] = "Nice shot",
    [5] = "Head Looter",
    [10] = "2X Damage???",
    [15] = "Between Eyes",
    [20] = "Portrait Splatter",
    [25] = "Brain Enthusiast",
    [30] = "Deadshot"
}
function ETERNAL:CanLevelUp(level)
    return math.Round(10 + ((level - 1) ^ 1.25) * 10)
end
NebulaEternals:Register("headshot", ETERNAL)

ETERNAL = {}
ETERNAL.Name = "Boom!"
ETERNAL.Help = "Kill with Explosions"
ETERNAL.Type = ETERNAL_BERSERKER
ETERNAL.Titles = {
    [1] = "Rocket Scientist",
    [5] = "KABOOM",
    [10] = "Glycerine Expert",
    [15] = "Demolition Guy",
    [20] = "Watch your feets",
    [25] = "Don't bring guns into a bombs fight",
    [30] = "TNT Enjoyer"
}
function ETERNAL:CanLevelUp(level)
    return math.Round(5 + ((level - 1) ^ 1.25) * 5)
end
NebulaEternals:Register("explosives", ETERNAL)

ETERNAL = {}
ETERNAL.Name = "Kills"
ETERNAL.Type = ETERNAL_BERSERKER
ETERNAL.Help = "Kill players wearing suits"
ETERNAL.Titles = {
    [1] = "Anti-Suit",
    [5] = "Fighting fire with fire",
    [10] = "Drop your suit or Die",
    [15] = "Suit's part Collector",
    [20] = "Bionic > Suits",
    [25] = "Get on the EVA",
    [30] = "Get a refund after this"
}
function ETERNAL:CanLevelUp(level)
    return math.Round(5 + ((level - 1) ^ 1.25) * 5)
end
NebulaEternals:Register("kills", ETERNAL)

ETERNAL = {}
ETERNAL.Name = "Warlord"
ETERNAL.Type = ETERNAL_BERSERKER
ETERNAL.Help = "Deal many damage you can"
ETERNAL.Titles = {
    [1] = "Cotton Bullets",
    [5] = "Tickles Tickles",
    [10] = "That had to sting",
    [15] = "Anti-Healer",
    [20] = "(Warning) I'm NOT friendly",
    [25] = "I'm the one who knocks",
    [30] = "I'm the Danger",
}
function ETERNAL:CanLevelUp(level)
    return math.Round(1000 + ((level - 1) ^ 1.5) * 1000)
end
NebulaEternals:Register("dps", ETERNAL)