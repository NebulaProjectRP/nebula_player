NebulaCredits = {}

local meta = FindMetaTable("Player")

function meta:getCredits()
    return (self.storeData or {}).credits or 0
end

function meta:canAffordCredits(am)
    return self:getCredits() >= am
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
    NebulaCredits[target] = {}
    while (net.ReadBool()) do
        table.insert(NebulaCredits[target], {
            date = net.ReadUInt(32),
            source = net.ReadString(),
            amount = net.ReadUInt(32)
        })
    end
    MsgN("Readed ", table.Count(NebulaCredits[target]), " entries")
end)