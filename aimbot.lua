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

local success, Rayfield = pcall(function()
	return loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
end)

if not success then
	warn("Rayfield failed to load")
	return
end

local Window = Rayfield:CreateWindow({
	Name = "โปรอิมบอท",
	LoadingTitle = "Aim bot",
	LoadingSubtitle = "by BakBomDev",
	ConfigurationSaving = { Enabled = false },
	Discord = {
		Enabled = true,
		Invite = "Z2DbfUgXwE"
	},
	KeySystem = false
})

local CombatTab = Window:CreateTab("🎯 Combat", 4483362458)
local VisualTab = Window:CreateTab("👁 Visual", 4483362458)
local MiscTab   = Window:CreateTab("⚙ Misc", 4483362458)

CombatTab:CreateToggle({
	Name = "Aimbot",
	CurrentValue = _G.AimbotEnabled,
	Callback = function(v)
		_G.AimbotEnabled = v
	end
})

CombatTab:CreateToggle({
	Name = "Wallbang Mode",
	CurrentValue = _G.Wallbang,
	Callback = function(v)
		_G.Wallbang = v
	end
})

CombatTab:CreateSlider({
	Name = "Aimbot FOV",
	Range = {50, 500},
	Increment = 5,
	Suffix = " FOV",
	CurrentValue = _G.FOV,
	Callback = function(v)
		_G.FOV = v
	end
})

CombatTab:CreateSlider({
	Name = "Smoothness",
	Range = {0.01, 0.3},
	Increment = 0.01,
	Suffix = " Smooth",
	CurrentValue = _G.Smooth,
	Callback = function(v)
		_G.Smooth = v
	end
})

VisualTab:CreateToggle({
	Name = "ESP Player",
	CurrentValue = _G.ESPEnabled,
	Callback = function(v)
		_G.ESPEnabled = v
	end
})

VisualTab:CreateToggle({
	Name = "Show Distance",
	CurrentValue = _G.ShowDistance,
	Callback = function(v)
		_G.ShowDistance = v
	end
})

MiscTab:CreateButton({
	Name = "📋 Copy Discord Invite",
	Callback = function()
		if setclipboard then
			setclipboard(_G.DiscordInvite)
		end
	end
})

MiscTab:CreateLabel("Status : Running")

local Holding = false
local LockTarget = nil
local ESPObjects = {}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = _G.ESPColor
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Transparency = 0.8
FOVCircle.Filled = false
FOVCircle.Visible = true

local function Visible(part)
	if _G.Wallbang then return true end
	local origin = Camera.CFrame.Position
	local dir = part.Position - origin

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
					local mag = (Vector2.new(pos.X,pos.Y) - center).Magnitude
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

for _,p in pairs(Players:GetPlayers()) do
	CreateESP(p)
end
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
	FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
	FOVCircle.Radius = _G.FOV

	if Holding and _G.AimbotEnabled then
    LockTarget = GetTarget()
    if LockTarget then
        local cf = CFrame.new(Camera.CFrame.Position, LockTarget.Position)
        Camera.CFrame = Camera.CFrame:Lerp(cf, 1 - _G.Smooth)
    end
else
    LockTarget = nil
end

	for player,esp in pairs(ESPObjects) do
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChild("Humanoid")

		if _G.ESPEnabled and hrp and hum and hum.Health > 0 then
			local pos, on = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,2,0))
			if on then
				local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
				esp.Text = _G.ShowDistance
					and string.format("%s [%.0fm]", player.Name, dist)
					or player.Name
				esp.Position = Vector2.new(pos.X, pos.Y)
				esp.Visible = true
			else
				esp.Visible = false
			end
		else
			esp.Visible = false
		end
	end
end)
