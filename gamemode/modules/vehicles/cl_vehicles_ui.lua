local PANEL = {}

surface.CreateFont("Fusion_Dealer_Title", {
    font = "Bebas Neue",
    size = ScreenScale(13),
    weight = 500,
    antialias = true
})

surface.CreateFont("Fusion_Dealer_Button", {
    font = "Bebas Neue",
    size = ScreenScale(8),
    weight = 500,
    antialias = true
})

function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:MakePopup()

    self.selected = nil
    self.vehicle = nil

    self.details = self:Add("DPanel")
    self.details:SetSize(ScrW() * .156, ScrH() * .555)
    self.details:SetPos(-self.details:GetWide(), ScrH() - self.details:GetTall())
    self.details:TDLib():Background(Color(30, 30, 30))
    self.details:MoveTo(0, ScrH() - self.details:GetTall(), 0.4, 0, 0.2, function() end)

    self.title = self.details:Add("DLabel")
    self.title:SetFont("Fusion_Dealer_Title")
    self.title:SetText("Vehicle Dealership")
    self.title:SetTextColor(color_white)
    self.title:SizeToContents()
    self.title:Dock(TOP)
    self.title:DockMargin(5, 5, 5, 0)

    self.panel = self.details:Add("DScrollPanel")
    self.panel:Dock(FILL)
    self.panel:DockMargin(5, 8, 5, 5)
    self.panel:TDLib():Background(Color(20, 20, 20))
    self.panel:HideVBar()

    self:Load()
end

function PANEL:Load()
    if !Fusion.vehicles.make or !Fusion.vehicles.cache then
        self:Remove()
        return
    end

    isViewingCar = true

    if IsValid(self.vehicle) then
        self.vehicle:Remove()
        self.vehicle = nil
    end

    self.cat = {}

    self.title:SetText("Vehicle Dealership")

    for k, v in pairs(Fusion.vehicles.make) do
        self.cat[k] = self.panel:Add("DButton")
        self.cat[k]:TDLib():ClearPaint()
        self.cat[k]:SetTall(ScrH() * .027)
        self.cat[k]:Dock(TOP)
        self.cat[k]:DockMargin(5, 5, 5, 0)
        self.cat[k]:Background(Color(30, 30, 30)):BarHover(Color(64, 160, 255))
        self.cat[k]:Text(k, "Fusion_Dealer_Button")
        self.cat[k].category = v
        self.cat[k]:On("DoClick", function(s)
            self.details:MoveTo(-self.details:GetWide(), ScrH() - self.details:GetTall(), 0.4, 0, 0.2, function()
                self:ShowCategory(s.category, k)

                self.details:MoveTo(0, ScrH() - self.details:GetTall(), 0.4, 0, 0.2, function() end)
            end)
        end)
    end
end

function PANEL:ShowCategory(tbl, name)
    self.veh = {}

    self.title:SetText(name)

    for k, v in pairs(self.cat) do
        v:Remove()
    end

    self.back = self.details:Add("DButton")
    self.back:TDLib():ClearPaint()
    self.back:SetTall(ScrH() * .021)
    self.back:Dock(BOTTOM)
    self.back:DockMargin(5, 0, 5, 5)
    self.back:Background(Color(37, 37, 37)):FadeHover(Color(44, 44, 44))
    self.back:Text("Back", "Fusion_Dealer_Button")
    self.back:On("DoClick", function(s)
        if IsValid(self.cust) then
            self.cust:MoveTo(ScrW(), ScrH() - self.cust:GetTall(), 0.4, 0, 0.2, function()
                self.cust:Remove()
            end)
        end

        self.details:MoveTo(-self.details:GetWide(), ScrH() - self.details:GetTall(), 0.4, 0, 0.2, function()
            for k, v in pairs(self.veh) do
                v:Remove()
            end

            s:Remove()

            self:Load()

            self.details:MoveTo(0, ScrH() - self.details:GetTall(), 0.4, 0, 0.2, function() end)
        end)
    end)

    for k, v in pairs(tbl) do
        self.veh[k] = self.panel:Add("DButton")
        self.veh[k]:TDLib():ClearPaint()
        self.veh[k]:SetTall(ScrH() * .027)
        self.veh[k]:Dock(TOP)
        self.veh[k]:DockMargin(5, 5, 5, 0)
        self.veh[k]:Background(Color(30, 30, 30)):FadeHover(Color(37, 37, 37))
        self.veh[k]:Text(v.name, "Fusion_Dealer_Button")
        self.veh[k].vehicle = v
        self.veh[k]:On("DoClick", function(s)
            self.selected = v
            self:MakeVehicle(self.selected)
            self:ShowCustomization()
        end)
    end
end

function PANEL:ShowCustomization()
    if IsValid(self.cust) then
        self.cust:Remove()
    end

    self.cust = self:Add("DPanel")
    self.cust:TDLib():ClearPaint()
    self.cust:SetSize(ScrW() * .156, ScrH() * .277)
    self.cust:SetPos(ScrW(), ScrH() - self.cust:GetTall())
    self.cust:Background(Color(30, 30, 30))
    self.cust:MoveTo(ScrW() - self.cust:GetWide(), ScrH() - self.cust:GetTall(), 0.4, 0, 0.2, function() end)

    self.c_title = self.cust:Add("DLabel")
    self.c_title:Dock(TOP)
    self.c_title:DockMargin(5, 5, 5, 0)
    self.c_title:SetFont("Fusion_Dealer_Title")
    self.c_title:SetText("Customization")
    self.c_title:SetTextColor(color_white)
    self.c_title:SizeToContents()

    self.c_panel = self.cust:Add("DScrollPanel")
    self.c_panel:TDLib():ClearPaint()
    self.c_panel:Dock(FILL)
    self.c_panel:DockMargin(5, 5, 5, 5)
    self.c_panel:Background(Color(20, 20, 20))
    self.c_panel:HideVBar()

    self.paint = self.c_panel:Add("DColorMixer")
    self.paint:Dock(TOP)
    self.paint:DockMargin(5, 5, 5, 0)
    self.paint:SetAlphaBar(false)
    self.paint:SetColor(Color(255, 255, 255))
end

function PANEL:MakeVehicle(tbl)
    if !Fusion.vehicles.cache[tbl.id] then return end
    if !isViewingCar then return end

    if IsValid(self.vehicle) then
        self.vehicle:Remove()
        self.vehicle = nil
    end

    self.vehicle = ents.CreateClientProp()
    self.vehicle:SetModel(tbl.model)
    self.vehicle:SetPos(Fusion.vehicles.config.vehicle_pos)
    self.vehicle:SetAngles(Fusion.vehicles.config.vehicle_ang)
    self.vehicle:SetColor(Color(255, 255, 255))
    self.vehicle:Spawn()
end

hook.Add("CalcView", "ViewCarView", function(ply, pos, angles, fov)
	if isViewingCar then
		local view = {}
		view.origin = Fusion.vehicles.config.camera_pos
	   	view.angles = Fusion.vehicles.config.camera_ang
	   	view.fov = 75
	   	view.drawviewer = true

		return view
	end
end)

function PANEL:Clear()
    for k, v in pairs(self.cat) do
        v:Remove()
    end

    self.cat = {}
end

function PANEL:Think()
    if IsValid(self.vehicle) then
        self.vehicle:SetAngles(self.vehicle:GetAngles() + Angle(0, 0.1, 0))
        self.vehicle:SetColor(self.paint:GetColor())
    end

	if (input.IsKeyDown(KEY_F1)) then
		self:Remove()
		Fusion.vehicles.panel = nil
        isViewingCar = nil

        if self.vehicle then
            self.vehicle:Remove()
            self.vehicle = nil
        end
	end
end

vgui.Register("FusionVehicles", PANEL, "EditablePanel")

local function open()
    if Fusion.vehicles.panel then
        Fusion.vehicles.panel:Remove()
        Fusion.vehicles.panel = nil
    end

    Fusion.vehicles.panel = vgui.Create("FusionVehicles")
end
concommand.Add("cars", function() open() end)
