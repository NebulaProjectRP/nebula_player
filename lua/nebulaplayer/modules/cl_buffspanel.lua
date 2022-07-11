local PANEL = {}
PANEL.Buffs = {}

local lightWhite = Color(255, 255, 255, 100)

function PANEL:Init()
    BuffPanel = self
    self.Buffs = {}
    self:SetSize(200, 118)
    self:AlignBottom(32)
    self:AlignLeft(300)

    self.Status = vgui.Create("Panel", self)
    self.Status:Dock(FILL)
    self.Status:DockMargin(0, 24, 0, 4)
end

function PANEL:AddBuff(id, duration)

    if (IsValid(self.Buffs[id])) then
        self.Buffs[id].life = 0
        self.Buffs[id].max = duration
        return
    end

    local data = NebulaBuffs.buffs[id]
    if not data then MsgN("no data") return end

    local line = vgui.Create("DPanel", self.Status)
    line:Dock(TOP)
    line:DockMargin(0, 0, 0, 4)
    line:SetTall(26)
    line.life = 0
    line.max = duration
    line.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(255, 255, 255, 10))
        draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(20, 7, 20, 200))
        draw.SimpleText(data.Name, NebulaUI:Font(16), 4, 0, lightWhite)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(4, 16, w - 8, h - 20)

        surface.SetDrawColor(lightWhite)
        surface.DrawRect(4, 16, (w - 8) * (1 - s.life / s.max), h - 20)

        s.life = s.life + FrameTime()
        if (s.life > duration) then
            self.Buffs[id] = nil
            s:Remove()
            if (table.IsEmpty(self.Buffs)) then
                self:AlphaTo(0, .25, 0, function()
                    self:Remove()
                end)
            end
        end
    end
    self.Buffs[id] = line
end

function PANEL:Paint(w, h)
    draw.SimpleText("STATUS:", NebulaUI:Font(16), 4, 0, lightWhite)
    surface.SetDrawColor(lightWhite)
    surface.DrawRect(0, 18, w, 1)
end

vgui.Register("nebulaui.buffs", PANEL, "PANEL")

if IsValid(BuffPanel) then
    BuffPanel:Remove()
end
