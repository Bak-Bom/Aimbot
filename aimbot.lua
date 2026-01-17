local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

_G.AimbotEnabled = true
_G.ESPEnabled = true
_G.Wallbang = false 
_G.FOV = 180
_G.Smooth = 0.08
_G.AimPart = "HumanoidRootPart"
_G.ESPColor = Color3.fromRGB(0,200,255)
_G.ShowDistance = true
_G.DiscordInvite = "https://discord.gg/Z2DbfUgXwE"

local Holding = false
local LockTarget = nil
local ESPObjects = {}


local FOV = Drawing.new("Circle")
FOV.Color = Color3.fromRGB(0,200,255)
FOV.Thickness = 2
FOV.NumSides = 100
FOV.Transparency = 0.8
FOV.Filled = false
FOV.Visible = true

local gui = Instance.new("ScreenGui", game.CoreGui)

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.fromOffset(52,52)
btn.Position = UDim2.fromScale(0.92,0.5)
btn.Text = "🎯"
btn.TextSize = 22
btn.BackgroundColor3 = Color3.fromRGB(0,200,255)
btn.TextColor3 = Color3.new(1,1,1)
btn.Active = true
btn.Draggable = true
Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)

local panel = Instance.new("Frame", gui)
panel.Size = UDim2.fromOffset(250,230)
panel.Position = UDim2.fromScale(0.5,0.5)
panel.AnchorPoint = Vector2.new(0.5,0.5)
panel.BackgroundColor3 = Color3.fromRGB(18,22,28)
panel.Visible = false
panel.Active = true
panel.Draggable = true
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,16)

local title = Instance.new("TextLabel", panel)
title.Size = UDim2.new(1,0,0,32)
title.Text = "NEON AIM PANEL"
title.Font = Enum.Font.GothamBold
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(0,200,255)
title.BackgroundTransparency = 1

local credit = Instance.new("TextLabel", panel)
credit.Position = UDim2.fromOffset(0,30)
credit.Size = UDim2.new(1,0,0,16)
credit.Text = "By BakBomDev"
credit.Font = Enum.Font.Gotham
credit.TextSize = 11
credit.TextColor3 = Color3.fromRGB(150,180,200)
credit.BackgroundTransparency = 1

local aimbotBtn = Instance.new("TextButton", panel)
aimbotBtn.Position = UDim2.fromOffset(20,50)
aimbotBtn.Size = UDim2.fromOffset(210,30)
aimbotBtn.Text = "AIMBOT : ON"
aimbotBtn.Font = Enum.Font.GothamBold
aimbotBtn.TextSize = 12
aimbotBtn.TextColor3 = Color3.new(1,1,1)
aimbotBtn.BackgroundColor3 = Color3.fromRGB(0,200,255)
Instance.new("UICorner", aimbotBtn).CornerRadius = UDim.new(0,10)

aimbotBtn.MouseButton1Click:Connect(function()
	_G.AimbotEnabled = not _G.AimbotEnabled
	aimbotBtn.Text = _G.AimbotEnabled and "AIMBOT : ON" or "AIMBOT : OFF"
end)

local wallBtn = Instance.new("TextButton", panel)
wallBtn.Position = UDim2.fromOffset(20,85)
wallBtn.Size = UDim2.fromOffset(210,30)
wallBtn.Text = "MODE : NORMAL"
wallBtn.Font = Enum.Font.GothamBold
wallBtn.TextSize = 12
wallBtn.TextColor3 = Color3.new(1,1,1)
wallBtn.BackgroundColor3 = Color3.fromRGB(255,120,60)
Instance.new("UICorner", wallBtn).CornerRadius = UDim.new(0,10)

wallBtn.MouseButton1Click:Connect(function()
	_G.Wallbang = not _G.Wallbang
	wallBtn.Text = _G.Wallbang and "MODE : WALLBANG" or "MODE : NORMAL"
end)

local espBtn = Instance.new("TextButton", panel)
espBtn.Position = UDim2.fromOffset(20,120)
espBtn.Size = UDim2.fromOffset(210,30)
espBtn.Text = "ESP : ON"
espBtn.Font = Enum.Font.GothamBold
espBtn.TextSize = 12
espBtn.TextColor3 = Color3.new(1,1,1)
espBtn.BackgroundColor3 = Color3.fromRGB(40,180,200)
Instance.new("UICorner", espBtn).CornerRadius = UDim.new(0,10)

espBtn.MouseButton1Click:Connect(function()
	_G.ESPEnabled = not _G.ESPEnabled
	espBtn.Text = _G.ESPEnabled and "ESP : ON" or "ESP : OFF"
end)

local discordBtn = Instance.new("TextButton", panel)
discordBtn.Position = UDim2.fromOffset(20,160)
discordBtn.Size = UDim2.fromOffset(210,30)
discordBtn.Text = "🔗 Discord Server"
discordBtn.Font = Enum.Font.GothamBold
discordBtn.TextSize = 12
discordBtn.TextColor3 = Color3.new(1,1,1)
discordBtn.BackgroundColor3 = Color3.fromRGB(88,101,242)
Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0,10)

discordBtn.MouseButton1Click:Connect(function()
	if setclipboard then
		setclipboard(_G.DiscordInvite)
	end
end)

btn.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)

local function Visible(part)
	if _G.Wallbang then return true end
	local origin = Camera.CFrame.Position
	local dir = (part.Position - origin)
	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {LocalPlayer.Character}
	params.FilterType = Enum.RaycastFilterType.Blacklist
	local ray = workspace:Raycast(origin, dir, params)
	return ray and ray.Instance:IsDescendantOf(part.Parent)
end

local function GetTarget()
	local best, dist = nil, _G.FOV
	local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

	for _,p in pairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local hum = p.Character:FindFirstChild("Humanoid")
			local part = p.Character:FindFirstChild(_G.AimPart)
			if hum and hum.Health > 0 and part and Visible(part) then
				local pos, on = Camera:WorldToViewportPoint(part.Position)
				if on then
					local mag = (Vector2.new(pos.X,pos.Y)-center).Magnitude
					if mag < dist then
						dist = mag
						best = part
					end
				end
			end
		end
	end
	return best
end

local function CreateESP(player)
	if player == LocalPlayer then return end
	local text = Drawing.new("Text")
	text.Size = 14
	text.Center = true
	text.Outline = true
	text.Font = 2
	text.Color = _G.ESPColor
	text.Visible = false
	ESPObjects[player] = text
end

for _,p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

UIS.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton2
	or i.UserInputType == Enum.UserInputType.Touch then
		Holding = true
	end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton2
	or i.UserInputType == Enum.UserInputType.Touch then
		Holding = false
		LockTarget = nil
	end
end)

RunService.RenderStepped:Connect(function()
	FOV.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	FOV.Radius = _G.FOV

	if Holding and _G.AimbotEnabled then
		if not LockTarget then
			LockTarget = GetTarget()
		end
		if LockTarget then
			local cf = CFrame.new(Camera.CFrame.Position, LockTarget.Position)
			Camera.CFrame = Camera.CFrame:Lerp(cf, 1 - _G.Smooth)
		end
	end

	for player,esp in pairs(ESPObjects) do
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")
		if _G.ESPEnabled and hrp and hum and hum.Health > 0 then
			local pos, on = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,2,0))
			if on then
				local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
				esp.Text = string.format("%s [%.0fm]", player.Name, dist)
				esp.Position = Vector2.new(pos.X,pos.Y)
				esp.Visible = true
			else
				esp.Visible = false
			end
		else
			esp.Visible = false
		end
	end
end)
