hook.Add("PostPlayerDraw", "TxTransform", function(ply)
    if not ply:Alive() then return end
    if not ply:hasCosmeticTitle() then return end
    if (ply:GetColor().a < 50) then return end
    local transform = NebulaPremium.TextDecorators[ply:GetNWString("HeadAnim", "default")]
    if not transform then return end
    local pos = ply:GetShootPos() + Vector(0, 0, 8)
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    cam.Start3D2D(pos, Angle(0, ang.y + 0, 90), 0.1)
    transform.display(ply, ply:GetNWString("HeadText", ""), NebulaUI:Font(32), ply:GetNWString("HeadStyle", "default"))
    cam.End3D2D()
end)

local PANEL = {}

function PANEL:Init()
    self:SetSize(500, 132 + 48 + 96 + 48)
    self:SetTitle("Title Editor")
    self:MakePopup()
    self:Center()
    self.Title = vgui.Create("nebula.textentry", self)
    self.Title:Dock(TOP)
    self.Title:SetTall(24)
    self.Title:SetText("Hello world!")
    self.Title:DockMargin(0, 0, 0, 8)
    local label = Label("Animation", self)
    label:SetFont(NebulaUI:Font(20))
    label:Dock(TOP)
    label:SetTall(20)
    label:SetTextColor(color_white)
    label:DockMargin(0, 0, 0, 8)
    self.Anim = vgui.Create("nebula.combobox", self)
    self.Anim:Dock(TOP)
    self.Anim:SetTall(24)
    self.Anim:DockMargin(0, 0, 0, 8)

    for k, v in pairs(NebulaPremium.TextDecorators) do
        self.Anim:AddChoice(v.name, k, true)
    end

    self.Style = vgui.Create("nebula.combobox", self)
    self.Style:Dock(TOP)
    self.Style:SetTall(24)
    self.Style:DockMargin(0, 0, 0, 8)

    for k, v in pairs(NebulaPremium.TextStyles) do
        self.Style:AddChoice(k[1]:upper() .. k:sub(2), k, true)
    end

    self.Preview = vgui.Create("DPanel", self)
    self.Preview:Dock(TOP)
    self.Preview:SetTall(96)
    self.Preview:DockMargin(0, 0, 0, 8)

    self.Preview.Paint = function(s, w, h)
        self:DrawPreview(w, h)
    end

    self.Save = vgui.Create("nebula.button", self)
    self.Save:Dock(FILL)
    self.Save:SetText("Save")

    self.Save.DoClick = function()
        net.Start("NebulaRP.Credits:ChangeCosmeticTitle")
        net.WriteString(self.Title:GetText())
        net.WriteString(self.Anim:GetOptionData(self.Anim:GetSelectedID()))
        net.WriteString(self.Style:GetOptionData(self.Style:GetSelectedID()))
        net.SendToServer()
    end
end

function PANEL:DrawPreview(w, h)
    local text = self.Title:GetText()
    local data = self.Anim:GetOptionData(self.Anim:GetSelectedID())
    local anim = NebulaPremium.TextDecorators[data]
    anim.display(LocalPlayer(), text, NebulaUI:Font(28), self.Style:GetText():lower(), w / 2, h / 2)
end

vgui.Register("nebula.cosmeticTitle", PANEL, "nebula.frame")