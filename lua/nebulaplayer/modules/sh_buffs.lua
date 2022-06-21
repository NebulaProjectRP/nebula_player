if SERVER then
    util.AddNetworkString("NebulaRP.SendBuff")
end

NebulaBuffs = NebulaBuffs or {
    buffs = {}
}

local buffMeta = {
    Remove = function(s)
        local owner = s:GetOwner()

        if SERVER then
            net.Start("NebulaRP.SendBuff")
            net.WriteString(s.ID)
            net.WriteFloat(0)
            net.WriteBool(s.Global)
            if (s.Global) then
                net.WriteEntity(owner)
                net.Broadcast()
            else
                net.Send(owner)
            end
        end
        s:ApplyStats()
        if (s.looper) then
            s.looper:Remove()
        end

        if (s.extraSpeed) then
            owner:SetRunSpeed(owner:GetRunSpeed() - s.extraSpeed)
        end

        if (s.extraHealth) then
            owner:SetMaxHealth(owner:GetMaxHealth() - s.extraHealth)
        end

        s:GetOwner().buffs[s.ID] = nil
    end,
    ApplyStats = function(s)
        local stats = s.Stats
        local owner = s:GetOwner()
        if (stats.Speed) then
           s.extraSpeed = owner:GetRunSpeed() * stats.Speed
            owner:SetRunSpeed(owner:GetRunSpeed() + s.extraSpeed)
        end

        if (stats.Health) then
            s.extraHealth = owner:Health() * stats.Health
            owner:SetHealth(owner:Health() + s.extraHealth)
            owner:SetMaxHealth(owner:GetMaxHealth() + s.extraHealth)
        end
    end
}

AccessorFunc(buffMeta, "owner", "Owner")
buffMeta.__index = __index

function NebulaBuffs:Register(id, data)
    self.buffs[id] = data
end

local meta = FindMetaTable("Player")

function meta:addBuff(id, duration)

    local buff = NebulaBuffs.buffs[id]

    if (!buff) then
        ErrorNoHalt("player:addBuff: " .. id .. " is not a valid buff id!")
        return
    end

    local cancel = hook.Run("CanAddBuff", self, id, duration)
    if (cancel == false) then return end
    if (isnumber(cancel)) then
        duration = cancel
    end

    buff = table.Copy(buff)
    setmetatable(buff, buffMeta)
    buff.ID = id
    buff:SetOwner(self)
    buff:SetDuration(duration)

    if (buff.Stackable and (buff.Stacks or 0) < buff.MaxStack) then
        buff.Stacks = buff.Stacks + 1
        buff:ApplyStats()
        buff.looper = self:LoopTimer(id .. "_looper", duration / 2, function()
            if (buff and (buff.RemoveWhole or (buff.Stacks or 0) > 0)) then
                buff.Stacks = buff.Stacks - 1
                if (buff.Stacks == 0) then
                    buff:Remove()
                end
            end
        end)
    end

    if !self.buffs then
        self.buffs = {}
    end

    if SERVER then
        net.Start("NebulaRP.SendBuff")
        net.WriteString(id)
        net.WriteFloat(duration)
        net.WriteBool(buff.Global)
        if (buff.Global) then
            net.WriteEntity(self)
            net.Broadcast()
        else
            net.Send(self)
        end
    end

    if (buff.OnCreate) then
        buff:OnCreate(self)
    end

    self.buffs[id] = buff
    hook.Run("OnBuffAdded", self, id, buff)
end

net.Receive("NebulaRP.SendBuff", function()
    local id = net.ReadString()
    local duration = net.ReadFloat()

    local global = net.ReadBool()
    local ply = global and net.ReadEntity() or LocalPlayer()

    if (duration > 0) then
        ply:addBuff(id, duration)
    elseif (ply.buffs[id]) then
        ply.buffs[id]:Remove()
    end
end)