NebulaPremium = {}

local meta = FindMetaTable("Player")

function meta:getCredits()
    return (self.storeData or {}).credits or 0
end

function meta:getTitles()
    return (self.storeData or {}).titles or {}
end

function meta:getTitle()
    return self:GetNWString("Title", nil)
end

function meta:canAffordCredits(am)
    return self:getCredits() >= am
end

function meta:hasCosmeticTitle()
    return self:GetNWString("HeadText", "") != ""
end

local function waitPlayer(data)
    if not IsValid(LocalPlayer()) then
        timer.Simple(.1, function()
            waitPlayer(data)
        end)
        return
    end

    LocalPlayer().storeData = data
end

net.Receive("NebulaRP.Credits:Sync", function()
    local isFull = net.ReadBool()

    if (isFull) then
        local data = {
            credits = net.ReadUInt(32),
            titles = util.JSONToTable(net.ReadString()),
            bag = util.JSONToTable(net.ReadString()),
            config = util.JSONToTable(net.ReadString()),
        }
        waitPlayer(data)
        return
    end

    LocalPlayer().storeData.credits = net.ReadUInt(32)
end)

net.Receive("NebulaRP.Credits:RequestLogs", function()
    local found = net.ReadBool()
    if not found then
        Derma_Message("This player doesn't have any credits transactions", "Error", "Ok")
        return
    end

    local target = net.ReadString()

    NebulaPremium[target] = {}

    while (net.ReadBool()) do
        table.insert(NebulaPremium[target], {
            date = net.ReadUInt(32),
            source = net.ReadString(),
            amount = net.ReadUInt(32)
        })
    end
    MsgN("Readed ", table.Count(NebulaPremium[target]), " entries")
end)

NebulaPremium.TextStyles = {
    default = function(p, i, txt)
        return p:GetPlayerColor():ToColor()
    end,
    hacker = function(p, i, txt)
        local offset = math.cos(RealTime() * 3 + i) * .35
        return HSVToColor(100, 1, .6 + offset)
    end,
    galaxy = function(p, i, txt)
        local offset = math.cos(RealTime() * 3 + i) * 30
        return HSVToColor(280 + offset, 1, .8)
    end,
    rainbow = function(p, i, txt)
        local offset = 180 + math.sin(RealTime() * 2 + i) * 180
        return HSVToColor(offset, 1, .75)
    end,
    love = function(p, i, txt)
        local offset = math.cos(RealTime() * 8 + i) / 4
        return HSVToColor(300, .6 - offset, 1)
    end,
    electric = function(p, i, txt)
        local offset = math.tan(RealTime() * 3 + i) / 4
        return HSVToColor(190, .6 - offset, 1)
    end,
}

NebulaPremium.TextDecorators = {
    default = {
        name = "Default",
        price = 0,
        display = function(ply, text, font, style, x, y)
            local clr = NebulaPremium.TextStyles[style] or NebulaPremium.TextStyles.default
            draw.SimpleText(text, font, x or 0, y or 0, clr(ply, 1, text), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    },
    failling = {
        name = "Ramp Up",
        price = 0,
        display = function(ply, text, font, style, ox, oy)
            local clr = NebulaPremium.TextStyles[style] or NebulaPremium.TextStyles.default
            surface.SetFont(font)
            local tx, _ = surface.GetTextSize(text)
            local origin = -tx / 2
            local extraY = 0
            for i = 1, #text do
                local char = text[i]
                local charw, _ = surface.GetTextSize(char)
                local x = origin + charw / 2 + ox or 0
                local y = extraY + oy or 0
                draw.SimpleText(char, font, x, y, clr(ply, i, char), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                origin = origin + charw
                extraY = extraY - 2
            end
        end
    },
    shaky = {
        name = "Bouncy",
        price = 0,
        display = function(ply, text, font, style, ox, oy)
            local clr = NebulaPremium.TextStyles[style] or NebulaPremium.TextStyles.default
            surface.SetFont(font)
            local tx, _ = surface.GetTextSize(text)
            local extra = math.cos(RealTime() * 4) * 32
            local origin = -tx / 2 - extra
            for i = 1, #text do
                local char = text[i]
                local charw, _ = surface.GetTextSize(char)
                local x = origin + charw / 2 + ox or 0
                local y = oy or 0
                draw.SimpleText(char, font, x, y, clr(ply, i, char), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                local center = math.abs((-(#text / 2) + i) / (#text / 2)) * math.abs(extra / 4)
                origin = origin + charw + center
            end
        end
    },
    sin = {
        name = "Wavvyy",
        price = 200,
        display = function(ply, text, font, style, ox, oy)
            local clr = NebulaPremium.TextStyles[style] or NebulaPremium.TextStyles.default
            surface.SetFont(font)
            local tx, _ = surface.GetTextSize(text)
            local origin = -tx / 2
            for i = 1, #text do
                local char = text[i]
                local charw, _ = surface.GetTextSize(char)
                local x = origin + charw / 2 + ox or 0
                local y = math.sin(CurTime() * 2 + x / 10) * 4 + oy or 0
                draw.SimpleText(char, font, x, y, clr(ply, i, char), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                origin = origin + charw
            end
        end
    },
    circling = {
        name = "Circling",
        price = 200,
        display = function(ply, text, font, style, ox, oy)
            local clr = NebulaPremium.TextStyles[style] or NebulaPremium.TextStyles.default
            surface.SetFont(font)
            local tx, _ = surface.GetTextSize(text)
            local origin = -tx / 2
            for i = 1, #text do
                local char = text[i]
                local charw, _ = surface.GetTextSize(char)
                local x = origin + charw / 2 + math.cos(CurTime() * 2 + (i / #text) * math.pi) * 4 + (ox or 0)
                local y = math.sin(CurTime() * 2 + (i / #text) * math.pi) * 10 + (oy or 0)
                draw.SimpleText(char, font, x, y, clr(ply, i, char), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                origin = origin + charw
            end
        end
    }
}