util.AddNetworkString("NebulaRP.Credits:Sync")
util.AddNetworkString("NebulaRP.Credits:Transfer")
util.AddNetworkString("NebulaRP.Credits:RequestLogs")
util.AddNetworkString("NebulaRP.Credits:ChangeTitle")
util.AddNetworkString("NebulaRP.Credits:ChangeCosmeticTitle")
util.AddNetworkString("NebulaRP.Credits:SendBP")

NebulaPremium = NebulaPremium or {}

function NebulaPremium:CreateLog(receiver, sender, amount, source)
    NebulaDriver:MySQLInsert("premium_logs", {
        receiver = receiver,
        sender = sender,
        source = source,
        credits = tonumber(amount),
        time = os.time()
    })
end

-- Meta
local meta = FindMetaTable("Player")

function meta:transferCredits(target, amount)
    amount = math.ceil(amount)

    if target == self then
        DarkRP.notify(self, 1, 5, "Ha ha really funny")

        return false
    end

    if amount <= 0 then
        DarkRP.notify(self, 1, 5, "You can transfer, not request")

        return false
    end

    if not self:canAffordCredits(amount) then
        DarkRP.notify(self, 1, 5, "You cannot afford this transfer")

        return false
    end

    local could = target:addCredits(amount, "Transfer-" .. self:SteamID64())

    if not could then
        DarkRP.notify({self, target}, 1, 7, target:Nick() .. " couldn't receive " .. self:Nick() .. " payment!")

        return false
    end

    could = self:addCredits(-amount, "Transfer-" .. target:SteamID64())

    if not could then
        target:addCredits(-amount, "Error-" .. self:SteamID64())

        DarkRP.notify({self, target}, 1, 7, self:Nick() .. " couldn't send " .. self:Nick() .. " payment! Money returned")

        return false
    end

    NebulaPremium:CreateLog(target:SteamID64(), self:SteamID64(), amount, "Player Transfer")

    return true
end

function meta:setCosmeticTitle(text, animation, style)
    animation = animation or "default"

    self.storeData.bag.head = {
        text = text,
        animation = animation,
        style = style
    }

    self:SetNWString("HeadAnim", animation)
    self:SetNWString("HeadText", text)
    self:SetNWString("HeadStyle", style)

    NebulaDriver:MySQLUpdate("premium", {
        bag = util.TableToJSON(self.storeData.bag)
    }, "steamid = " .. self:SteamID64())
end

function meta:syncCredits()
    local st = self.storeData
    net.Start("NebulaRP.Credits:Sync")
    net.WriteBool(true)
    net.WriteUInt(st.credits, 32)
    net.WriteString(util.TableToJSON(st.titles))
    net.WriteString(util.TableToJSON(st.bag))
    net.WriteString(util.TableToJSON(st.config))
    net.Send(self)
end

function meta:addCredits(x, source, ignore)
    if not source then
        ErrorNoHalt("Source #2 parameter not found, gonna have to do something about that!")

        return false
    end

    if self._lockedTransaction then
        DarkRP.notify(self, 1, 4, "Waiting for your last transaction to end!")

        return false
    end

    if not NebulaPremium[self:SteamID64()] then
        NebulaPremium[self:SteamID64()] = {
            Credits = 0,
            Logs = {}
        }
    end

    local credits, canModify = hook.Run("OnCreditsAdd", self, x, source, ignore)

    if canModify ~= nil then
        DarkRP.notify(self, 1, 4, "Failed credits transaction: " .. tostring(canModify))

        return false
    end

    if credits then
        x = credits
    end

    if (self.storeData.credits + x) < 0 then
        DarkRP.notify(self, 1, 4, "Failed credits transaction: Below 0 result")

        return false
    end

    self.storeData.credits = (self.storeData.credits or 0) + x
    NebulaPremium[self:SteamID64()].Credits = NebulaPremium[self:SteamID64()].Credits + x

    table.insert(NebulaPremium[self:SteamID64()].Logs, {
        date = os.time(),
        reason = source,
        amount = x
    })

    NebulaPremium:CreateLog(self:SteamID64(), nil, x, source)

    if ignore then return true end

    net.Start("NebulaRP.Credits:Sync")
    net.WriteBool(false)
    net.WriteUInt(math.max(self.storeData.credits, 0), 32)
    net.Send(self)
    self._lockedTransaction = true

    NebulaDriver:MySQLUpdate("premium", {
        credits = self.storeData.credits
    }, "steamid = " .. self:SteamID64(), function()
        if IsValid(self) then
            self._lockedTransaction = nil
        end

        MsgN("[Nebula] [Online Player] " .. self:SteamID64() .. " has been given " .. x .. " credits. New balance: " .. self.storeData.credits)
    end)

    return true
end

hook.Add("DatabaseInitialized", "NebulaRP.Store", function()
    NebulaDriver:MySQLCreateTable("premium", {
        steamid = "VARCHAR(22) NOT NULL",
        credits = "INT NOT NULL DEFAULT 0",
        titles = "TEXT NOT NULL",
        activetitle = "VARCHAR(32) DEFAULT 'user'",
        bag = "TEXT NOT NULL",
        config = "TEXT NOT NULL",
        joinDate = "INT(32) NOT NULL DEFAULT 0",
    }, "steamid")

    NebulaDriver:MySQLCreateTable("premium_logs", {
        id = "INT NOT NULL AUTO_INCREMENT",
        sender = "VARCHAR(22)",
        receiver = "VARCHAR(22)",
        credits = "INT NOT NULL DEFAULT 0",
        source = "VARCHAR(64) NOT NULL",
        time = "INT(32) NOT NULL",
    }, "id")

    NebulaDriver:MySQLHook("premium", function(pl, data)
        local time = os.time()

        if not data then
            NebulaDriver:MySQLInsert("premium", {
                steamid = pl:SteamID64(),
                titles = "[]",
                bag = "[]",
                config = "[]",
                joinDate = time
            })

            data = {
                credits = 0,
                titles = {},
                bag = {},
                config = {},
                joinDate = time
            }
        else
            if data.joinDate == 0 then
                NebulaDriver:MySQLUpdate("premium", {
                    joinDate = time,
                }, "steamid = " .. pl:SteamID64(), function()
                    data.joinDate = time
                    MsgN("[Nebula] [Unknown Player] " .. pl:SteamID64() .. " has been validated.")
                end)
            end

            data.titles = util.JSONToTable(data.titles)
            data.bag = util.JSONToTable(data.bag)
            data.config = util.JSONToTable(data.config)
        end

        pl.storeData = data
        pl:SetNWString("Title", data.activetitle)
        if (data.bag.head) then
            pl:SetNWString("HeadAnim", data.bag.head.animation)
            pl:SetNWString("HeadText", data.bag.head.text)
            pl:SetNWString("HeadStyle", data.bag.head.style)
        end
        pl:syncCredits()
    end)
end)

function meta:giveRank(rank)
    if not table.HasValue(self.storeData.titles, rank) then
        table.insert(self.storeData.titles, rank)
        self.storeData.activetitle = rank
        self:SetNWString("Title", rank)

        NebulaDriver:MySQLUpdate("premium", {
            titles = util.TableToJSON(self.storeData.titles),
            activetitle = rank
        }, "steamid = " .. self:SteamID64(), function()
            MsgN("[Nebula] [Online Player] " .. self:SteamID64() .. " has been given " .. rank .. " rank.")
        end)
    end
end

function meta:addBattlepass(id)
    if not self.storeData.bag then
        self.storeData.bag = {}
    end

    self.storeData.bag[id] = {
        level = 0,
        premium = true,
        claimed = 0
    }

    net.Start("NebulaRP.Credits:SendBP")
    net.WriteString(id)
    net.WriteBool(true)
    net.WriteUInt(self.storeData.bag[id].level, 32)
    net.WriteUInt(self.storeData.bag[id].claimed, 32)
    net.Send(self)
end

net.Receive("NebulaRP.Credits:Transfer", function(l, pl)
    local result = pl:transferCredits(net.ReadEntity(), net.ReadUInt(32))
    net.Start("NebulaRP.Credits:Transfer")
    net.WriteBool(result)
    net.Send(pl)
end)

net.Receive("NebulaRP.Credits:RequestLogs", function(l, pl)
    if not pl:IsSuperAdmin() then return end
    local target = net.ReadString()
    local page = net.ReadUInt(8)

    if not NebulaPremium[target] then
        net.Start("NebulaRP.Credits:RequestLogs")
        net.WriteBool(false)
        net.Send(pl)

        return
    end

    net.Start("NebulaRP.Credits:RequestLogs")
    net.WriteBool(true)
    net.WriteString(target)

    for k = page * 10, (page + 1) * 10 do
        local obj = NebulaPremium[target][k]

        if not obj then
            net.WriteBool(false)
            continue
        end

        net.WriteBool(true)
        net.WriteUInt(obj.date, 32)
        net.WriteString(obj.source)
        net.WriteUInt(obj.amount, 32)
    end

    net.Send(pl)
end)

net.Receive("NebulaRP.Credits:ChangeTitle", function(l, ply)
    local title = net.ReadString()
    if (ply.lastTitleChange or 0) > CurTime() then return end
    ply.lastTitleChange = CurTime() + 2

    if title == ply:getTitle() or not table.HasValue(ply:getTitles(), title) then
        ply:SetNWString("Title", title)

        NebulaDriver:MySQLUpdate("premium", {
            activetitle = title
        }, "steamid = " .. ply:SteamID64())
    end
end)

local blacklisted = {
    mod = true,
    ["m0d"] = true,
    owner = true,
    admin = true,
    vip = true,

}

net.Receive("NebulaRP.Credits:ChangeCosmeticTitle", function(l, ply)
    local text = net.ReadString()
    local animation = net.ReadString()
    local style = net.ReadString()

    text = string.Replace(text, "'", "")
    text = string.Replace(text, '"', '')

    if (#text > 24) then
        MsgN("Message too long")
        return
    end

    if not NebulaPremium.TextDecorators[animation] then
        MsgN("No animation")
        return
    end

    if not NebulaPremium.TextStyles[style] then
        style = "default"
    end

    for k, v in pairs(blacklisted) do
        if (string.find(text, k)) then
            net.Start("NebulaRP.Credits:ChangeCosmeticTitle")
            net.WriteBool(false)
            net.WriteUInt(0, 2)
            net.Send(ply)
            MsgN("Blacklisted")
            return
        end
    end

    local oldtext, oldanim, oldStyle = ply:GetNWString("HeadText"), ply:GetNWString("HeadAnim"), ply:GetNWString("HeadStyle")
    //MsgN(oldtext," ", text," ", animation," ", oldanim, " ", style, " ", oldStyle)
    local price = (oldtext != text and 250 or 0) + (oldanim != animation and NebulaPremium.TextDecorators[animation].price or 0) + (oldStyle != style and 250 or 0) 
    MsgN(price)
    if (ply:getCredits() < price) then
        net.Start("NebulaRP.Credits:ChangeCosmeticTitle")
        net.WriteBool(false)
        net.WriteUInt(1, 2)
        net.Send(ply)
        MsgN("Can't afford")
        return
    end
    if price > 0 then
        ply:addCredits(-price, "Buying Title")
        ply:setCosmeticTitle(text, animation, style)
    end
end)

-- Concommands
concommand.Add("neb_addrank", function(ply, cmd, args)
    if IsValid(ply) then return end
    local target = args[1]
    local rank = args[2]

    if IsValid(player.GetBySteamID64(target)) then
        player.GetBySteamID64(target):giveRank(rank)
        DarkRP.notify(player.GetBySteamID64(target), 0, 4, "You have been given the " .. rank .. " rank!")
    else
        NebulaDriver:MySQLQuery("SELECT titles FROM premium WHERE steamid = " .. target, function(data)
            if data and data[1] then
                local titles = util.JSONToTable(data[1].titles)
                table.insert(titles, rank)

                NebulaDriver:MySQLUpdate("premium", {
                    titles = util.TableToJSON(titles),
                    activetitle = rank
                }, "steamid = " .. target, function()
                    MsgN("[Nebula] [Existing Player] " .. target .. " has been given " .. rank .. " rank.")
                end)
            else
                NebulaDriver:MySQLInsert("premium", {
                    steamid = target,
                    titles = util.TableToJSON({rank}),
                    activetitle = rank,
                    bag = "[]",
                    config = "[]",
                }, function()
                    MsgN("[Nebula] [Unknown Player] " .. target .. " has been given " .. rank .. " rank.")
                end)
            end
        end)
    end
end)

concommand.Add("neb_addcredits", function(ply, cmd, args)
    if IsValid(ply) then return end
    local target = args[1]
    local amount = tonumber(args[2])
    if not amount then return end

    if IsValid(player.GetBySteamID64(target)) then
        player.GetBySteamID64(target):addCredits(amount, "Console/RCON/Donation")
        DarkRP.notify(player.GetBySteamID64(target), 0, 4, "You have been given " .. amount .. " credits!")
    else
        NebulaDriver:MySQLQuery("SELECT credits FROM premium WHERE steamid = " .. target, function(data)
            if data and data[1] then
                NebulaDriver:MySQLUpdate("premium", {
                    credits = "credits + " .. amount
                }, "steamid = " .. target, function()
                    NebulaPremium:CreateLog(target, nil, amount, "Console/RCON/Donation")
                    MsgN("[Nebula] [Existing Player] " .. target .. " has been given " .. amount .. " credits. New balance: " .. tonumber(data[1].credits) + amount)
                end)
            else
                NebulaDriver:MySQLInsert("premium", {
                    steamid = target,
                    credits = amount,
                    titles = "[]",
                    bag = "[]",
                    config = "[]",
                }, function()
                    NebulaPremium:CreateLog(target, nil, amount, "Console/RCON/Donation")
                    MsgN("[Nebula] [Unknown Player] " .. target .. " has been given " .. amount .. " credits. New balance: " .. amount)
                end)
            end
        end)
    end
end)

-- NOT NEEDED RN

-- concommand.Add("neb_givebp", function(ply, cmd, args)
--     if IsValid(ply) then return end
--     local target = args[1]
--     local bp = args[2]
--     if IsValid(player.GetBySteamID64(target)) then
--         player.GetBySteamID64(target):addBattlepass(bp)
--     else
--         NebulaDriver:MySQLQuery("SELECT bag FROM premium WHERE steamid = " .. target, function(data)
--             if data and data[1] then
--                 local bag = util.JSONToTable(data[1].bag)
--                 bag[bp] = {
--                     level = 0,
--                     premium = true,
--                     claimed = 0
--                 }
--                 NebulaDriver:MySQLUpdate("premium", {
--                     bag = util.TableToJSON(bag)
--                 }, "steamid = " .. target, function()
--                     MsgN("[Nebula] " .. target .. " has been given " .. bp .. " battlepass.")
--                 end)
--             end
--         end)
--     end
-- end)