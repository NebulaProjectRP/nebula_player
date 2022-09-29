local ETERNAL = {}
ETERNAL.Name = "Money Printer"
ETERNAL.Type = ETERNAL_ECONOMY
ETERNAL.Help = "Print large amounts of money"
ETERNAL.Titles = {
    [1] = "It was that easy?",
    [5] = "Living the dream underground",
    [10] = "Protect her at all costs <3",
    [15] = "Don't touch my stuff",
    [20] = "It grows up from a PC",
    [25] = "CHING CHING",
    [30] = "W $$ EDGY $$ LORD $$ W"
}

function ETERNAL:CanLevelUp(level)
    return math.Round(250000 + ((level - 1) ^ 1.4) * 100000)
end
NebulaEternals:Register("printer", ETERNAL)

ETERNAL = {}
ETERNAL.Name = "Printer Destruction"
ETERNAL.Type = ETERNAL_ECONOMY
ETERNAL.Help = "Destroy printers"
ETERNAL.Titles = {
    [1] = "No more printers",
    [5] = "Put away your printer waltuh",
    [10] = "Do you even print?",
    [15] = "Printer's Ransomware",
    [20] = "BITCOIN ENJOYER",
    [25] = "Only one printer fits in this town",
    [30] = ">$< MONOPOLY >$<"
}

function ETERNAL:CanLevelUp(level)
    return math.Round(5 + ((level - 1) ^ 1.2) * 5)
end
NebulaEternals:Register("printer_killer", ETERNAL)

ETERNAL = {}
ETERNAL.Name = "Bitcoin Miner"
ETERNAL.Type = ETERNAL_ECONOMY
ETERNAL.Help = "Mine many bitcoins as you can"
ETERNAL.Titles = {
    [1] = "Late to the party",
    [5] = "It's not a bubble",
    [10] = "Do you even mine?",
    [15] = "BITCOIN > PAPER",
    [20] = "Decentralized Retard",
    [25] = "Want some NFTs kids?",
    [30] = ">$< %5kOtsD5Dz >$<"
}

function ETERNAL:CanLevelUp(level)
    return math.Round(250000 + ((level - 1) ^ 1.4) * 100000)
end
NebulaEternals:Register("bitcoin", ETERNAL)

ETERNAL = {}
ETERNAL.Name = "Bitcoig Destruction"
ETERNAL.Type = ETERNAL_ECONOMY
ETERNAL.Help = "Destroy Bitcoin Miners"
ETERNAL.Titles = {
    [1] = "That's your gas",
    [5] = "Here's a new Crypto called Copium",
    [10] = "PAPER > BITCOIN",
    [15] = "Bubble Popper",
    [20] = "Anti-Nerds",
    [25] = "I don't care about your NFTs",
    [30] = "Waaah your cryptos crashed"
}

function ETERNAL:CanLevelUp(level)
    return math.Round(5 + ((level - 1) ^ 1.2) * 5)
end
NebulaEternals:Register("bitcoin_killer", ETERNAL)

ETERNAL = {}
ETERNAL.Name = "Stonks Enjoyer"
ETERNAL.Type = ETERNAL_ECONOMY
ETERNAL.Help = "Sell Items to stonks man"
ETERNAL.Titles = {
    [1] = "They finally added stonks!",
    [5] = "Take my trash fancy man",
    [10] = "wHy dOnT yOu aCcEpT tHiS",
    [15] = "Rich in shitty items",
    [20] = "Give me your trash please",
    [25] = "STONKS",
    [30] = "I'm the Stonks man"
}

function ETERNAL:CanLevelUp(level)
    return math.Round(10 + ((level - 1) ^ 1.4) * 20)
end
NebulaEternals:Register("stonks", ETERNAL)

ETERNAL = {}
ETERNAL.Name = "Braking Bad"
ETERNAL.Type = ETERNAL_ECONOMY
ETERNAL.Help = "Sell meth to the dealer"
ETERNAL.Titles = {
    [1] = "Kid name Finger",
    [5] = "Blue and tasty",
    [10] = "I'm the one who knocks",
    [15] = "Say my name",
    [20] = "Cook with License",
    [25] = "Waltuh, put your dick away",
    [30] = "I'm not having sex with you now waltuh"
}

function ETERNAL:CanLevelUp(level)
    return math.Round(350 + ((level - 1) ^ 1.4) * 1000)
end
NebulaEternals:Register("meth", ETERNAL)

ETERNAL = {}
ETERNAL.Name = "Weed Backer"
ETERNAL.Type = ETERNAL_ECONOMY
ETERNAL.Help = "Sell weed to the dealer"
ETERNAL.Titles = {
    [1] = "420",
    [5] = "Bake it and blaze it",
    [10] = "I just want to grow weed dude",
    [15] = "Weed Dispensary",
    [20] = "Weed WarLord",
    [25] = "Don't touch my plants",
    [30] = "Look at me, I do weed"
}

function ETERNAL:CanLevelUp(level)
    return math.Round(25000 + ((level - 1) ^ 1.5) * 10000)
end
NebulaEternals:Register("weed", ETERNAL)