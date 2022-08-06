util.AddNetworkString("NebulaRP.Credits:Sync")
util.AddNetworkString("NebulaRP.Credits:Transfer")
util.AddNetworkString("NebulaRP.Credits:RequestLogs")
util.AddNetworkString("NebulaRP.Credits:ChangeTitle")
util.AddNetworkString("NebulaRP.Credits:SendBP")

NebulaCredits = {}
local meta = FindMetaTable("Player")

function meta:transferCredits(target, amount)
    amount = math.ceil(amount)
    if (target == self) then
        DarkRP.notify(self, 1, 5, "Ha ha really funny")
        return false
    end

    if (amount <= 0) then
        DarkRP.notify(self, 1, 5, "You can transfer, not request")
        return false
    end

    if (not self:canAffordCredits(amount)) then
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

    NebulaDriver:MySQLInsert("credits_logs", {
        credits = amount,
        sender = self,
        receiver = target,
        date = os.time(),
        source = "Transfer:" .. self:SteamID64() .. "-" .. target:SteamID64()
    })

    return true
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
        ErrorNoHalt("source #2 parameter not found, wanna gonna do about that!")

        return false
    end

    if self._lockedTransaction then
        DarkRP.notify(self, 1, 4, "Waiting for your last transaction to end")

        return false
    end

    if not NebulaCredits[self:SteamID64()] then
        NebulaCredits[self:SteamID64()] = {
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
    NebulaCredits[self:SteamID64()].Credits = NebulaCredits[self:SteamID64()].Credits + x

    table.insert(NebulaCredits[self:SteamID64()].Logs, {
        date = os.time(),
        reason = source,
        amount = x
    })

    if ignore then return true end
    net.Start("NebulaRP.Credits:Sync")
    net.WriteBool(false)
    net.WriteUInt(math.max(self.storeData.credits, 0), 32)
    net.Send(self)
    self._lockedTransaction = true

    NebulaDriver:MySQLUpdate("credits", {
        credits = self.storeData.credits
    }, "steamid = " .. self:SteamID64(), function()
        if IsValid(self) then
            self._lockedTransaction = nil
        end
    end)

    return true
end

hook.Add("DatabaseInitialized", "NebulaRP.Store", function()
    NebulaDriver:MySQLCreateTable("credits", {
        steamid = "VARCHAR(22) NOT NULL",
        credits = "INT NOT NULL DEFAULT 0",
        titles = "TEXT NOT NULL",
        activetitle = "VARCHAR(32) DEFAULT 'user'",
        bag = "TEXT NOT NULL",
        config = "TEXT NOT NULL",
        joinDate = "INT(32) NOT NULL"
    }, "steamid")

    NebulaDriver:MySQLCreateTable("credits_logs", {
        id = "INT NOT NULL AUTO_INCREMENT",
        credits = "INT NOT NULL DEFAULT 0",
        sender = "VARCHAR(22) NOT NULL",
        receiver = "VARCHAR(22) NOT NULL",
        date = "INT(32) NOT NULL",
        source = "VARCHAR(64) NOT NULL"
    }, "id")

    NebulaDriver:MySQLHook("credits", function(pl, data)
        if not data then
            NebulaDriver:MySQLInsert("credits", {
                steamid = pl:SteamID64(),
                titles = "[]",
                bag = "[]",
                config = "[]",
                joinDate = os.time()
            })

            data = {
                credits = 0,
                titles = {},
                bag = {},
                config = {},
                joinDate = os.time()
            }
        else
            data.titles = util.JSONToTable(data.titles)
            data.bag = util.JSONToTable(data.bag)
            data.config = util.JSONToTable(data.config)
        end

        pl.storeData = data
        pl:SetNWString("Title", data.activetitle)
        pl:addCredits(data.credits, "First Spawn", true)
        pl:syncCredits()
    end)
end)

function meta:giveRank(rank)
    if not table.HasValue(self.storeData.titles, rank) then
        table.insert(self.storeData.titles, rank)
        self.storeData.activetitle = rank
        self:SetNWString("Title", rank)
        NebulaDriver:MySQLUpdate("credits", {
            titles = util.TableToJSON(self.storeData.titles),
            activetitle = rank
        }, "steamid = " .. self:SteamID64())
    end
end

concommand.Add("neb_addrank", function(ply, cmd, args)
    if (IsValid(ply)) then
        return
    end

    local target = table.concat(args, "", 1, 5)
    local rank = args[6]

    if IsValid(player.GetBySteamID(target)) then
        player.GetBySteamID(target):giveRank(rank)
    else
        local sid64 = util.SteamIDTo64(target)
        NebulaDriver:MySQLQuery("SELECT titles FROM credits WHERE steamid = " .. sid64, function(data)
            if data and data[1] then
                local titles = util.JSONToTable(data[1].titles)
                table.insert(titles, rank)
                NebulaDriver:MySQLUpdate("titles", {
                    titles = util.TableToJSON(titles)
                }, "steamid = " .. sid64, function()
                    MsgN("[NebulaRP] " .. target .. " has been given " .. rank .. " rank.")
                end)
            end
        end)
    end
end)

concommand.Add("neb_addcredits", function(ply, cmd, args)
    if (IsValid(ply)) then
        return
    end

    local target = table.concat(args, "", 1, 5)
    local amount = args[6]

    if IsValid(player.GetBySteamID(target)) then
        DarkRP.notify(player.GetBySteamID(target), 0, 4, "You have been given " .. amount .. " credits!")
        player.GetBySteamID(target):addCredits(tonumber(amount), "Console/RCON/Donation")
    else
        local sid64 = util.SteamIDTo64(target)
        NebulaDriver:MySQLUpdate("credits", {
            credits = "credits + " .. tonumber(amount)
        }, "steamid = " .. sid64, function()
            NebulaDriver:MySQLQuery("SELECT credits FROM credits WHERE steamid = " .. sid64, function(data)
                if data and data[1] then
                    MsgN("[NebulaRP] " .. target .. " has been given " .. amount .. " credits. New balance: " .. data[1].credits)
                    NebulaCredits[sid64] = {
                        Credits = data[1].credits,
                        Logs = {}
                    }
                end
            end)
        end)
    end
end)

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

concommand.Add("neb_givebp", function(ply, cmd, args)
    if (IsValid(ply)) then
        return
    end

    local target = table.concat(args, "", 1, 5)
    local bp = args[6]

    if IsValid(player.GetBySteamID(target)) then
        player.GetBySteamID(target):addBattlepass(bp)
    else
        local sid = util.SteamIDTo64(target)
        NebulaDriver:MySQLQuery("SELECT bag FROM credits WHERE steamid = " .. sid64, function(data)
            if data and data[1] then
                local bag = util.JSONToTable(data[1].bag)
                bag[bp] = {
                    level = 0,
                    premium = true,
                    claimed = 0
                }
                NebulaDriver:MySQLUpdate("credits", {
                    bag = util.TableToJSON(bag)
                }, "steamid = " .. sid64, function()
                    MsgN("[NebulaRP] " .. target .. " has been given " .. bp .. " battlepass.")
                end)
            end
        end)
    end
end)

net.Receive("NebulaRP.Credits:Transfer", function(l, pl)
    local result = pl:transferCredits(net.ReadEntity(), net.ReadUInt(32))
    net.Start("NebulaRP.Credits:Transfer")
    net.WriteBool(result)
    net.Send(pl)
end)

net.Receive("NebulaRP.Credits:RequestLogs", function(l, pl)
    if not pl:IsAdmin() then return end

    local target = net.ReadString()
    local page = net.ReadUInt(8)

    if (not NebulaCredits[target]) then
        net.Start("NebulaRP.Credits:RequestLogs")
        net.WriteBool(false)
        net.Send(pl)
        return
    end

    net.Start("NebulaRP.Credits:RequestLogs")
    net.WriteBool(true)
    net.WriteString(target)
    for k = page * 10, (page + 1) * 10 do
        local obj = NebulaCredits[target][k]
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

    if (title == ply:getTitle() or not ply:getTitles()[title]) then
        ply:SetNWString("Title", title)
        NebulaDriver:MySQLUpdate("credits", {
            activetitle = title
        }, "steamid = " .. ply:SteamID64())
    end
end)