local maxDist = 256 * 256

hook.Add("PostPlayerDraw", "TxTransform", function(ply)
    if not ply:Alive() then return end
    if not ply:hasCosmeticTitle() then return end
    if ply:GetColor().a < 50 then return end
    if ply:EyePos():DistToSqr(LocalPlayer():EyePos()) > maxDist then return end
    local transform = NebulaPremium.TextDecorators[ply:GetNWString("HeadAnim", "default")]
    if not transform then return end

    if not ply._headBone then
        ply._headBone = ply:LookupBone("ValveBiped.Bip01_Head1")
        local tag_name = ply:SteamID() .. "_modelCheck"
        local ply_model = ply:GetModel()

        timer.Create(tag_name, 10, 1, function()
            if not IsValid(ply) then
                timer.Remove(tag_name)

                return
            end

            if ply:IsDormant() then return end
            if ply:GetModel() == ply_model then return end
            ply._headBone = ply:LookupBone("ValveBiped.Bip01_Head1")
        end)
    end

    local pos, _ = ply:GetBonePosition(ply._headBone or 0)
    pos = pos + Vector(0, 0, 24)
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
    self.Title:SetText(LocalPlayer():GetNWString("HeadText", "Hello world!"))
    self.Title:SetMaxLetters(48)
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
        self.Anim:AddChoice(v.name, k, LocalPlayer():GetNWString("HeadAnim", "default") == k)
    end

    self.Style = vgui.Create("nebula.combobox", self)
    self.Style:Dock(TOP)
    self.Style:SetTall(24)
    self.Style:DockMargin(0, 0, 0, 8)

    for k, v in pairs(NebulaPremium.TextStyles) do
        self.Style:AddChoice(k[1]:upper() .. k:sub(2), k, LocalPlayer():GetNWString("HeadStyle", "default") == k)
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
        local ply = LocalPlayer()
        local oldtext, oldanim, oldStyle = ply:GetNWString("HeadText"), ply:GetNWString("HeadAnim"), ply:GetNWString("HeadStyle")
        local text, animation, style = self.Title:GetText(), self.Anim:GetOptionData(self.Anim:GetSelectedID()), self.Style:GetOptionData(self.Style:GetSelectedID())
        local price = (oldtext ~= text and 200 or 0) + (oldanim ~= animation and NebulaPremium.TextDecorators[animation].price or 0) + (oldStyle ~= style and 100 or 0)

        if price == 0 then
            self:Remove()

            return
        end

        if LocalPlayer():getCredits() < price then
            Derma_Message("Your changes costs " .. price .. " credits that you cannot afford", "Error", "OK")

            return
        end

        Derma_Query("Are you sure you want to change your title? This will cost you " .. price .. " credits.", "Confirm", "Yes", function()
            net.Start("NebulaPremium.Title")
            net.WriteString(text)
            net.WriteString(animation)
            net.WriteString(style)
            net.SendToServer()
        end, "No", function() end)

        self:Remove()
    end
end

function PANEL:DrawPreview(w, h)
    local text = self.Title:GetText()
    local data = self.Anim:GetOptionData(self.Anim:GetSelectedID())
    local anim = NebulaPremium.TextDecorators[data]
    anim.display(LocalPlayer(), text, NebulaUI:Font(28), self.Style:GetText():lower(), w / 2, h / 2)
end

vgui.Register("nebula.cosmeticTitle", PANEL, "nebula.frame")