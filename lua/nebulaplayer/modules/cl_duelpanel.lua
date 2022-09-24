local PANEL = {}

function PANEL:Init()
    if IsValid(DUEL_PANEL) then
        DUEL_PANEL:Remove()
    end

    DUEL_PANEL = self
    self:SetAlpha(0)
    self:AlphaTo(255, .25, 0)
    self:SetSize(ScrW(), ScrH())
    self.Players = {}
    self.Poly = {}
    self.Progress = 0
    self.Wait = 2
    self.MustReturn = false
    self.LocalName = LocalPlayer():Nick()
    self.EnemyName = "Enemy"
    self.IsReady = false
    surface.PlaySound("nebularp/duel_start.wav")
    self:BuildPoly()
end

function PANEL:BuildPlayers(enemy)
    self.lavatar = vgui.Create("AvatarImage", self)
    self.lavatar:SetSize(64, 64)
    self.lavatar:SetPlayer(LocalPlayer(), 64)
    self.lavatar:SetPaintedManually(true)
    self.ravatar = vgui.Create("AvatarImage", self)
    self.ravatar:SetSize(64, 64)
    self.ravatar:SetPlayer(enemy, 64)
    self.ravatar:SetPaintedManually(true)
    self.EnemyEnt = enemy
    self.EnemyName = enemy:Nick()
    self.IsReady = true

    self.PlayerLeft = vgui.Create("DModelPanel", self)
    self.PlayerLeft:SetModel(LocalPlayer():GetModel())
    self.PlayerLeft:SetSize(ScrW() / 2, ScrH())
    self.PlayerLeft:SetPos(0, 0)
    self.PlayerLeft:SetPaintedManually(true)
    self.PlayerLeft.LayoutEntity = function() end
    self.PlayerLeft:SetCamPos(Vector(40, -60, 65))
    self.PlayerLeft:SetLookAt(Vector(0, 0, 55))
    self.PlayerLeft:SetFOV(35)
    self.PlayerLeft:GetEntity():ResetSequence("menu_combine")

    self.PlayerRight = vgui.Create("DModelPanel", self)
    self.PlayerRight:SetModel(enemy:GetModel())
    self.PlayerRight:SetPaintedManually(true)
    self.PlayerRight:SetSize(ScrW() / 2, ScrH())
    self.PlayerRight:SetPos(ScrW() / 2, 0)
    self.PlayerRight.LayoutEntity = function() end
    self.PlayerRight:SetCamPos(Vector(40, 60, 65))
    self.PlayerRight:SetLookAt(Vector(0, 0, 55))
    self.PlayerRight:SetFOV(35)
    self.PlayerRight:GetEntity():ResetSequence("menu_combine")
    LocalPlayer().DuelEnemy = enemy
end

local lines = Material("nebularp/ui/duel_lines")
local gradient = Material("gui/center_gradient")
function PANEL:BuildPoly()
    local poly_left = {
        {
            x = 0,
            y = 0,
            u = 0,
            v = 0
        },
        {
            x = 0,
            y = 0,
            u = 1,
            v = 0
        },
        {
            x = 0,
            y = ScrH(),
            u = 1,
            v = 1
        },
        {
            x = 0,
            y = ScrH(),
            u = 0,
            v = 1
        }
    }

    local poly_right = {
        {
            x = ScrW(),
            y = 0,
            u = 0,
            v = 0
        },
        {
            x = ScrW(),
            y = 0,
            u = 1,
            v = 0,
        },
        {
            x = ScrW(),
            y = ScrH(),
            u = 1,
            v = 1
        },
        {
            x = ScrW(),
            y = ScrH(),
            u = 0,
            v = 1
        }
    }

    self.Poly = {
        [1] = poly_left,
        [2] = poly_right
    }
end

local color_red = Color(247, 70, 70)
local color_blue = Color(98, 149, 245)
local color_red2 = Color(170, 29, 29)
local color_blue2 = Color(30, 85, 187)

function PANEL:Paint(w, h)
    if not self.IsReady then return end
    local doMove = false

    if not self.MustReturn and self.Progress < 1 then
        doMove = true
        self.Progress = math.min(self.Progress + FrameTime() * 3, 1)
    elseif not self.MustReturn and self.Progress == 1 and self.Wait > 0 then
        self.Wait = math.max(self.Wait - FrameTime(), 0)

        if self.Wait == 0 then
            self.MustReturn = true
            self.PlayerLeft:MoveTo(-ScrW() / 2, 0, .5, 0)
            self.PlayerRight:MoveTo(ScrW(), 0, .5, 0)
        end
    elseif self.MustReturn and self.Progress > 0 then
        doMove = true
        self.Progress = math.max(self.Progress - FrameTime() * 3, 0)

        if self.Progress == 0 then
            self:Remove()

            return
        end
    end

    if doMove then
        self.Poly[1][2].x = Lerp(self.Progress, 0, w / 2 + w / 6)
        self.Poly[1][3].x = Lerp(self.Progress, 0, w / 2 - w / 6)
        self.Poly[2][1].x = Lerp(self.Progress, w, w / 2 + w / 6)
        self.Poly[2][4].x = Lerp(self.Progress, w, w / 2 - w / 6)
        self.PlayerLeft:SetLookAt(Vector(60 - self.Progress * 60, 0, 55))
        self.PlayerRight:SetLookAt(Vector(60 - self.Progress * 60, 0, 55))
    end

    surface.SetAlphaMultiplier(self.Progress)

    draw.NoTexture()
    surface.SetDrawColor(color_blue2)
    surface.DrawPoly(self.Poly[1])
    surface.SetDrawColor(color_red2)
    surface.DrawPoly(self.Poly[2])

    surface.SetMaterial(gradient)
    surface.SetDrawColor(color_blue)
    surface.DrawPoly(self.Poly[1])
    surface.SetDrawColor(color_red)
    surface.DrawPoly(self.Poly[2])

    surface.SetMaterial(lines)
    surface.SetDrawColor(color_white)
    //surface.SetDrawColor(255, 145, 0, 255)
    surface.DrawPoly(self.Poly[1])
    //surface.SetDrawColor(0, 238, 255, 255)
    surface.DrawPoly(self.Poly[2])

    self.PlayerRight:PaintManual()
    self.PlayerLeft:PaintManual()
    local tx, _ = draw.SimpleText(self.EnemyName, NebulaUI:Font(42), w / 2 + w / 4, h - h * .2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(self.EnemyEnt:GetNWInt("DuelsWins", 0), NebulaUI:Font(48, true), w / 2 + w / 4 - tx / 2 - 12, h - h * .2, color_blue, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    self.ravatar:SetPos(w / 2 + w / 4 + tx / 2 + 8, h - h * .2 - 32)
    self.ravatar:PaintManual()

    tx, _ = draw.SimpleText(self.LocalName, NebulaUI:Font(42), w / 4, h - h * .2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(LocalPlayer():GetNWInt("DuelsWins", 0), NebulaUI:Font(48, true), w / 4 + tx / 2 + 12, h - h * .2, color_red, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    self.lavatar:SetPos(w / 4 - tx / 2 - 72, h - h * .2 - 32)
    self.lavatar:PaintManual()

    draw.SimpleText("VS", NebulaUI:Font(96), w / 2, h / 2 - 100 * (1 - self.Progress), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    surface.SetAlphaMultiplier(1)

end

vgui.Register("nebula.microduel", PANEL, "DPanel")
local rope = Material("trails/physbeam")

hook.Add("PostDrawTranslucentRenderables", "DuelMaster.Main", function()
    local ply = LocalPlayer()
    if not ply:IsDueling() or not IsValid(ply.DuelEnemy) then return end
    local enemy = ply.DuelEnemy
    render.SetMaterial(rope)
    cam.IgnoreZ(true)
    render.DrawBeam(ply:GetPos(), enemy:GetPos(), 16, RealTime(), RealTime() - 1, color_white)
    cam.IgnoreZ(false)
end)

local stalemate = CreateConVar("nebula_stalemate_timer", "90", {FCVAR_ARCHIVE, FCVAR_REPLICATED})
net.Receive("NebulaDuels.MiniDuel", function()
    local a = net.ReadEntity()
    local b = net.ReadEntity()
    local duel = vgui.Create("nebula.microduel")
    duel:BuildPlayers(a == LocalPlayer() and b or a)

    if IsValid(MiniduelTimer) then
        MiniduelTimer:Remove()
    end

    MiniduelTimer = vgui.Create("DPanel")
    MiniduelTimer:SetSize(128, 72)
    MiniduelTimer:SetAlpha(0)
    MiniduelTimer:AlphaTo(255, .25)
    MiniduelTimer:SetPos(ScrW() / 2 - 64, -72)
    MiniduelTimer:MoveTo(ScrW() / 2 - 64, 72, 0.5, 0, 1)
    MiniduelTimer.Remaining = stalemate:GetInt()

    LocalPlayer():SetNW2Bool("IsDueling", true)
    local dark = Color(0, 0, 0, 200)
    MiniduelTimer.Paint = function(s, w, h)
        if not LocalPlayer():IsDueling() then
            s:Remove()
            return
        end

        s.Remaining = math.max(s.Remaining - FrameTime(), 0)
        draw.RoundedBox(8, 0, 0, w, h, dark)
        draw.SimpleText("Time Remainig", NebulaUI:Font(20), w / 2, 4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText(math.Round(s.Remaining, 1), NebulaUI:Font(42, true), w / 2, 24, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        if (s.Remaining == 0) then
            s:Remove()
        end
    end
end)

local duel = vgui.Create("nebula.microduel")
duel:BuildPlayers(p(2))