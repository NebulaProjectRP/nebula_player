if SERVER then
    util.AddNetworkString("NebulaRP.SendBuff")
end

local meta = FindMetaTable("Player")

function meta:hasBuff(id)
    return (self.buffs or {})[id]
end

function meta:Cleanse()
    for k, v in pairs(self.buffs or {}) do
        v:Remove()
    end
end

NebulaBuffs = NebulaBuffs or {
    buffs = {},
    TakeDamageHooks = {},
    PlayerDrawHooks = {},
    Loopers = {}
}

local buffMeta = {
    Remove = function(s)
        local owner = s:GetOwner()

        if SERVER then
            net.Start("NebulaRP.SendBuff")
            net.WriteString(s.ID)
            net.WriteFloat(0)
            net.WriteBool(s.Global)

            if s.Global then
                net.WriteEntity(owner)
                net.Broadcast()
            else
                net.Send(owner)
            end
        end

        if s.OnRemove then
            s:OnRemove(owner)
        end

        s:ApplyStats()

        if s.looper then
            s.looper:Remove()
        end

        if s.extraSpeed then
            owner:SetRunSpeed(owner:GetRunSpeed() - s.extraSpeed)
        end

        if s.extraHealth then
            owner:SetMaxHealth(owner:GetMaxHealth() - s.extraHealth)
        end

        s:GetOwner().buffs[s.ID] = nil
    end,
    ApplyStats = function(s)
        local stats = s.Stats or {}
        local owner = s:GetOwner()

        if stats.Speed then
            s.extraSpeed = owner:GetRunSpeed() * stats.Speed
            owner:SetRunSpeed(owner:GetRunSpeed() + s.extraSpeed)
        end

        if stats.Health then
            s.extraHealth = owner:Health() * stats.Health
            owner:SetHealth(owner:Health() + s.extraHealth)
            owner:SetMaxHealth(owner:GetMaxHealth() + s.extraHealth)
        end
    end
}

AccessorFunc(buffMeta, "owner", "Owner")
AccessorFunc(buffMeta, "attacker", "Attacker")
AccessorFunc(buffMeta, "duration", "Duration")
buffMeta.__index = buffMeta

function NebulaBuffs:Register(id, data)
    self.buffs[id] = data
    meta["Is" .. string.upper(id[1]) .. string.sub(id, 2)] = function(s, ...) return s:hasBuff(id) end
end

function NebulaBuffs.Think(ply)
    if table.IsEmpty(NebulaBuffs.Loopers or {}) then return end
    local buffs = NebulaBuffs.Loopers[ply]

    if not IsValid(ply) or not ply:Alive() then
        NebulaBuffs.Loopers[ply] = nil

        return
    end

    for id, buff in pairs(buffs or {}) do
        if not ply:hasBuff(id) then
            NebulaBuffs.Loopers[ply][id] = nil

            if table.IsEmpty(NebulaBuffs.Loopers[ply]) then
                NebulaBuffs.Loopers[ply] = nil

                return
            end

            continue
        end

        if (buff.Next or ply.buffs[id].TickInterval) < CurTime() then
            buff.Next = CurTime() + ply.buffs[id].TickInterval
            buff.Fun(ply.buffs[id], ply)
        end
    end
end

hook.Add("PlayerTick", "NebulaBuffs.Tick", NebulaBuffs.Think)

function NebulaBuffs.TakeDamage(ent, dmg, att, inf)
    local result = false

    for ply, buffs in pairs(NebulaBuffs.TakeDamageHooks) do
        if ent ~= ply then continue end

        for id, buff in pairs(buffs) do
            if not ply:hasBuff(id) then
                NebulaBuffs.TakeDamageHooks[ply][id] = nil

                if table.IsEmpty(NebulaBuffs.TakeDamageHooks[ply]) then
                    NebulaBuffs.TakeDamageHooks[ply] = nil

                    return
                end

                continue
            end

            result = buff(ply.buffs[id], ply, dmg, att, inf)
        end
    end

    if result then return true end
end

hook.Add("EntityTakeDamage", "NebulaBuffs.ETD", NebulaBuffs.TakeDamage)

function NebulaBuffs.PlayerDraw(ply)
    if table.IsEmpty(NebulaBuffs.PlayerDrawHooks or {}) or table.IsEmpty(NebulaBuffs.PlayerDrawHooks[ply] or {}) then return end

    for id, buff in pairs(NebulaBuffs.PlayerDrawHooks[ply]) do
        if not ply:hasBuff(id) then
            NebulaBuffs.PlayerDrawHooks[id] = nil

            if table.IsEmpty(NebulaBuffs.PlayerDrawHooks) then
                NebulaBuffs.PlayerDrawHooks = nil

                return
            end

            continue
        end
    end
end

hook.Add("PostPlayerDraw", "NebulaBuffs.PD", NebulaBuffs.PlayerDraw)

hook.Add("PlayerDeath", "NebulaRP.Cleanse", function(ply)
    ply:Cleanse()
end)

function meta:addBuff(id, duration, causer)
    local buff = NebulaBuffs.buffs[id]

    if not buff then
        ErrorNoHalt("player:addBuff: " .. id .. " is not a valid buff id!")

        return
    end

    local cancel = hook.Run("CanAddBuff", self, id, duration)
    if cancel == false then return end

    if isnumber(cancel) then
        duration = cancel
    end

    buff = table.Copy(buff)
    setmetatable(buff, buffMeta)
    buff.ID = id
    buff:SetOwner(self)
    buff:SetDuration(duration)
    buff:SetAttacker(causer or self)

    if buff.Tick then
        if not NebulaBuffs.Loopers[self] then
            NebulaBuffs.Loopers[self] = {}
        end

        NebulaBuffs.Loopers[self][id] = {
            Delay = buff.TickInterval,
            Fun = buff.Tick,
            Owner = self,
            ID = id
        }
    end

    if buff.Stackable and (buff.Stacks or 0) < buff.MaxStack then
        buff.Stacks = (buff.Stacks or 0) + 1
        buff:ApplyStats()

        buff.looper = self:LoopTimer(id .. "_looper", duration / 2, function()
            if buff and (buff.RemoveWhole or (buff.Stacks or 0) > 0) then
                buff.Stacks = buff.Stacks - 1

                if buff.Stacks == 0 then
                    buff:Remove()
                end
            end
        end)
    end

    if not self.buffs then
        self.buffs = {}
    end

    if SERVER then
        net.Start("NebulaRP.SendBuff")
        net.WriteString(id)
        net.WriteFloat(duration)
        net.WriteEntity(causer)
        net.WriteBool(buff.Global)

        if buff.Global then
            net.WriteEntity(self)
            net.Broadcast()
        else
            net.Send(self)
        end

        if buff.TakeDamage then
            if not NebulaBuffs.TakeDamageHooks[self] then
                NebulaBuffs.TakeDamageHooks[self] = {}
            end

            NebulaBuffs.TakeDamageHooks[self][id] = buff.TakeDamage
        end
    elseif buff.PlayerDraw then
        if not NebulaBuffs.PlayerDrawHooks then
            NebulaBuffs.PlayerDrawHooks = {}
        end

        if not NebulaBuffs.PlayerDrawHooks[self] then
            NebulaBuffs.PlayerDrawHooks[self] = {}
        end

        NebulaBuffs.PlayerDrawHooks[self][id] = buff.PlayerDraw
    end

    if CLIENT and self == LocalPlayer() then
        if not IsValid(BuffPanel) then
            BuffPanel = vgui.Create("nebulaui.buffs")
        end

        BuffPanel:AddBuff(id, duration)
    end

    if self.buffs[id] and buff.OnCreate then
        buff:Remove(self, true)

        timer.Simple(0, function()
            buff:OnCreate(self)
        end)
    elseif buff.OnCreate then
        buff:OnCreate(self)
    end

    if not self._buffTimers then
        self._buffTimers = {}
    end

    if duration > 0 then
        if self._buffTimers[id] and self._buffTimers[id].Remove then
            self._buffTimers[id]:Remove()
            self._buffTimers[id] = nil
        end

        self._buffTimers[id] = self:Wait(duration, function()
            hook.Run("OnBuffEnded", self, id, buff)
            buff:Remove()
        end)
    end

    self.buffs[id] = buff
    hook.Run("OnBuffAdded", self, id, buff)
end

function meta:removeBuff(id)
    if self.buffs[id] then
        self.buffs[id]:Remove()
    end
end

net.Receive("NebulaRP.SendBuff", function()
    local id = net.ReadString()
    local duration = net.ReadFloat()
    local causer = net.ReadEntity()
    local global = net.ReadBool()
    local ply = global and net.ReadEntity() or LocalPlayer()

    if duration > 0 then
        ply:addBuff(id, duration, causer)
    elseif ply.buffs and ply.buffs[id] then
        ply.buffs[id]:Remove()
    end
end)

AddCSLuaFile("buffs/season1.lua")
AddCSLuaFile("buffs/fire.lua")
AddCSLuaFile("buffs/ice.lua")
AddCSLuaFile("buffs/weed.lua")
AddCSLuaFile("buffs/shadow.lua")
AddCSLuaFile("buffs/tarot.lua")
include("buffs/shadow.lua")
include("buffs/season1.lua")
include("buffs/fire.lua")
include("buffs/ice.lua")
include("buffs/weed.lua")
include("buffs/tarot.lua")