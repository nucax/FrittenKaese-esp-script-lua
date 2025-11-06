-- nucax loves frittenfett ihhh wtf
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Frittenkäse"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 340)
Frame.Position = UDim2.new(0, 20, 0, 100)
Frame.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Dragging GUI
local dragging, dragInput, dragStart, startPos
local function update(input)
	local delta = input.Position - dragStart
	Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
	                           startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

-- Connections tracker for cleanup
local connections = {}
local function connect(signal, func)
	local conn = signal:Connect(func)
	table.insert(connections, conn)
	return conn
end

connect(Frame.InputBegan, function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = Frame.Position
		connect(input.Changed, function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

connect(Frame.InputChanged, function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

connect(UserInputService.InputChanged, function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Layout for GUI
local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = Frame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local Minimized = Instance.new("TextButton")
Minimized.Size = UDim2.new(0, 60, 0, 25)
Minimized.Position = UDim2.new(0, 20, 0, 100)
Minimized.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
Minimized.Text = "Nucax"
Minimized.TextColor3 = Color3.new(0, 0, 0)
Minimized.Font = Enum.Font.SourceSansBold
Minimized.TextSize = 18
Minimized.Visible = false
Minimized.Parent = ScreenGui

-- Toggles and Dropdowns
local function makeToggle(name, default)
	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(1, 0, 0, 25)
	toggle.BackgroundColor3 = Color3.fromRGB(255, 230, 50)
	toggle.TextColor3 = Color3.new(0, 0, 0)
	toggle.Font = Enum.Font.SourceSansBold
	toggle.TextSize = 18
	toggle.Text = name..": "..(default and "ON" or "OFF")
	toggle.Parent = Frame
	local state = default
	connect(toggle.MouseButton1Click, function()
		state = not state
		toggle.Text = name..": "..(state and "ON" or "OFF")
	end)
	return function() return state end
end

local function makeDropdown(name, options, default)
	local drop = Instance.new("TextButton")
	drop.Size = UDim2.new(1, 0, 0, 25)
	drop.BackgroundColor3 = Color3.fromRGB(255, 230, 50)
	drop.TextColor3 = Color3.new(0, 0, 0)
	drop.Font = Enum.Font.SourceSansBold
	drop.TextSize = 18
	drop.Text = name..": "..options[default]
	drop.Parent = Frame
	local index = default
	connect(drop.MouseButton1Click, function()
		index = (index % #options) + 1
		drop.Text = name..": "..options[index]
	end)
	return function() return options[index] end
end

local espHighlightOn = makeToggle("Highlight ESP", false)
local espNameOn = makeToggle("Name ESP", false)
local espDistanceOn = makeToggle("Distance ESP", false)
local espHealthOn = makeToggle("Health ESP", false)
local espTracersOn = makeToggle("Tracers", false)
local tracerPos = makeDropdown("Tracer Pos", {"Top", "Middle", "Bottom"}, 2)

local highlights, billboardGuis, drawings = {}, {}, {}

-- Highlights
local function addHighlight(player)
	if highlights[player] then return end
	local highlight = Instance.new("Highlight")
	highlight.FillColor = Color3.fromRGB(255, 255, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 200, 0)
	highlight.OutlineTransparency = 0
	highlight.Parent = player.Character
	highlights[player] = highlight
end

local function removeHighlight(player)
	if highlights[player] then
		highlights[player]:Destroy()
		highlights[player] = nil
	end
end

-- Billboard Functions for name esp
local function createBillboard(player)
	if billboardGuis[player] then return end
	local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
	if not head then return end
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 200, 0, 50)
	bb.AlwaysOnTop = true
	bb.Name = "FrittenkaeseESP"
	bb.Parent = head

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 16)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.Name = "NameLabel"
	nameLabel.Parent = bb

	local distLabel = Instance.new("TextLabel")
	distLabel.Size = UDim2.new(1, 0, 0, 16)
	distLabel.Position = UDim2.new(0, 0, 0, 16)
	distLabel.BackgroundTransparency = 1
	distLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	distLabel.TextStrokeTransparency = 0
	distLabel.TextScaled = true
	distLabel.Font = Enum.Font.SourceSansBold
	distLabel.Name = "DistLabel"
	distLabel.Parent = bb

	local hpLabel = Instance.new("TextLabel")
	hpLabel.Size = UDim2.new(1, 0, 0, 16)
	hpLabel.Position = UDim2.new(0, 0, 0, 32)
	hpLabel.BackgroundTransparency = 1
	hpLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
	hpLabel.TextStrokeTransparency = 0
	hpLabel.TextScaled = true
	hpLabel.Font = Enum.Font.SourceSansBold
	hpLabel.Name = "HPLabel"
	hpLabel.Parent = bb

	billboardGuis[player] = bb
end

local function removeBillboard(player)
	if billboardGuis[player] then
		billboardGuis[player]:Destroy()
		billboardGuis[player] = nil
	end
end

-- Clear ALL ESP things
local function clearAllESP()
	for _, plr in pairs(Players:GetPlayers()) do
		removeHighlight(plr)
		removeBillboard(plr)
	end
	for _, v in pairs(drawings) do v:Destroy() end
	drawings = {}
end

-- ESP Render Loop
local runESP = true
local function espLoop()
	while runESP do
		for _, v in pairs(drawings) do v:Destroy() end
		drawings = {}

		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") then
				local hrp = player.Character.HumanoidRootPart
				local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

				if espHighlightOn() then addHighlight(player) else removeHighlight(player) end

				if espNameOn() or espDistanceOn() or espHealthOn() then
					createBillboard(player)
					local bb = billboardGuis[player]
					if bb and player.Character then
						bb.Enabled = true
						local head = player.Character:FindFirstChild("Head") or hrp
						bb.Adornee = head
						bb.NameLabel.Text = espNameOn() and player.Name or ""
						bb.DistLabel.Text = espDistanceOn() and (math.floor((Camera.CFrame.Position - hrp.Position).Magnitude).."m") or ""
						bb.HPLabel.Text = espHealthOn() and ("HP: "..math.floor(player.Character.Humanoid.Health)) or ""
					end
				else
					removeBillboard(player)
				end

				if espTracersOn() and onScreen then
					local yOffset = (tracerPos() == "Bottom" and Camera.ViewportSize.Y) or
					               (tracerPos() == "Top" and 0) or
					               (tracerPos() == "Middle" and Camera.ViewportSize.Y / 2)

					local line = Drawing.new("Line")
					line.Color = Color3.fromRGB(255, 255, 0)
					line.Thickness = 1
					line.From = Vector2.new(Camera.ViewportSize.X / 2, yOffset)
					line.To = Vector2.new(pos.X, pos.Y)
					line.Visible = true
					table.insert(drawings, line)
				end
			else
				removeHighlight(player)
				removeBillboard(player)
			end
		end
		RunService.RenderStepped:Wait()
	end
end
task.spawn(espLoop)

-- Player removing cleanup
connect(Players.PlayerRemoving, function(p)
	removeHighlight(p)
	removeBillboard(p)
end)

-- Buttons on GUI
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(1, 0, 0, 25)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "CLOSE"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 18
CloseBtn.Parent = Frame
connect(CloseBtn.MouseButton1Click, function()
	runESP = false
	cleanup()
end)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(1, 0, 0, 25)
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
MinBtn.Text = "MINIMIZE"
MinBtn.TextColor3 = Color3.new(0, 0, 0)
MinBtn.Font = Enum.Font.SourceSansBold
MinBtn.TextSize = 18
MinBtn.Parent = Frame
connect(MinBtn.MouseButton1Click, function()
	Frame.Visible = false
	Minimized.Visible = true
end)

connect(Minimized.MouseButton1Click, function()
	Frame.Visible = true
	Minimized.Visible = false
end)

-- Rainbow footer
local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, 0, 0, 35)
Footer.BackgroundTransparency = 1
Footer.Text = "FRITTENKÄSE\nhttps://github.com/nucax"
Footer.TextScaled = true
Footer.Font = Enum.Font.SourceSansBold
Footer.TextStrokeTransparency = 0
Footer.Parent = Frame

local rainbowRunning = true
task.spawn(function()
	local hue = 0
	while rainbowRunning and Footer.Parent do
		hue = (hue + 0.01) % 1
		Footer.TextColor3 = Color3.fromHSV(hue, 1, 1)
		task.wait(0.03)
	end
end)

-- Cleanup function
function cleanup()
	rainbowRunning = false
	runESP = false
	clearAllESP()
	for _, conn in pairs(connections) do
		if conn.Connected then
			conn:Disconnect()
		end
	end
	connections = {}
	if ScreenGui then
		ScreenGui:Destroy()
		ScreenGui = nil
	end
end
