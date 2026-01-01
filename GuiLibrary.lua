-- Loadstring: https://raw.githubusercontent.com/FZGecko/Nothing/refs/heads/main/GuiLibrary.lua
-- // variables
local library = {}
local pages = {}
local sections = {}
local multisections = {}
local mssections = {}
local toggles = {}
local buttons = {}
local sliders = {}
local dropdowns = {}
local multiboxs = {}
local buttonboxs = {}
local textboxs = {}
local keybinds = {}
local colorpickers = {}
local configloaders = {}
local loaderguis = {}
local huds = {}
local watermarks = {}
local loaders = {}
local activeRainbows = {} -- Centralized table for rainbow pickers

--
local utility = {}
--
local check_exploit = (syn and "Synapse") or (KRNL_LOADED and "Krnl") or (isourclosure and "ScriptWare") or nil
local plrs = game:GetService("Players")
local cre = game:GetService("CoreGui")
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService") 
local uis = game:GetService("UserInputService") 
local hs = game:GetService("HttpService")
local ws = game:GetService("Workspace")
local plr = plrs.LocalPlayer
local cam = ws.CurrentCamera
-- // indexes
library.__index = library
pages.__index = pages
sections.__index = sections
multisections.__index = multisections
mssections.__index = mssections
toggles.__index = toggles
buttons.__index = buttons
sliders.__index = sliders
dropdowns.__index = dropdowns
multiboxs.__index = multiboxs
buttonboxs.__index = buttonboxs
textboxs.__index = textboxs
keybinds.__index = keybinds
colorpickers.__index = colorpickers
configloaders.__index = configloaders
loaderguis.__index = loaderguis
huds.__index = huds
watermarks.__index = watermarks
loaderguis.__index = loaderguis
-- // functions
library.theme = {
	accent = Color3.fromRGB(225, 58, 81),
	background = Color3.fromRGB(20, 20, 20),
	content = Color3.fromRGB(24, 24, 24),
	text = Color3.fromRGB(255, 255, 255),
	outline = Color3.fromRGB(12, 12, 12)
}
utility.new = function(instance,properties) 
	-- // instance
	local ins = Instance.new(instance)
	-- // properties setting
	for property,value in pairs(properties) do
		ins[property] = value
	end
	-- // return
	return ins
end
--
utility.dragify = function(ins,touse,customCondition)
	local dragging
	local dragInput
	local dragStart
	local startPos
	local connections = {}
	local function update(input)
		local delta = input.Position - dragStart
		touse.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
	--
	ins.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if customCondition and not customCondition() then return end
			dragging = true
			dragStart = input.Position
			startPos = touse.Position

			local changedConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
			table.insert(connections, changedConn)
		end
	end)
	
	local inputChangedConn1 = ins.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	table.insert(connections, inputChangedConn1)

	local inputChangedConn2 = uis.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
	table.insert(connections, inputChangedConn2)
	return connections
end
--
utility.round = function(n,d)
	return tonumber(string.format("%."..(d or 0).."f",n))
end
--
utility.zigzag = function(X)
	return math.acos(math.cos(X*math.pi))/math.pi
end
--
utility.capatalize = function(s)
	local l = ""
	for v in s:gmatch('%u') do
		l = l..v
	end
	return l
end
--
utility.splitenum = function(enum)
	local s = tostring(enum):split(".")
	return s[#s]
end
--
utility.from_hex = function(h)
	local r,g,b = string.match(h,"^#?(%w%w)(%w%w)(%w%w)$")
	return Color3.fromRGB(tonumber(r,16), tonumber(g,16), tonumber(b,16))
end
--
utility.to_hex = function(c)
	return string.format("#%02X%02X%02X",c.R *255,c.G *255,c.B *255)
end
--
utility.removespaces = function(s)
   return s:gsub(" ","")
end
-- // main
function library:new(props)
	-- // properties
	local textsize = props.textsize or props.TextSize or props.textSize or props.Textsize or 12
	local font = props.font or props.Font or "RobotoMono"
	local name = props.name or props.Name or props.UiName or props.Uiname or props.uiName or props.username or props.Username or props.UserName or props.userName or "new ui"
	local color = props.color or props.Color or props.mainColor or props.maincolor or props.MainColor or props.Maincolor or props.Accent or props.accent or Color3.fromRGB(225, 58, 81)
	local background = props.background or self.theme.background
	local content = props.content or self.theme.content
	local text = props.text or self.theme.text
	local outline_col = props.outline or self.theme.outline
	-- // variables
	self.theme.accent = color -- Set the library-wide theme color
	local window = {}
	-- // main
	local screen = utility.new(
		"ScreenGui",
		{
			Name = tostring(math.random(0,999999))..tostring(math.random(0,999999)),
			DisplayOrder = 9999,
			ResetOnSpawn = false,
			ZIndexBehavior = "Global",
			Parent = cre
		}
	)
	
	local hudScreen = utility.new(
		"ScreenGui",
		{
			Name = "HUD_" .. tostring(math.random(0,999999)),
			DisplayOrder = 9990, -- Slightly behind main GUI
			ResetOnSpawn = false,
			ZIndexBehavior = "Global",
			Parent = cre
		}
	)
	--
        if (check_exploit == "Synapse" and syn.protect_gui) then
	syn.protect_gui(screen)
	syn.protect_gui(hudScreen)
        end
	-- 1
	local outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = color, -- Accent
			BorderColor3 = outline_col,
			BorderSizePixel = 1,
			Size = UDim2.new(0,500,0,606),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = screen
		}
	)
	-- 2
	local outline2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0), -- Keep black for contrast
			BorderColor3 = outline_col,
			BorderSizePixel = 1,
			Size = UDim2.new(1,-4,1,-4),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = outline
		}
	)
	-- 3
	local indent = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = background,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = outline2
		}
	)
	-- 4
	local main = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundColor3 = background,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-10,1,-25),
			Position = UDim2.new(0.5,0,1,-5),
			Parent = outline2
		}
	)
	--
	local title = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0.5,0,0,0),
			Parent = outline2
		}
	)
	-- 5
	local outline3 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = content,
			BorderColor3 = outline_col,
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = main
		}
	)
	--
	local titletext = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0,0),
			Font = font,
			Text = name,
			TextColor3 = text,
			TextXAlignment = "Left",
			TextSize = textsize,
			TextStrokeTransparency = 0,
			Parent = title
		}
	)
	-- 6
	local holder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-6,1,-6),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = main
		}
	)
	-- 7
	local holder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-6,1,-6),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = main
		}
	)
	-- 8
	local tabs = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundColor3 = background,
			BorderColor3 = outline_col,
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,-20),
			Position = UDim2.new(0.5,0,1,0),
			Parent = holder
		}
	)
	--
	local tabsbuttons = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,21),
			Position = UDim2.new(0.5,0,0,0),
			ZIndex = 2,
			Parent = holder
		}
	)
	-- 9
	local outline4 = utility.new(
		"Frame",
		{
			BackgroundColor3 = background,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = tabs
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Horizontal",
			Padding = UDim.new(0,2),
			Parent = tabsbuttons
		}
	)
	--
	utility.dragify(title,outline)
	-- // window tbl
	window = {
		["screen"] = screen,
		["hudScreen"] = hudScreen,
		["isOpen"] = true,
		["holder"] = holder,
		["labels"] = {},
		["tabs"] = outline4,
		["tabsbuttons"] = tabsbuttons,
		["outline"] = outline,
		["pages"] = {},
		["pointers"] = {},
		["dropdowns"] = {},
		["multiboxes"] = {},
		["buttonboxs"] = {},
		["colorpickers"] = {},
		["x"] = true,
		["y"] = true,
		["key"] = Enum.KeyCode.RightShift,
		["textsize"] = textsize,
		["font"] = font, 
		["theme"] = self.theme, -- Reference the library's theme
		["themeitems"] = {
			["accent"] = {
				["BackgroundColor3"] = {}, ["BorderColor3"] = {}, ["TextColor3"] = {}
			},
			["background"] = {
				["BackgroundColor3"] = {}
			},
			["content"] = {
				["BackgroundColor3"] = {}
			},
			["text"] = {
				["TextColor3"] = {}
			},
			["outline"] = {
				["BorderColor3"] = {}
			}
		},
		["register"] = function(self, theme, property, object)
			if not self.themeitems[theme] then self.themeitems[theme] = {} end
			if not self.themeitems[theme][property] then self.themeitems[theme][property] = {} end
			table.insert(self.themeitems[theme][property], object)
		end
	}
	--
	table.insert(window.themeitems["accent"]["BackgroundColor3"],outline)
	window:register("background", "BackgroundColor3", indent)
	window:register("background", "BackgroundColor3", main)
	window:register("background", "BackgroundColor3", tabs)
	window:register("background", "BackgroundColor3", outline4)
	window:register("content", "BackgroundColor3", outline3)
	window:register("text", "TextColor3", titletext)
	window:register("outline", "BorderColor3", outline)
	window:register("outline", "BorderColor3", outline2)
	window:register("outline", "BorderColor3", outline3)
	window:register("outline", "BorderColor3", tabs)

	window.connections = {}

	local toggled = true
	local cooldown = false
	local saved = UDim2.new(0,0,0,0)
	--
	local toggleConnection = uis.InputBegan:Connect(function(Input)
		-- Check if the input matches the stored key, regardless of type (KeyCode or UserInputType)
		local isMatch = (Input.KeyCode == window.key) or (Input.UserInputType == window.key)
		if not isMatch then return end

		if cooldown == false then
			if toggled then
				cooldown = true
				toggled = not toggled
				window.isOpen = toggled
				saved = outline.Position
				local xx,yy = 0,0
				local xxx,yyy = 0,0
				--
				if (outline.AbsolutePosition.X+(outline.AbsoluteSize.X/2)) < (cam.ViewportSize.X/2) then
					xx = -3
				else
					xx = 3
				end
				--
				if window.y then
					if (outline.AbsolutePosition.Y+(outline.AbsoluteSize.Y/2)) < (cam.ViewportSize.Y/2) then
						yy = -3
					else
						yy = 3
					end
				else
					yy = saved.Y.Scale
					yyy = saved.Y.Offset
				end
				--
				if window.x == false and window.y == false then
					screen.Enabled = false
				else
					ts:Create(outline, TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.In), {Position = UDim2.new(xx,xxx,yy,yyy)}):Play()
				end
				wait(0.5)
				cooldown = false
			else
				cooldown = true
				toggled = not toggled
				window.isOpen = toggled
				if window.x == false and window.y == false then
					screen.Enabled = true
				else
					ts:Create(outline, TweenInfo.new(0.5,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Position = saved}):Play()
				end
				wait(0.5)
				cooldown = false
			end
		end
	end)
	table.insert(window.connections, toggleConnection)

	local dragConnections = utility.dragify(title,outline)
	for _, c in ipairs(dragConnections) do
		table.insert(window.connections, c)
	end
	window.labels[#window.labels+1] = titletext
	-- // metatable indexing + return
	setmetatable(window, library)
	return window
end
--
function library:watermark()
	local watermark = {}
	--
	local outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = self.theme.accent,
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(0,300,0,26),
			Position = UDim2.new(1,-10,0,10),
			ZIndex = 9900,
			Visible = false,
			Parent = self.screen
		}
	)
	--
	table.insert(self.themeitems["accent"]["BackgroundColor3"],outline)
	--
	local outline2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(1,-4,1,-4),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 9901,
			Parent = outline
		}
	)
	--
	local indent = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 9902,
			Parent = outline2
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0,0),
			Font = self.font,
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextXAlignment = "Left",
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			ZIndex = 9903,
			Parent = indent
		}
	)
	--
	local con
	con = title:GetPropertyChangedSignal("TextBounds"):Connect(function()
		outline.Size = UDim2.new(0,title.TextBounds.X+20,0,26)
	end)
	--
	watermark = {
		["outline"] = outline,
		["outline2"] = outline2,
		["indent"] = indent,
		["title"] = title,
		["connection"] = con
	}
	--
	self.labels[#self.labels+1] = title
	--
	setmetatable(watermark,watermarks)
	return watermark
end
--
function watermarks:update(content)
	local content = content or {}
	local watermark = self
	--
	local text = ""
	--
	for i,v in pairs(content) do
		text = text..i..": "..v.."  "
	end
	--
	text = text:sub(0, -3)
	--
	watermark.title.Text = text
end
--
function watermarks:updateside(side)
	side = utility.removespaces(tostring(side):lower())
	--
	local sides = {
		topright = {
			AnchorPoint = Vector2.new(1,0),
			Position = UDim2.new(1,-10,0,10)
		},
		topleft = {
			AnchorPoint = Vector2.new(0,0),
			Position = UDim2.new(0,10,0,10)
		},
		bottomright = {
			AnchorPoint = Vector2.new(1,1),
			Position = UDim2.new(1,-10,1,-10)
		},
		bottomleft = {
			AnchorPoint = Vector2.new(0,1),
			Position = UDim2.new(0,10,1,-10)
		}
	}
	--
	if sides[side] then
		self.outline.AnchorPoint = sides[side].AnchorPoint
		self.outline.Position = sides[side].Position
	end
end
--
function library:loaderGui(props)
	local name = props.name or "Loading Gui..."
	local color = props.color or self.theme.accent
	local loaderGui = {}

	local screen = utility.new(
		"ScreenGui",
		{
			Name = "LoaderGui_" .. tostring(math.random(0,999999)),
			DisplayOrder = 99999, -- Ensure it's on top of everything
			ResetOnSpawn = false,
			ZIndexBehavior = "Global",
			Parent = cre
		}
	)

	if (check_exploit == "Synapse" and syn.protect_gui) then
		syn.protect_gui(screen)
	end

	local mainFrame = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(0, 300, 0, 100),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Parent = screen
		}
	)

	local titleLabel = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			Position = UDim2.new(0, 0, 0, 10),
			Font = Enum.Font.SourceSansBold, -- Use a default font
			Text = name,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 16, -- Use a default text size
			TextStrokeTransparency = 0,
			TextXAlignment = "Center",
			Parent = mainFrame
		}
	)

	local progressBarBg = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(1, -20, 0, 20),
			Position = UDim2.new(0, 10, 0, 50),
			Parent = mainFrame
		}
	)

	local progressBarFill = utility.new(
		"Frame",
		{
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0), -- Starts at 0%
			Position = UDim2.new(0, 0, 0, 0),
			Parent = progressBarBg
		}
	)
	-- Removed: self.themeitems is not initialized at this point.

	local percentageLabel = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			Font = Enum.Font.SourceSans, -- Use a default font
			Text = "0%",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 14, -- Use a default text size
			TextStrokeTransparency = 0,
			TextXAlignment = "Center",
			Parent = progressBarBg
		}
	)

	loaderGui = {
		screen = screen,
		mainFrame = mainFrame,
		titleLabel = titleLabel,
		progressBarFill = progressBarFill,
		percentageLabel = percentageLabel,
		library = self,
		updateProgress = function(self, percentage)
			percentage = math.clamp(percentage, 0, 100)
			self.progressBarFill:TweenSize(UDim2.new(percentage / 100, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.4, true)
			self.percentageLabel.Text = tostring(math.floor(percentage)) .. "%"
			task.wait(0.1) -- Small delay for visual update
		end,
		destroy = function(self)
			self.screen:Destroy()
		end
	}

	setmetatable(loaderGui, loaderguis)
	return loaderGui
end

function loaderguis:updateProgress(percentage)
	self.updateProgress(self, percentage)
end

function loaderguis:destroy()
	self.destroy(self)
end

function library:loader(props)
	local name = props.name or props.Name or props.LoaderName or props.Loadername or props.loaderName or props.loadername or "Loader"
	local scriptname = props.scriptname or props.Scriptname or props.ScriptName or props.scriptName or "Universal"
	local closed = props.close or props.Close or props.closecallback or props.Closecallback or props.CloseCallback or props.closeCallback or function()end
	local logedin = props.login or props.Login or props.logincallback or props.Logincallback or props.LoginCallback or props.loginCallback or function()end
	local loader = {}
	--
	local screen = utility.new(
		"ScreenGui",
		{
			Name = tostring(math.random(0,999999))..tostring(math.random(0,999999)),
			DisplayOrder = 9999,
			ResetOnSpawn = false,
			ZIndexBehavior = "Global",
			Parent = cre
		}
	)
        if (check_exploit == "Synapse" and syn.protect_gui) then
	syn.protect_gui(screen)
        end
	--
	local outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(168, 52, 235),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(0,300,0,90),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 9900,
			Visible = false,
			Parent = screen
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(1,-4,1,-4),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 9901,
			Parent = outline
		}
	)
	--
	local indent = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 9902,
			Parent = outline2
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,0,20),
			Position = UDim2.new(0.5,0,0,0),
			Font = "RobotoMono",
			Text = name,
			TextColor3 = Color3.fromRGB(168, 52, 235),
			TextXAlignment = "Center",
			TextSize = 12,
			TextStrokeTransparency = 0,
			ZIndex = 9903,
			Parent = indent
		}
	)
	--
	local scripttitle = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,0,20),
			Position = UDim2.new(0.5,0,0,20),
			Font = "RobotoMono",
			Text = "Script: "..scriptname,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = "Center",
			TextSize = 12,
			TextStrokeTransparency = 0,
			ZIndex = 9903,
			Parent = indent
		}
	)
	--
	local makebutton = function(name,parent)
		local button_holder = utility.new(
			"Frame",
			{
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 9904,
				Parent = parent
			}
		)
		--
		local button_outline = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(12, 12, 12),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 9905,
				Parent = button_holder
			}
		)
		--
		local button_outline2 = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(56, 56, 56),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 9906,
				Parent = button_outline
			}
		)
		--
		local button_color = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,0,0),
				Position = UDim2.new(0,0,0,0),
				ZIndex = 9907,
				Parent = button_outline2
			}
		)
		--
		utility.new(
			"UIGradient",
			{
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
				Rotation = 90,
				Parent = button_color
			}
		)
		--
		local button_button = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0,0,0,0),
				Text = name,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = 12,
				TextStrokeTransparency = 0,
				Font = "RobotoMono",
				ZIndex = 9908,
				Parent = button_holder
			}
		)
		--
		return {button_holder,button_outline,button_button}
	end
	--
	local close = makebutton("close",indent)
	local login = makebutton("login",indent)
	--
	close[1].AnchorPoint = Vector2.new(0.5,0)
	close[1].Size = UDim2.new(0.5,0,0,20)
	close[1].Position = UDim2.new(0.5,0,0,40)
	--
	login[1].AnchorPoint = Vector2.new(0.5,0)
	login[1].Size = UDim2.new(0.5,0,0,20)
	login[1].Position = UDim2.new(0.5,0,0,62)
	--
	close[3].MouseButton1Down:Connect(function()
		close[2].BorderColor3 = Color3.fromRGB(168, 52, 235)
		outline:TweenPosition(UDim2.new(-1.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.75,true)
		closed()
		wait(0.05)
		close[2].BorderColor3 = Color3.fromRGB(12,12,12)
		wait(0.7)
		screen:Remove()
	end)
	--
	login[3].MouseButton1Down:Connect(function()
		login[2].BorderColor3 = Color3.fromRGB(168, 52, 235)
		outline:TweenPosition(UDim2.new(1.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.75,true)
		logedin()
		wait(0.05)
		login[2].BorderColor3 = Color3.fromRGB(12,12,12)
		wait(0.7)
		screen:Remove()
	end)
	--
	loader = {
		["outline"] = outline,
		["outline2"] = outline2,
		["indent"] = indent,
		["title"] = title
	}
	--
	setmetatable(loader,loaders)
	return loader
end
--
function loaders:toggle()
	self.outline.Visible = true
end
--
function watermarks:toggle(bool)
	local watermark = self
	--
	watermark.outline.Visible = bool
end
--
function library:saveconfig()
	local cfg = {}
	--
	for i,v in pairs(self.pointers) do
		cfg[i] = {}
		for c,d in pairs(v) do
			cfg[i][c] = {}
			for x,z in pairs(d) do
				if typeof(z.current) == "Color3" then
					cfg[i][c][x] = {z.current.R,z.current.G,z.current.B}
				else
					cfg[i][c][x] = z.current
				end
			end
		end
	end
	--
	return hs:JSONEncode(cfg)
end
--
function library:loadconfig(cfg)
	local cfg = hs:JSONDecode(readfile(cfg))
	for i,v in pairs(cfg) do
		for c,d in pairs(v) do
			for x,z in pairs(d) do
				if z ~= nil then
					if self.pointers[i] ~= nil and self.pointers[i][c] ~= nil and self.pointers[i][c][x] ~= nil then
						self.pointers[i][c][x]:set(z)
					end
				end
			end
		end
	end
end
--
function library:settheme(theme,color)
	local window = self
	--
	if window.theme[theme] then
		window.theme[theme] = color
	end
	--
	if window.themeitems[theme] then
		for i,v in pairs(window.themeitems[theme]) do
			for z,x in pairs(v) do
				x[i] = color
			end
		end
	end
end
--
function library:setkey(key)
	if typeof(key) == "EnumItem" then
		local window = self
		window.key = key
	end
end
--
function library:settoggle(side,bool)
	if side == "x" then
		self.x = bool
	else
		self.y = bool
	end
end
--
function library:setfont(font)
	if font ~= nil then
		local window = self
		for i,v in pairs(window.labels) do
			if v ~= nil then
				v.Font = font
			end
		end
	end
end
--
function library:settextsize(size)
	if size ~= nil then
		local window = self
		for i,v in pairs(window.labels) do
			if v ~= nil then
				v.TextSize = size
			end
		end
	end
end
--
function library:page(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	-- // variables
	local page = {}
	-- // main
	local tabbutton = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,75,1,0),
			Parent = self.tabsbuttons
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = tabbutton
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = tabbutton
		}
	)
	--
	local r_line = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 0,
			Size = UDim2.new(0,1,0,1),
			Position = UDim2.new(1,0,1,1),
			ZIndex = 2,
			Parent = outline
		}
	)
	--
	local l_line = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 0,
			Size = UDim2.new(0,1,0,1),
			Position = UDim2.new(0,0,1,1),
			ZIndex = 2,
			Parent = outline
		}
	)
	--
	local line = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,0,2),
			Position = UDim2.new(0,0,1,0),
			ZIndex = 2,
			Parent = outline
		}
	)
	--
	local label = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,0),
			Font = self.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			Parent = outline
		}
	)
	--
	local pageholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-20,1,-20),
			Position = UDim2.new(0.5,0,0.5,0),
			Visible = false,
			Parent = self.tabs
		}
	)
	--
	local left = utility.new(
		"ScrollingFrame",
		{
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0.5,-5,1,0),
			Position = UDim2.new(0,0,0,0),
			AutomaticCanvasSize = "Y",
			CanvasSize = UDim2.new(0,0,0,0),
			ScrollBarImageTransparency = 1,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 0,
			ClipsDescendants = true,
			VerticalScrollBarInset = "None",
			VerticalScrollBarPosition = "Right",
			Parent = pageholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,10),
			Parent = left
		}
	)
	--
	local right = utility.new(
		"ScrollingFrame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0.5,-5,1,0),
			Position = UDim2.new(1,0,0,0),
			AutomaticCanvasSize = "Y",
			CanvasSize = UDim2.new(0,0,0,0),
			ScrollBarImageTransparency = 1,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 0,
			ClipsDescendants = true,
			VerticalScrollBarInset = "None",
			VerticalScrollBarPosition = "Right",
			Parent = pageholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,10),
			Parent = right
		}
	)
	-- // page tbl
	page = {
		["library"] = self,
		["outline"] = outline,
		["r_line"] = r_line,
		["l_line"] = l_line,
		["line"] = line,
		["page"] = pageholder,
		["left"] = left,
		["right"] = right,
		["open"] = false,
		["pointers"] = {}
	}
	--
	table.insert(self.pages,page)
	--
	button.MouseButton1Down:Connect(function()
		if page.open == false then
			for i,v in pairs(self.pages) do
				if v ~= page then
					if v.open then
						v.page.Visible = false
						v.open = false
						v.outline.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
						v.line.Size = UDim2.new(1,0,0,2)
						v.line.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
					end
				end
			end
			--
			self:closewindows()
			--
			page.page.Visible = true
			page.open = true
			page.outline.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			page.line.Size = UDim2.new(1,0,0,3)
			page.line.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		self.pointers[tostring(pointer)] = page.pointers
	end
	--
	self.labels[#self.labels+1] = label
	-- // metatable indexing + return
	setmetatable(page, pages)
	return page
end
--
function pages:openpage()
	local page = self
	--
	if page.open == false then
		for i,v in pairs(page.library.pages) do
			if v ~= page then
				if v.open then
					v.page.Visible = false
					v.open = false
					v.outline.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
					v.line.Size = UDim2.new(1,0,0,2)
					v.line.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
				end
			end
		end
		--
		page.page.Visible = true
		page.open = true
		page.outline.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		page.line.Size = UDim2.new(1,0,0,3)
		page.line.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	end
end
--
function pages:section(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local side = props.side or props.Side or props.sectionside or props.Sectionside or props.SectionSide or props.sectionSide or "left"
	local size = props.size or props.Size or props.yaxis or props.yAxis or props.YAxis or props.Yaxis or 200
	side = side:lower()
	-- // variables
	local section = {}
	-- // main
	local sectionholder = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BackgroundColor3 = self.library.theme.content,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,size),
			Parent = self[side]
		}
	)
	table.insert(self.library.themeitems["content"]["BackgroundColor3"], sectionholder)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BackgroundColor3 = self.library.theme.content,
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = sectionholder
		}
	)
	table.insert(self.library.themeitems["content"]["BackgroundColor3"], outline)
	--
	local color = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = self.library.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-2,0,1),
			Position = UDim2.new(0.5,0,0,0),
			Parent = outline
		}
	)
	--
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],color)
	--
	local content = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-12,1,-25),
			Position = UDim2.new(0.5,0,1,-5),
			Parent = outline
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-5,0,20),
			Position = UDim2.new(0,5,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = outline
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], title)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,5),
			Parent = content
		}
	)
	-- // section tbl
	section = {
		["library"] = self.library,
		["sectionholder"] = sectionholder,
		["color"] = color,
		["content"] = content,
		["pointers"] = {}
	}
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = section.pointers
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	-- // metatable indexing + return
	setmetatable(section, sections)
	return section
end
--
function pages:multisection(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local side = props.side or props.Side or props.sectionside or props.Sectionside or props.SectionSide or props.sectionSide or "left"
	local size = props.size or props.Size or props.yaxis or props.yAxis or props.YAxis or props.Yaxis or 200
	side = side:lower()
	-- // variables
	local multisection = {}
	-- // main
	local sectionholder = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,size),
			Parent = self[side]
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = sectionholder
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = self.library.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-2,0,1),
			Position = UDim2.new(0.5,0,0,0),
			Parent = outline
		}
	)
	--
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],color)
	--
	local tabsholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,-15),
			Position = UDim2.new(0,0,1,0),
			Parent = outline
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-5,0,20),
			Position = UDim2.new(0,5,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = outline
		}
	)
	--
	local buttons = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-6,0,20),
			Position = UDim2.new(0.5,0,0,5),
			Parent = tabsholder
		}
	)
	--
	local tabs = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-6,1,-27),
			Position = UDim2.new(0.5,0,1,-3),
			Parent = tabsholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Horizontal",
			Padding = UDim.new(0,2),
			Parent = buttons
		}
	)
	--
	local tabs_outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = tabs
		}
	)
	-- // section tbl
	multisection = {
		["library"] = self.library,
		["sectionholder"] = sectionholder,
		["color"] = color,
		["tabsholder"] = tabsholder,
		["mssections"] = {},
		["buttons"] = buttons,
		["tabs"] = tabs,
		["tabs_outline"] = tabs_outline,
		["pointers"] = {}
	}
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = multisection.pointers
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	-- // metatable indexing + return
	setmetatable(multisection,multisections)
	return multisection
end
--
function multisections:section(props)
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	-- // variables
	local mssection = {}
	-- // main
	local tabbutton = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,60,0,20),
			Parent = self.buttons
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = tabbutton
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = tabbutton
		}
	)
	--
	local r_line = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 0,
			Size = UDim2.new(0,1,0,1),
			Position = UDim2.new(1,0,1,1),
			ZIndex = 2,
			Parent = outline
		}
	)
	--
	local l_line = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 0,
			Size = UDim2.new(0,1,0,1),
			Position = UDim2.new(0,0,1,1),
			ZIndex = 2,
			Parent = outline
		}
	)
	--
	local line = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,0,2),
			Position = UDim2.new(0,0,1,0),
			ZIndex = 2,
			Parent = outline
		}
	)
	--
	local label = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Parent = outline
		}
	)
	--
	local content = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-6,1,-27),
			Position = UDim2.new(0.5,0,1,-3),
			Parent = self.tabs_outline
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,5),
			Parent = content
		}
	)
	-- // mssection tbl
	mssection = {
		["library"] = self.library,
		["outline"] = outline,
		["r_line"] = r_line,
		["l_line"] = l_line,
		["line"] = line,
		["content"] = content,
		["open"] = false,
		["pointers"] = {}
	}
	--
	table.insert(self.mssections,mssection)
	--
	button.MouseButton1Down:Connect(function()
		if mssection.open == false then
			for i,v in pairs(self.mssections) do
				if v ~= mssection then
					if v.open then
						v.page.Visible = false
						v.open = false
						v.outline.BackgroundColor3 = Color3.fromRGB(31, 31 ,31)
						v.line.Size = UDim2.new(1,0,0,2)
						v.line.BackgroundColor3 = Color3.fromRGB(31, 31 ,31)
					end
				end
			end
			--
			mssection.library:closewindows()
			--
			mssection.content.Visible = true
			mssection.open = true
			mssection.outline.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
			mssection.line.Size = UDim2.new(1,0,0,3)
			mssection.line.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = mssection.pointers
		end
	end
	--
	self.library.labels[#self.library.labels+1] = label
	-- // metatable indexing + return
	setmetatable(mssection,mssections)
	return mssection
end
--
function sections:toggle(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or props.toggle or props.Toggle or props.toggled or props.Toggled or false
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	-- // variables
	local toggle = {}
	-- // main
	local toggleholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,15,0,15),
			Parent = toggleholder
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = toggleholder
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-20,1,0),
			Position = UDim2.new(0,20,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = toggleholder
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], title)
	--
	local col = Color3.fromRGB(20, 20, 20)
	if def then
		col = self.library.theme.accent
	end
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = col,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = outline
		}
	)
	if def then
		table.insert(self.library.themeitems["accent"]["BackgroundColor3"],color)
	end
	-- // toggle tbl
	toggle = {
		["library"] = self.library,
		["toggleholder"] = toggleholder,
		["title"] = title,
		["color"] = color,
		["callback"] = callback,
		["current"] = def
	}
	--
	button.MouseButton1Down:Connect(function()
		if toggle.current then
			toggle.callback(false)
			toggle.color.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			local find = table.find(self.library.themeitems["accent"]["BackgroundColor3"],toggle.color)
			if find then
				table.remove(self.library.themeitems["accent"]["BackgroundColor3"],find)
			end
			toggle.current = false
		else
			toggle.callback(true)
			toggle.color.BackgroundColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["BackgroundColor3"],toggle.color)
			toggle.current = true
		end
	end)
	--
	if props.colorpicker then
		local cp = props.colorpicker
		cp.parent = toggleholder
		cp.flag = "toggle"
		cp.name = ""
		self:colorpicker(cp)
	end
	--
	if props.keybind then
		local kb = props.keybind
		kb.parent = toggleholder
		kb.flag = "toggle"
		kb.name = ""
		self:keybind(kb)
	end
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = toggle
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	-- // metatable indexing + return
	callback(def)
	setmetatable(toggle, toggles)
	return toggle
end
--
function toggles:set(bool)
	if bool ~= nil then
		local toggle = self
		if toggle.current == bool then return end

		toggle.callback(bool)
		toggle.current = bool
		if bool then
			toggle.color.BackgroundColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["BackgroundColor3"],toggle.color)
		else
			toggle.color.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			local find = table.find(self.library.themeitems["accent"]["BackgroundColor3"],toggle.color)
			if find then
				table.remove(self.library.themeitems["accent"]["BackgroundColor3"],find)
			end
		end
	end
end
--
function sections:button(props)
	-- // properties
	local name = props.name or props.Name or "new button"
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	-- // variables
	local button = {}
	-- // main
	local buttonholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,20),
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = buttonholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = outline
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Parent = outline2
		}
	)
	--
	local gradient = utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = color
		}
	)
	--
	local buttonpress = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Font = self.library.font,
			Parent = buttonholder
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], buttonpress)
	--
	buttonpress.MouseButton1Down:Connect(function()
		callback()
		outline.BorderColor3 = self.library.theme.accent
		table.insert(self.library.themeitems["accent"]["BorderColor3"],outline)
		wait(0.05)
		outline.BorderColor3 = Color3.fromRGB(12, 12, 12)
		local find = table.find(self.library.themeitems["accent"]["BorderColor3"],outline)
		if find then
			table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
		end
	end)
	-- // button tbl
	button = {
		["library"] = self.library
	}
	--
	self.library.labels[#self.library.labels+1] = buttonpress
	-- // metatable indexing + return
	setmetatable(button, buttons)
	return button
end
--
function sections:slider(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or 0
	local max = props.max or props.Max or props.maximum or props.Maximum or 100
	local min = props.min or props.Min or props.minimum or props.Minimum or 0
	local rounding = props.rounding or props.Rounding or props.round or props.Round or props.decimals or props.Decimals or false
	local ticking = props.tick or props.Tick or props.ticking or props.Ticking or false
	local measurement = props.measurement or props.Measurement or props.digit or props.Digit or props.calc or props.Calc or ""
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	def = math.clamp(def,min,max)
	-- // variables
	local slider = {}
	-- // main
	local sliderholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,25),
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,12),
			Position = UDim2.new(0,0,0,15),
			Parent = sliderholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = outline
		}
	)	
	--
	local value = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,2),
			Position = UDim2.new(0,0,0.5,0),
			Font = self.library.font,
			Text = def..measurement.."/"..max..measurement,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			ZIndex = 3,
			Parent = outline
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], value)
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Parent = outline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = color
		}
	)
	--
	local slide = utility.new(
		"Frame",
		{
			BackgroundColor3 = self.library.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new((1 / color.AbsoluteSize.X) * (color.AbsoluteSize.X / (max - min) * (def - min)),0,1,0),
			ZIndex = 2,
			Parent = outline
		}
	)
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],slide)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = slide
		}
	)
	--
	local sliderbutton = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = sliderholder
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = sliderholder
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], title)
	-- // slider tbl
	slider = {
		["library"] = self.library,
		["outline"] = outline,
		["sliderbutton"] = sliderbutton,
		["title"] = title,
		["value"] = value,
		["slide"] = slide,
		["color"] = color,
		["max"] = max,
		["min"] = min,
		["current"] = def,
		["measurement"] = measurement,
		["tick"] = ticking,
		["rounding"] = rounding,
		["callback"] = callback
	}
	--
	local function slide()
		local size = math.clamp(plr:GetMouse().X - slider.color.AbsolutePosition.X ,0 ,slider.color.AbsoluteSize.X)
		local result = (slider.max - slider.min) / slider.color.AbsoluteSize.X * size + slider.min
		if slider.rounding then
			local newres = math.floor(result)
			value.Text = newres..slider.measurement.."/"..slider.max..slider.measurement
			slider.current = newres
			slider.callback(newres)
			if slider.tick then
				slider.slide:TweenSize(UDim2.new((1 / slider.color.AbsoluteSize.X) * (slider.color.AbsoluteSize.X / (slider.max - slider.min) * (newres - slider.min)) ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
			else
				slider.slide:TweenSize(UDim2.new((1 / slider.color.AbsoluteSize.X) * size ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
			end
		else
			local newres = utility.round(result ,2)
			value.Text = newres..slider.measurement.."/"..slider.max..slider.measurement
			slider.current = newres
			slider.callback(newres)
			if slider.tick then
				slider.slide:TweenSize(UDim2.new((1 / slider.color.AbsoluteSize.X) * (slider.color.AbsoluteSize.X / (slider.max - slider.min) * (newres - slider.min)) ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
			else
				slider.slide:TweenSize(UDim2.new((1 / slider.color.AbsoluteSize.X) * size ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
			end
		end
	end
	--
	sliderbutton.MouseButton1Down:Connect(function()
		slider.holding = true
		slide()
		table.insert(self.library.themeitems["accent"]["BorderColor3"],outline)
		outline.BorderColor3 = self.library.theme.accent
	end)
	--
	local inputChangedConn = uis.InputChanged:Connect(function()
		if slider.holding then
			slide()
		end
	end)
	table.insert(self.library.connections, inputChangedConn)
	local inputEndedConn = uis.InputEnded:Connect(function(Input)
		if Input.UserInputType.Name == 'MouseButton1' and slider.holding then
			slider.holding = false
			outline.BorderColor3 = Color3.fromRGB(12, 12, 12)
			local find = table.find(self.library.themeitems["accent"]["BorderColor3"],outline)
			if find then
				table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
			end
		end
	end)
	table.insert(self.library.connections, inputEndedConn)

	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = slider
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	self.library.labels[#self.library.labels+1] = value
	-- // metatable indexing + return
	callback(def)
	setmetatable(slider, sliders)
	return slider
end
--
function sliders:set(value)
	local size = math.clamp((self.color.AbsoluteSize.X / (self.max - self.min) * (value - self.min)) ,0 ,self.color.AbsoluteSize.X)
	local result = value
	if self.rounding then
		local newres = math.floor(result)
		self.value.Text = newres..self.measurement.."/"..self.max..self.measurement
		self.current = newres
		self.callback(newres)
		if self.tick then
			self.slide:TweenSize(UDim2.new((1 / self.color.AbsoluteSize.X) * (self.color.AbsoluteSize.X / (self.max - self.min) * (newres - self.min)) ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
		else
			self.slide:TweenSize(UDim2.new((1 / self.color.AbsoluteSize.X) * size ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
		end
	else
		local newres = utility.round(result ,2)
		self.value.Text = newres..self.measurement.."/"..self.max..self.measurement
		self.current = newres
		self.callback(newres)
		if self.tick then
			self.slide:TweenSize(UDim2.new((1 / self.color.AbsoluteSize.X) * (self.color.AbsoluteSize.X / (self.max - self.min) * (newres - self.min)) ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
		else
			self.slide:TweenSize(UDim2.new((1 / self.color.AbsoluteSize.X) * size ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
		end
	end
end
--
function library:closewindows(ignore)
	local window = self
	--
	for i,v in pairs(window.dropdowns) do
		if v ~= ignore then
			if v.open then
				v.optionsholder.Visible = false
				v.indicator.Text = "-"
				v.open = false
			end
		end
	end
	--
	for i,v in pairs(window.multiboxes) do
		if v ~= ignore then
			if v.open then
				v.optionsholder.Visible = false
				v.indicator.Text = "-"
				v.open = false
			end
		end
	end
	--
	for i,v in pairs(window.buttonboxs) do
		if v ~= ignore then
			if v.open then
				v.optionsholder.Visible = false
				v.indicator.Text = "-"
				v.open = false
			end
		end
	end
	--
	for i,v in pairs(window.colorpickers) do
		if v ~= ignore then
			if v.open then
				v.cpholder.Visible = false
				v.open = false
			end
		end
	end
end
--
function sections:dropdown(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or ""
	local max = props.max or props.Max or props.maximum or props.Maximum or 4
	local options = props.options or props.Options or props.Settings or props.settings or {}
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	-- // variables
	local dropdown = {}
	-- // main
	local dropdownholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,35),
			ZIndex = 2,
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,15),
			Parent = dropdownholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = color
		}
	)
	--
	local value = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-20,1,0),
			Position = UDim2.new(0,5,0,0),
			Font = self.library.font,
			Text = def,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			ClipsDescendants = true,
			Parent = outline
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], value)
	--
	local indicator = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0,0),
			Font = self.library.font,
			Text = "+",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Right",
			ClipsDescendants = true,
			Parent = outline
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], indicator)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = dropdownholder
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], title)
	--
	local dropdownbutton = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = dropdownholder
		}
	)
	--
	local optionsholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,34),
			Visible = false,
			Parent = dropdownholder
		}
	)
	--
	local size = #options
	--
	size = math.clamp(size,1,max)
	--
	local optionsoutline = utility.new(
		"ScrollingFrame",
		{
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,size,2),
			Position = UDim2.new(0,0,0,0),
			ClipsDescendants = true,
			CanvasSize = UDim2.new(0,0,0,18*#options),
			ScrollBarImageTransparency = 0.25,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 5,
			VerticalScrollBarInset = "ScrollBar",
			VerticalScrollBarPosition = "Right",
			ZIndex = 5,
			Parent = optionsholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Parent = optionsoutline
		}
	)
	-- // dropdown tbl
	dropdown = {
		["library"] = self.library,
		["optionsholder"] = optionsholder,
		["indicator"] = indicator,
		["options"] = options,
		["title"] = title,
		["value"] = value,
		["open"] = false,
		["titles"] = {},
		["current"] = def,
		["callback"] = callback
	}
	--
	table.insert(dropdown.library.dropdowns,dropdown)
	--
	for i,v in pairs(options) do
		local ddoptionbutton = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,18),
				Text = "",
				ZIndex = 6,
				Parent = optionsoutline
			}
		)
		--
		local ddoptiontitle = utility.new(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,-10,1,0),
				Position = UDim2.new(0.5,0,0,0),
				Font = self.library.font,
				Text = v,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextColor3 = self.library.theme.text,
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Left",
				ClipsDescendants = true,
				ZIndex = 6,
				Parent = ddoptionbutton
			}
		)
		table.insert(self.library.themeitems["text"]["TextColor3"], ddoptiontitle)
		--
		self.library.labels[#self.library.labels+1] = ddoptiontitle
		--
		table.insert(dropdown.titles,ddoptiontitle)
		--
		if v == dropdown.current then ddoptiontitle.TextColor3 = self.library.theme.accent end
		--
		ddoptionbutton.MouseButton1Down:Connect(function()
			optionsholder.Visible = false
			dropdown.open = false
			indicator.Text = "+"
			for z,x in pairs(dropdown.titles) do
				if x.TextColor3 == self.library.theme.accent then
					x.TextColor3 = Color3.fromRGB(255,255,255)
				end
			end
			dropdown.current = v
			dropdown.value.Text = v
			ddoptiontitle.TextColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["TextColor3"],ddoptiontitle)
			dropdown.callback(v)
		end)
	end
	--
	dropdownbutton.MouseButton1Down:Connect(function()
		dropdown.library:closewindows(dropdown)
		for i,v in pairs(dropdown.titles) do
			if v.Text == dropdown.current then
				v.TextColor3 = dropdown.library.theme.accent
			else
				v.TextColor3 = Color3.fromRGB(255,255,255)
			end
		end
		optionsholder.Visible = not dropdown.open
		dropdown.open = not dropdown.open
		if dropdown.open then
			indicator.Text = "-"
		else
			indicator.Text = "+"
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = dropdown
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	self.library.labels[#self.library.labels+1] = value
	-- // metatable indexing + return
	callback(def)
	setmetatable(dropdown, dropdowns)
	return dropdown
end
--
function sections:buttonbox(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or ""
	local max = props.max or props.Max or props.maximum or props.Maximum or 4
	local options = props.options or props.Options or props.Settings or props.settings or {}
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	-- // variables
	local buttonbox = {}
	-- // main
	local buttonboxholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,35),
			ZIndex = 2,
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,15),
			Parent = buttonboxholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = color
		}
	)
	--
	local indicator = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0,0),
			Font = self.library.font,
			Text = "+",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Right",
			ClipsDescendants = true,
			Parent = outline
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = buttonboxholder
		}
	)
	--
	local buttonboxbutton = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = buttonboxholder
		}
	)
	--
	local optionsholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,34),
			Visible = false,
			Parent = buttonboxholder
		}
	)
	--
	local size = #options
	--
	size = math.clamp(size,1,max)
	--
	local optionsoutline = utility.new(
		"ScrollingFrame",
		{
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,size,2),
			Position = UDim2.new(0,0,0,0),
			ClipsDescendants = true,
			CanvasSize = UDim2.new(0,0,0,18*#options),
			ScrollBarImageTransparency = 0.25,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 5,
			VerticalScrollBarInset = "ScrollBar",
			VerticalScrollBarPosition = "Right",
			ZIndex = 5,
			Parent = optionsholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Parent = optionsoutline
		}
	)
	-- // buttonbox tbl
	buttonbox = {
		["library"] = self.library,
		["optionsholder"] = optionsholder,
		["indicator"] = indicator,
		["options"] = options,
		["title"] = title,
		["open"] = false,
		["titles"] = {},
		["current"] = def,
		["callback"] = callback
	}
	--
	table.insert(buttonbox.library.buttonboxs,buttonbox)
	--
	for i,v in pairs(options) do
		local bboptionbutton = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,18),
				Text = "",
				ZIndex = 6,
				Parent = optionsoutline
			}
		)
		--
		local bboptiontitle = utility.new(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,-10,1,0),
				Position = UDim2.new(0.5,0,0,0),
				Font = self.library.font,
				Text = v,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Left",
				ClipsDescendants = true,
				ZIndex = 6,
				Parent = bboptionbutton
			}
		)
		--
		self.library.labels[#self.library.labels+1] = bboptiontitle
		--
		table.insert(buttonbox.titles,bboptiontitle)
		--
		bboptionbutton.MouseButton1Down:Connect(function()
			optionsholder.Visible = false
			buttonbox.open = false
			indicator.Text = "+"
			buttonbox.current = v
			buttonbox.callback(v)
		end)
	end
	--
	buttonboxbutton.MouseButton1Down:Connect(function()
		buttonbox.library:closewindows(buttonbox)
		optionsholder.Visible = not buttonbox.open
		buttonbox.open = not buttonbox.open
		if buttonbox.open then
			indicator.Text = "-"
		else
			indicator.Text = "+"
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = buttonbox
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	-- // metatable indexing + return
	setmetatable(buttonbox, buttonboxs)
	return buttonbox
end
--
function dropdowns:set(value)
	if value ~= nil then
		local dropdown = self
		if table.find(dropdown.options,value) then
			self.current = tostring(value)
			self.value.Text = tostring(value)
			self.callback(tostring(value))
			for z,x in pairs(dropdown.titles) do
				if x.Text == value then
					x.TextColor3 = dropdown.library.theme.accent
				else
					x.TextColor3 = Color3.fromRGB(255,255,255)
				end
			end
		end
	end
end
--
function sections:multibox(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or {}
	local max = props.max or props.Max or props.maximum or props.Maximum or 4
	local options = props.options or props.Options or props.Settings or props.settings or {}
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	local defstr = ""
	if #def > 1 then
		for i,v in pairs(def) do
			if i == #def then
				defstr = defstr..v
			else
				defstr = defstr..v..", "
			end
		end
	else
		for i,v in pairs(def) do
			defstr = defstr..v
		end
	end
	-- // variables
	local multibox = {}
	-- // main
	local multiboxholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,35),
			ZIndex = 2,
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,15),
			Parent = multiboxholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = color
		}
	)
	--
	local value = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-20,1,0),
			Position = UDim2.new(0,5,0,0),
			Font = self.library.font,
			Text = defstr,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			ClipsDescendants = true,
			Parent = outline
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], value)
	--
	local indicator = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0,0),
			Font = self.library.font,
			Text = "+",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Right",
			ClipsDescendants = true,
			Parent = outline
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], indicator)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = multiboxholder
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], title)
	--
	local dropdownbutton = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = multiboxholder
		}
	)
	--
	local optionsholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,34),
			Visible = false,
			Parent = multiboxholder
		}
	)
	--
	local size = #options
	--
	size = math.clamp(size,1,max)
	--
	local optionsoutline = utility.new(
		"ScrollingFrame",
		{
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,size,2),
			Position = UDim2.new(0,0,0,0),
			ClipsDescendants = true,
			CanvasSize = UDim2.new(0,0,0,18*#options),
			ScrollBarImageTransparency = 0.25,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 5,
			VerticalScrollBarInset = "ScrollBar",
			VerticalScrollBarPosition = "Right",
			ZIndex = 5,
			Parent = optionsholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Parent = optionsoutline
		}
	)
	-- // dropdown tbl
	multibox = {
		["library"] = self.library,
		["indicator"] = indicator,
		["optionsholder"] = optionsholder,
		["options"] = options,
		["value"] = value,
		["open"] = false,
		["titles"] = {},
		["current"] = def,
		["callback"] = callback
	}
	--
	table.insert(multibox.library.multiboxes,multibox)
	--
	for i,v in pairs(options) do
		local ddoptionbutton = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,18),
				Text = "",
				ZIndex = 6,
				Parent = optionsoutline
			}
		)
		--
		local ddoptiontitle = utility.new(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,-10,1,0),
				Position = UDim2.new(0.5,0,0,0),
				Font = self.library.font,
				Text = v,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextColor3 = self.library.theme.text,
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Left",
				ClipsDescendants = true,
				ZIndex = 6,
				Parent = ddoptionbutton
			}
		)
		table.insert(self.library.themeitems["text"]["TextColor3"], ddoptiontitle)
		--
		self.library.labels[#self.library.labels+1] = ddoptiontitle
		--
		table.insert(multibox.titles,ddoptiontitle)
		--
		for c,b in pairs(def) do if v == b then ddoptiontitle.TextColor3 = self.library.theme.accent end end
		--
		ddoptionbutton.MouseButton1Down:Connect(function()
			local find = table.find(multibox.current,v)
			if find == nil then
				table.insert(multibox.current,v)
				local str = ""
				if #multibox.current > 1 then
					for i,v in pairs(multibox.current) do
						if i == #multibox.current then
							str = str..v
						else
							str = str..v..", "
						end
					end
				else
					for i,v in pairs(multibox.current) do
						str = str..v
					end
				end
				value.Text = str
				ddoptiontitle.TextColor3 = self.library.theme.accent
				table.insert(self.library.themeitems["accent"]["TextColor3"],ddoptiontitle)
				multibox.callback(multibox.current)
			else
				table.remove(multibox.current,find)
				local str = ""
				if #multibox.current > 1 then
					for i,v in pairs(multibox.current) do
						if i == #multibox.current then
							str = str..v
						else
							str = str..v..", "
						end
					end
				else
					for i,v in pairs(multibox.current) do
						str = str..v
					end
				end
				value.Text = str
				ddoptiontitle.TextColor3 = Color3.fromRGB(255,255,255)
				multibox.callback(multibox.current)
			end
		end)
	end
	--
	dropdownbutton.MouseButton1Down:Connect(function()
		multibox.library:closewindows(multibox)
		for i,v in pairs(multibox.titles) do
			if v.TextColor3 ~= Color3.fromRGB(255,255,255) then
				v.TextColor3 = self.library.theme.accent
			end
		end
		optionsholder.Visible = not multibox.open
		multibox.open = not multibox.open
		if multibox.open then
			indicator.Text = "-"
		else
			indicator.Text = "+"
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = multibox
		end
	end
	--
	self.library.labels[#self.library.labels+1] = value
	self.library.labels[#self.library.labels+1] = title
	-- // metatable indexing + return
	callback(def)
	setmetatable(multibox, multiboxs)
	return multibox
end
--
function buttonboxs:set(value)
	if value ~= nil then
		local dropdown = self
		if table.find(dropdown.options,value) then
			self.current = tostring(value)
			self.callback(tostring(value))
		end
	end
end
--
function multiboxs:set(tbl)
	if tbl then
		local multibox = self
		if typeof(tbl) == "table" then
			multibox.current = {}
			for i,v in pairs(tbl) do
				if table.find(multibox.options,v) then
					table.insert(multibox.current,v)
				end
			end
			--
			for i,v in pairs(multibox.titles) do
				if v.TextColor3 == multibox.library.theme.accent then
					v.TextColor3 = Color3.fromRGB(255,255,255)
				end
				if table.find(tbl,v.Text) then
					v.TextColor3 = multibox.library.theme.accent
				end
			end
			--
			local str = ""
			if #multibox.current > 1 then
				for i,v in pairs(multibox.current) do
					if i == #multibox.current then
						str = str..v
					else
						str = str..v..", "
					end
				end
			else
				for i,v in pairs(multibox.current) do
					str = str..v
				end
			end
			--
			multibox.value.Text = str
		end
	end
end
--
function sections:textbox(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or ""
	local placeholder = props.placeholder or props.Placeholder or props.placeHolder or props.PlaceHolder or props.placeholdertext or props.PlaceHolderText or props.PlaceHoldertext or props.placeHolderText or props.placeHoldertext or props.Placeholdertext or props.PlaceholderText or props.placeholderText or ""
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	-- // variables
	local textbox = {}
	-- // main
	local textboxholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,35),
			ZIndex = 2,
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,15),
			Parent = textboxholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = outline
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Parent = outline2
		}
	)
	--
	local gradient = utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = color
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Font = self.library.font,
			Parent = textboxholder
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], button)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = textboxholder
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], title)
	--
	local tbox = utility.new(
		"TextBox",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,0,20),
			Position = UDim2.new(0.5,0,0,15),
			PlaceholderText = placeholder,
			Text = def,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextTruncate = "AtEnd",
			Font = self.library.font,
			Parent = textboxholder
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], tbox)
	-- // textbox tbl
	textbox = {
		["library"] = self.library,
		["tbox"] = tbox,
		["current"] = def,
		["callback"] = callback
	}
	--
	button.MouseButton1Down:Connect(function()
		tbox:CaptureFocus()
	end)
	--
	tbox.Focused:Connect(function()
		outline.BorderColor3 = self.library.theme.accent
		table.insert(self.library.themeitems["accent"]["BorderColor3"],outline)
	end)
	--
	tbox.FocusLost:Connect(function(enterPressed)
		textbox.current = tbox.Text
		callback(tbox.Text)
		outline.BorderColor3 = Color3.fromRGB(12, 12, 12)
		local find = table.find(self.library.themeitems["accent"]["BorderColor3"],outline)
		if find then
			table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = textbox
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	self.library.labels[#self.library.labels+1] = tbox
	-- // metatable indexing + return
	callback(def)
	setmetatable(textbox, textboxs)
	return textbox
end
--
function textboxs:set(value)
	self.tbox.Text = value
	self.current = value
	self.callback(value)
end
--
function sections:keybind(props)
	-- // properties
	local name = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or nil
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	local allowed = props.allowed or props.Allowed or 1
	local parent = props.parent or self.content
	--
	local default = ".."
	local typeis = nil
	--
	if typeof(def) == "EnumItem" then
		if def == Enum.UserInputType.MouseButton1 then
			if allowed == 1 then
				default = "MB1"
				typeis = "UserInputType"
			end
		elseif def == Enum.UserInputType.MouseButton2 then
			if allowed == 1 then
				default = "MB2"
				typeis = "UserInputType"
			end
		elseif def == Enum.UserInputType.MouseButton3 then
			if allowed == 1 then
				default = "MB3"
				typeis = "UserInputType"
			end
		else
			local capd = utility.capatalize(def.Name)
			if #capd > 1 then
				default = capd
			else
				default = def.Name
			end
			typeis = "KeyCode"
		end
	end
	-- // variables
	local keybind = {}
	-- // main
	local keybindholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,17), -- Default height
			Parent = parent
		}
	)
	--
	if props.flag == "toggle" then
		keybindholder.Size = UDim2.new(1,0,1,0)
		keybindholder.Position = UDim2.new(0,0,0,0)
		keybindholder.ZIndex = 3
	end
	--
	local outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,40,1,0),
			Position = UDim2.new(1,0,0,0),
			Parent = keybindholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline
		}
	)
	--
	local value = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = default,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Center",
			Parent = outline
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], value)
	--
	outline.Size = UDim2.new(0,value.TextBounds.X+20,1,0)
	--
	local color = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = outline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = color
		}
	)
	--
	local btnParent = keybindholder
	if props.flag == "toggle" then
		-- If embedded in toggle, button should only cover the keybind box, not the whole row
		btnParent = outline
	end
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Font = self.library.font,
			Parent = btnParent
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], button)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Visible = (props.flag ~= "toggle"),
			Parent = keybindholder
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], title)
	-- // keybind tbl
	keybind = {
		["library"] = self.library,
		["down"] = false,
		["outline"] = outline,
		["value"] = value,
		["allowed"] = allowed,
		["current"] = {typeis,utility.splitenum(def)},
		["pressed"] = false,
		["callback"] = callback,
		["ignoreNextMouse1"] = false -- Initialize the flag
	}
	--
	button.MouseButton1Down:Connect(function()
		if keybind.down == false then
			outline.BorderColor3 = self.library.theme.accent
			value.Text = "..."
			keybind.ignoreNextMouse1 = true -- Set flag immediately to prevent race condition
			table.insert(self.library.themeitems["accent"]["BorderColor3"],outline)
			keybind.down = true
        end
	end)
	--
	button.MouseButton2Down:Connect(function()
		keybind.down = false
		keybind.current = {nil,nil}
		outline.BorderColor3 = Color3.fromRGB(12, 12, 12)
		local find = table.find(self.library.themeitems["accent"]["BorderColor3"],outline)
		if find then
			table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
		end
		value.Text = ".."
		outline.Size = UDim2.new(0,value.TextBounds.X+20,1,0)
	end)
	--
	local function turn(typeis, current, enum)
		outline.Size = UDim2.new(0,value.TextBounds.X+20,1,0)
		keybind.down = false
		keybind.current = {typeis, current}
		outline.BorderColor3 = Color3.fromRGB(12, 12, 12)
		local find = table.find(self.library.themeitems["accent"]["BorderColor3"],outline)
		if find then
			table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
		end
		callback(enum)
	end
	--
	uis.InputBegan:Connect(function(Input)
		if keybind.down then
			-- Ignore the initial MouseButton1 input that activated capture mode
			if keybind.ignoreNextMouse1 and Input.UserInputType == Enum.UserInputType.MouseButton1 then
				keybind.ignoreNextMouse1 = false
				return
			end

			if Input.KeyCode == Enum.KeyCode.Escape then
				value.Text = ".."
				turn("KeyCode", "None", nil)
				callback(nil)
				return
			elseif Input.UserInputType == Enum.UserInputType.Keyboard then
				local capd = utility.capatalize(Input.KeyCode.Name)
				if #capd > 1 then
					value.Text = capd
				else
					value.Text = Input.KeyCode.Name
				end
				turn("KeyCode", Input.KeyCode.Name, Input.KeyCode)
			end
			if allowed == 1 then
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					value.Text = "MB1"
					turn("UserInputType", Input.UserInputType.Name, Input.UserInputType)
				elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
					value.Text = "MB2"
					turn("UserInputType", Input.UserInputType.Name, Input.UserInputType)
				elseif Input.UserInputType == Enum.UserInputType.MouseButton3 then
					value.Text = "MB3"
					turn("UserInputType", Input.UserInputType.Name, Input.UserInputType)
				end
			end
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = keybind
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	self.library.labels[#self.library.labels+1] = value
	-- // metatable indexing + return
	callback(def)
	setmetatable(keybind, keybinds)
	return keybind
end
--
function keybinds:set(key)
	if key then
		if typeof(key) == "EnumItem" or typeof(key) == "table" then
			if typeof(key) == "table" then
				if key[1] and key[2] then
					key = Enum[key[1]][key[2]]
				else
					return
				end
			end
			local keybind = self
			local typeis = ""
			--
			local default = ".."
			--
			if key == Enum.UserInputType.MouseButton1 then
				if keybind.allowed == 1 then
					default = "MB1"
					typeis = "UserInputType"
				end
			elseif key == Enum.UserInputType.MouseButton2 then
				if keybind.allowed == 1 then
					default = "MB2"
					typeis = "UserInputType"
				end
			elseif key == Enum.UserInputType.MouseButton3 then
				if keybind.allowed == 1 then
					default = "MB3"
					typeis = "UserInputType"
				end
			else
				local capd = utility.capatalize(key.Name)
				if #capd > 1 then
					default = capd
				else
					default = key.Name
				end
				typeis = "KeyCode"
			end
			--
			keybind.value.Text = default
			keybind.current = {typeis,utility.splitenum(key)}
			keybind.callback(keybind.current)
			keybind.outline.Size = UDim2.new(0,keybind.value.TextBounds.X+20,1,0)
			--
			if keybind.down then
				keybind.down = false
				keybind.outline.BorderColor3 = Color3.fromRGB(12, 12, 12)
				local find = table.find(self.library.themeitems["accent"]["BorderColor3"],keybind.outline)
				if find then
					table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
				end
			end
		end
	end
end
--
function sections:colorpicker(props)
	-- // properties
	local name = props.name or props.Name or "new colorpicker"
	local cpname = props.cpname or props.Cpname or props.CPname or props.CPName or props.cPname or props.cpName or props.colorpickername or nil
	local def = props.def or props.Def or props.default or props.Default or Color3.fromRGB(255,255,255)
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	local parent = props.parent or self.content
	--
	local h,s,v = def:ToHSV()
	-- // variables
	local colorpicker = {}
	-- // main
	local colorpickerholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			ZIndex = 2,
			Parent = parent
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,30,1,0),
			Position = UDim2.new(1,0,0,0),
			Parent = colorpickerholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = outline
		}
	)
	--
	local cpcolor = utility.new(
		"Frame",
		{
			BackgroundColor3 = def,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Parent = outline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = cpcolor
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = colorpickerholder
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], title)
	--
	local btnSize = UDim2.new(1,0,1,0)
	local btnPos = UDim2.new(0,0,0,0)
	local btnAnchor = Vector2.new(0,0)
	if props.flag == "toggle" then
		btnSize = UDim2.new(0,30,1,0)
		btnPos = UDim2.new(1,0,0,0)
		btnAnchor = Vector2.new(1,0)
	end
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = btnAnchor,
			BackgroundTransparency = 1,
			Size = btnSize,
			Position = btnPos,
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Font = self.library.font,
			Parent = colorpickerholder
		}
	)
	--
	local cpholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,255), -- Increased height for slider
			Position = UDim2.new(0,0,1,5),
			Visible = false,
			ZIndex = 5,
			Parent = colorpickerholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 5,
			Parent = cpholder
		}
	)
	--
	local color = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = self.library.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-2,0,1),
			Position = UDim2.new(0.5,0,0,0),
			ZIndex = 5,
			Parent = outline2
		}
	)
	--
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],color)
	--
	local cptitle = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,0,20),
			Position = UDim2.new(0.5,0,0,0),
			Font = self.library.font,
			Text = cpname or name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextColor3 = self.library.theme.text,
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			ZIndex = 5,
			Parent = outline2
		}
	)
	table.insert(self.library.themeitems["text"]["TextColor3"], cptitle)
	--
	local cpholder2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0.875,0,0,150),
			Position = UDim2.new(0,5,0,20),
			ZIndex = 5,
			Parent = outline2
		}
	)
	--
	local outline3 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromHSV(h,1,1),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 5,
			Parent = cpholder2
		}
	)
	--
	local cpimage = utility.new(
		"ImageButton",
		{
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 5,
			Image = "rbxassetid://7074305282",
			Parent = outline3
		}
	)
	--
	local cpcursor = utility.new(
		"ImageLabel",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0,6,0,6),
			Position = UDim2.new(s,0,1-v,0),
			ZIndex = 5,
			Image = "rbxassetid://7074391319",
			Parent = cpimage
		}
	)
	--
	local huepicker = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0.05,0,0,150),
			Position = UDim2.new(1,-5,0,20),
			ZIndex = 5,
			Parent = outline2
		}
	)
	--
	local outline4 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 5,
			Parent = huepicker
		}
	)
	--
	local huebutton = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Font = self.library.font,
			ZIndex = 5,
			Parent = huepicker
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.10, Color3.fromRGB(255, 153, 0)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(209, 255, 0)), ColorSequenceKeypoint.new(0.30, Color3.fromRGB(55, 255, 0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 102)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 102, 255)), ColorSequenceKeypoint.new(0.70, Color3.fromRGB(51, 0, 255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(204, 0, 255)), ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 153)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))},
			Rotation = 90,
			Parent = outline4
		}
	)
	--
	local huecursor = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,12,0,6),
			Position = UDim2.new(0.5,0,h,0),
			ZIndex = 5,
			Parent = outline4
		}
	)
	--
	local huecursor_inline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromHSV(h,1,1),
			BorderColor3 = Color3.fromRGB(255, 255, 255),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			ZIndex = 5,
			Parent = huecursor
		}
	)
	--
	local function textbox(parent,size,position)
		local textbox_holder = utility.new(
			"Frame",
			{
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = position,
				Size = size,
				ZIndex = 5,
				Parent = parent
			}
		)
		--
		local outline5 = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(12, 12, 12),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = textbox_holder
			}
		)
		--
		local outline6 = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(56, 56, 56),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = outline5
			}
		)
		--
		local color2 = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,0,0),
				Position = UDim2.new(0,0,0,0),
				ZIndex = 5,
				Parent = outline6
			}
		)
		--
		utility.new(
			"UIGradient",
			{
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
				Rotation = 90,
				Parent = color2
			}
		)
		--
		local tbox = utility.new(
			"TextBox",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0.5,0,0,0),
				PlaceholderColor3 = Color3.fromRGB(255,255,255),
				PlaceholderText = "",
				Text = "",
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				Font = self.library.font,
				ZIndex = 5,
				Parent = textbox_holder
			}
		)
		--
		local tbox_button = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0,0,0,0),
				Text = "",
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				Font = self.library.font,
				ZIndex = 5,
				Parent = textbox_holder
			}
		)
		--
		tbox_button.MouseButton1Down:Connect(function()
			tbox:CaptureFocus()
		end)
		--
		return {textbox_holder,tbox,outline5}
	end
	--
	local red = textbox(outline2,UDim2.new(0,62,0,20),UDim2.new(0,5,0,175))
	local green = textbox(outline2,UDim2.new(0,62,0,20),UDim2.new(0,5,0,175))
	green[1].AnchorPoint = Vector2.new(0.5,0)
	green[1].Position = UDim2.new(0.5,0,0,175)
	local blue = textbox(outline2,UDim2.new(0,62,0,20),UDim2.new(0,5,0,175))
	blue[1].AnchorPoint = Vector2.new(1,0)
	blue[1].Position = UDim2.new(1,-5,0,175)
	-- Shrink hex box to make space for the rainbow button
	local hex = textbox(outline2,UDim2.new(1, -75, 0, 20),UDim2.new(0, 5, 0, 200))
	hex[2].Size = UDim2.new(1,-12,1,0)
	hex[2].TextXAlignment = "Left"
	-- // colorpicker tbl
	colorpicker = {
		["library"] = self.library,
		["cpholder"] = cpholder,
		["cpcolor"] = cpcolor,
		["huecursor"] = huecursor,
		["outline3"] = outline3,
		["huecursor_inline"] = huecursor_inline,
		["cpcursor"] = cpcursor,
		["current"] = def,
		["open"] = false,
		["cp"] = false,
		["hue"] = false,
		["hsv"] = {h,s,v},
		["red"] = red[2],
		["green"] = green[2],
		["blue"] = blue[2],
		["hex"] = hex[2],
		["callback"] = callback,
		["rainbowSpeed"] = 5, -- Default speed (1-10)
		["rainbowEnabled"] = false,
		["rainbowConnection"] = nil,
		["rainbowSliding"] = false
	}
	--
	-- Rainbow Button
	local rainbowButton = utility.new("TextButton", {
		Name = "RainbowButton",
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.new(0, 60, 0, 20),
		Position = UDim2.new(1, -5, 0, 200),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		BorderSizePixel = 1,
		Text = "Rainbow",
		Font = self.library.font,
		TextSize = self.library.textsize,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 6, -- ZINDEX FIX
		Parent = outline2
	})

	-- Rainbow Speed Slider
	local rainbowSliderHolder = utility.new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -45, 0, 12), -- Reduced width to fit TextBox
		Position = UDim2.new(0, 5, 0, 225),
		ZIndex = 6, -- ZINDEX FIX
		Parent = outline2
	})
	local rainbowSliderOutline = utility.new("Frame", {
		BackgroundColor3 = Color3.fromRGB(24, 24, 24),
		BorderColor3 = Color3.fromRGB(12, 12, 12),
		BorderMode = "Inset",
		BorderSizePixel = 1,
		ZIndex = 6,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = rainbowSliderHolder
	})
	local rainbowSliderOutline2 = utility.new("Frame", {
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		BorderMode = "Inset",
		BorderSizePixel = 1,
		ZIndex = 6,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = rainbowSliderOutline
	})
	local rainbowSliderFill = utility.new("Frame", {
		BackgroundColor3 = self.library.theme.accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0.5, 0, 1, 0), -- Default speed 5/10 = 0.5
		ZIndex = 7,
		Parent = rainbowSliderOutline
	})
	local rainbowSliderButton = utility.new("TextButton", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 7,
		Text = "",
		Parent = rainbowSliderHolder
	})

	-- Rainbow Speed Text Box
	local rainbowSpeedBox = utility.new("TextBox", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 30, 0, 12),
		Position = UDim2.new(1, -35, 0, 225),
		Text = tostring(colorpicker.rainbowSpeed),
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = self.library.textsize,
		Font = self.library.font,
		PlaceholderText = "Spd",
		ZIndex = 7,
		Parent = outline2
	})
	
	local function setRainbow(enabled)
		colorpicker.rainbowEnabled = enabled
		if enabled then
			rainbowButton.TextColor3 = self.library.theme.accent
			if colorpicker.rainbowConnection then colorpicker.rainbowConnection:Disconnect() end

			colorpicker.rainbowConnection = rs.Heartbeat:Connect(function()
				local speed = colorpicker.rainbowSpeed
				local cycleTime = 10.1 - speed -- Map speed 1-10 to cycle time 10-0.1
				local hue = (tick() % cycleTime) / cycleTime
				local rainbowColor = Color3.fromHSV(hue, 1, 1)
				
				-- Update internal state without triggering callbacks yet
				colorpicker.current = rainbowColor
				local h,s,v = rainbowColor:ToHSV()
				colorpicker.hsv = {h,s,v}

				-- Update UI elements
				colorpicker.cpcolor.BackgroundColor3 = rainbowColor
				colorpicker.outline3.BackgroundColor3 = Color3.fromHSV(h,1,1)
				colorpicker.huecursor_inline.BackgroundColor3 = Color3.fromHSV(h,1,1)
				colorpicker.huecursor.Position = UDim2.new(0.5,0,h,0)
				colorpicker.cpcursor.Position = UDim2.new(s,0,1-v,0)

				-- Update text boxes
				colorpicker.red.PlaceholderText = "R: "..tostring(math.floor(rainbowColor.R*255))
				colorpicker.green.PlaceholderText = "G: "..tostring(math.floor(rainbowColor.G*255))
				colorpicker.blue.PlaceholderText = "B: "..tostring(math.floor(rainbowColor.B*255))
				colorpicker.hex.PlaceholderText = "Hex: "..utility.to_hex(rainbowColor)

				-- Finally, call the external callback
				colorpicker.callback(rainbowColor)
			end)
			activeRainbows[colorpicker] = true -- Register to centralized loop
		else
			rainbowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			if colorpicker.rainbowConnection then
				colorpicker.rainbowConnection:Disconnect()
				colorpicker.rainbowConnection = nil
			end
			activeRainbows[colorpicker] = nil -- Unregister
			-- Restore to the last static color by calling the main set function
			colorpicker:set(Color3.fromHSV(unpack(colorpicker.hsv)))
		end
	end

	rainbowButton.MouseButton1Click:Connect(function()
		setRainbow(not colorpicker.rainbowEnabled)
	end)

	local function updateRainbowSpeed()
		local size = math.clamp(plr:GetMouse().X - rainbowSliderOutline.AbsolutePosition.X, 0, rainbowSliderOutline.AbsoluteSize.X)
		local result = (10 - 1) / rainbowSliderOutline.AbsoluteSize.X * size + 1 -- Map to 1-10 range
		colorpicker.rainbowSpeed = utility.round(result, 1)
		local newSpeed = utility.round(result, 1)
		colorpicker.rainbowSpeed = newSpeed
		rainbowSpeedBox.Text = tostring(newSpeed)
		rainbowSliderFill:TweenSize(UDim2.new(size / rainbowSliderOutline.AbsoluteSize.X, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
	end

	-- Text Box Logic
	rainbowSpeedBox.FocusLost:Connect(function()
		local num = tonumber(rainbowSpeedBox.Text)
		if num then
			num = math.clamp(num, 1, 10)
			colorpicker.rainbowSpeed = num
			-- Update slider visual
			local percent = (num - 1) / 9
			rainbowSliderFill:TweenSize(UDim2.new(percent, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
		end
		rainbowSpeedBox.Text = tostring(colorpicker.rainbowSpeed)
	end)

	rainbowSliderButton.MouseButton1Down:Connect(function() colorpicker.rainbowSliding = true; updateRainbowSpeed() end)
	uis.InputChanged:Connect(function() if colorpicker.rainbowSliding then updateRainbowSpeed() end end)
	uis.InputEnded:Connect(function(input) if input.UserInputType.Name == 'MouseButton1' and colorpicker.rainbowSliding then colorpicker.rainbowSliding = false end end)
	
	-- Proper Input Handling: Add to library connections for cleanup
	local rbInputChanged = uis.InputChanged:Connect(function() if colorpicker.rainbowSliding then updateRainbowSpeed() end end)
	local rbInputEnded = uis.InputEnded:Connect(function(input) if input.UserInputType.Name == 'MouseButton1' and colorpicker.rainbowSliding then colorpicker.rainbowSliding = false end end)
	
	table.insert(self.library.connections, rbInputChanged)
	table.insert(self.library.connections, rbInputEnded)

	table.insert(self.library.colorpickers,colorpicker)
	--
	local function updateboxes()
		colorpicker.red.PlaceholderText = "R: "..tostring(math.floor(colorpicker.current.R*255))
		colorpicker.green.PlaceholderText = "G: "..tostring(math.floor(colorpicker.current.G*255))
		colorpicker.blue.PlaceholderText = "B: "..tostring(math.floor(colorpicker.current.B*255))
		colorpicker.hex.PlaceholderText = "Hex: "..utility.to_hex(colorpicker.current)
	end
	--
	updateboxes()
	--
	local function movehue()
		if colorpicker.rainbowEnabled then setRainbow(false) end
		local posy = math.clamp(plr:GetMouse().Y-outline3.AbsolutePosition.Y,0,outline3.AbsoluteSize.Y)
		local resy = (1/outline3.AbsoluteSize.Y)*posy
		outline3.BackgroundColor3 = Color3.fromHSV(resy,1,1)
		huecursor_inline.BackgroundColor3 = Color3.fromHSV(resy,1,1)
		colorpicker.hsv[1] = resy
		colorpicker.current = Color3.fromHSV(colorpicker.hsv[1],colorpicker.hsv[2],colorpicker.hsv[3])
		cpcolor.BackgroundColor3 = colorpicker.current
		updateboxes()
		colorpicker.callback(colorpicker.current)
		huecursor:TweenPosition(UDim2.new(0.5,0,resy,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true)
	end
	--
	local function movecp()
		if colorpicker.rainbowEnabled then setRainbow(false) end
		local posx,posy = math.clamp(plr:GetMouse().X-outline3.AbsolutePosition.X,0,outline3.AbsoluteSize.X),math.clamp(plr:GetMouse().Y-outline3.AbsolutePosition.Y,0,outline3.AbsoluteSize.Y)
		local resx,resy = (1/outline3.AbsoluteSize.X)*posx,(1/outline3.AbsoluteSize.Y)*posy
		colorpicker.hsv[2] = resx
		colorpicker.hsv[3] = 1-resy
		colorpicker.current = Color3.fromHSV(colorpicker.hsv[1],colorpicker.hsv[2],colorpicker.hsv[3])
		cpcolor.BackgroundColor3 = colorpicker.current
		updateboxes()
		colorpicker.callback(colorpicker.current)
		cpcursor:TweenPosition(UDim2.new(resx,0,resy,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true)
	end
	--
	huebutton.MouseButton1Down:Connect(function()
		colorpicker.hue = true
		movehue()
	end)
	--
	cpimage.MouseButton1Down:Connect(function()
		colorpicker.cp = true
		movecp()
	end)
	--
	button.MouseButton1Down:Connect(function()
		self.library:closewindows(colorpicker)
		colorpicker.open = not colorpicker.open
		cpholder.Visible = colorpicker.open

		if colorpicker.open then
			-- Re-parent to main screen to draw over everything, using absolute size and position
			local absoluteSize = colorpickerholder.AbsoluteSize
			cpholder.Parent = self.library.screen
			cpholder.Size = UDim2.fromOffset(absoluteSize.X, 255)
			cpholder.Position = UDim2.fromOffset(colorpickerholder.AbsolutePosition.X, colorpickerholder.AbsolutePosition.Y + colorpickerholder.AbsoluteSize.Y + 5)
		else
			-- Parent back to original holder and restore relative properties
			cpholder.Parent = colorpickerholder
			cpholder.Size = UDim2.new(1,0,0,255)
			cpholder.Position = UDim2.new(0,0,1,5)
		end
	end)
	--
	local inputChangedConn = uis.InputChanged:Connect(function()
		if colorpicker.cp then
			movecp()
		end
		if colorpicker.hue then
			movehue()
		end
	end)
	table.insert(self.library.connections, inputChangedConn)
	local inputEndedConn = uis.InputEnded:Connect(function(Input)
		if Input.UserInputType.Name == 'MouseButton1'  then
			if colorpicker.cp then
				colorpicker.cp = false
			end
			if colorpicker.hue then
				colorpicker.hue = false
			end
		end
	end)
	table.insert(self.library.connections, inputEndedConn)

	red[2].Focused:Connect(function()
		red[3].BorderColor3 = self.library.theme.accent
	end)
	--
	red[2].FocusLost:Connect(function()
		if colorpicker.rainbowEnabled then setRainbow(false) end
		local saved = red[2].Text
		local num = tonumber(saved)
		if num then
			saved = tostring(math.clamp(tonumber(saved),0,255))
			red[2].Text = ""
			if saved then
				if #saved >= 1 and #saved <= 3 then
					red[2].PlaceholderText = "R: "..tostring(saved)
				end
				colorpicker:set(Color3.fromRGB(tonumber(saved),colorpicker.current.G*255,colorpicker.current.B*255))
				red[3].BorderColor3 = Color3.fromRGB(12,12,12)
			else
				red[3].BorderColor3 = Color3.fromRGB(12,12,12)
			end
		else
			red[2].Text = ""
			red[3].BorderColor3 = Color3.fromRGB(12,12,12)
		end
	end)
	--
	green[2].Focused:Connect(function()
		green[3].BorderColor3 = self.library.theme.accent
	end)
	--
	green[2].FocusLost:Connect(function()
		if colorpicker.rainbowEnabled then setRainbow(false) end
		local saved = green[2].Text
		local num = tonumber(saved)
		if num then
			saved = tostring(math.clamp(tonumber(saved),0,255))
			green[2].Text = ""
			if saved then
				if #saved >= 1 and #saved <= 3 then
					green[2].PlaceholderText = "G: "..tostring(saved)
				end
				colorpicker:set(Color3.fromRGB(colorpicker.current.R*255,tonumber(saved),colorpicker.current.B*255))
				green[3].BorderColor3 = Color3.fromRGB(12,12,12)
			else
				green[3].BorderColor3 = Color3.fromRGB(12,12,12)
			end
		else
			green[2].Text = ""
			green[3].BorderColor3 = Color3.fromRGB(12,12,12)
		end
	end)
	--
	blue[2].Focused:Connect(function()
		blue[3].BorderColor3 = self.library.theme.accent
	end)
	--
	blue[2].FocusLost:Connect(function()
		if colorpicker.rainbowEnabled then setRainbow(false) end
		local saved = blue[2].Text
		local num = tonumber(saved)
		if num then
			saved = tostring(math.clamp(tonumber(saved),0,255))
			blue[2].Text = ""
			if saved then
				if #saved >= 1 and #saved <= 3 then
					blue[2].PlaceholderText = "B: "..tostring(saved)
				end
				colorpicker:set(Color3.fromRGB(colorpicker.current.R*255,colorpicker.current.G*255,tonumber(saved)))
				blue[3].BorderColor3 = Color3.fromRGB(12,12,12)
			else
				blue[3].BorderColor3 = Color3.fromRGB(12,12,12)
			end
		else
			blue[2].Text = ""
			blue[3].BorderColor3 = Color3.fromRGB(12,12,12)
		end
	end)
	--
	hex[2].Focused:Connect(function()
		hex[3].BorderColor3 = self.library.theme.accent
	end)
	--
	hex[2].FocusLost:Connect(function()
		if colorpicker.rainbowEnabled then setRainbow(false) end
		local saved = hex[2].Text
		if #saved >= 6 and #saved <= 7 then
			local e,s = pcall(function()
				utility.from_hex(saved)
			end)
			if e == true then
				local hexcolor = utility.from_hex(saved)
				if hexcolor then
					colorpicker:set(hexcolor)
					hex[2].Text = ""
					hex[3].BorderColor3 = Color3.fromRGB(12,12,12)
				else
					hex[2].Text = ""
					hex[3].BorderColor3 = Color3.fromRGB(12,12,12)
				end
			else
				hex[2].Text = ""
				hex[3].BorderColor3 = Color3.fromRGB(12,12,12)
			end
		else
			hex[2].Text = ""
			hex[3].BorderColor3 = Color3.fromRGB(12,12,12)
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	--
	if pointer then
		if self.pointers then
			self.pointers[tostring(pointer)] = colorpicker
		end
	end
	--
	self.library.labels[#self.library.labels+1] = title
	self.library.labels[#self.library.labels+1] = hex[2]
	self.library.labels[#self.library.labels+1] = red[2]
	self.library.labels[#self.library.labels+1] = green[2]
	self.library.labels[#self.library.labels+1] = blue[2]
	self.library.labels[#self.library.labels+1] = cptitle
	-- // metatable indexing + return
	callback(def)
	setmetatable(colorpicker, colorpickers)
	return colorpicker
end


--
function colorpickers:set(color)
	if color then
		if typeof(color) == "table" then
			color = Color3.fromRGB(color[1]*255,color[2]*255,color[3]*255)
		end
		local colorpicker = self
		local h,s,v = color:ToHSV()

		-- When a color is set programmatically, disable rainbow mode.
		if colorpicker.rainbowEnabled then
			colorpicker.rainbowEnabled = false
			if colorpicker.rainbowConnection then
				colorpicker.rainbowConnection:Disconnect()
				colorpicker.rainbowConnection = nil
			end
			activeRainbows[colorpicker] = nil -- Unregister
			-- Find the rainbow button associated with this colorpicker and update its color
			local rainbowButton
			if colorpicker.cpholder then
				rainbowButton = colorpicker.cpholder:FindFirstChild("RainbowButton", true)
			end
			if rainbowButton then
				rainbowButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
		end

		--
		local function updateboxes()
			colorpicker.red.PlaceholderText = "R: "..tostring(math.floor(colorpicker.current.R*255))
			colorpicker.green.PlaceholderText = "G: "..tostring(math.floor(colorpicker.current.G*255))
			colorpicker.blue.PlaceholderText = "B: "..tostring(math.floor(colorpicker.current.B*255))
			colorpicker.hex.PlaceholderText = "Hex: "..utility.to_hex(colorpicker.current)
		end
		--
		local function movehue()
			colorpicker.outline3.BackgroundColor3 = Color3.fromHSV(h,1,1)
			colorpicker.huecursor_inline.BackgroundColor3 = Color3.fromHSV(h,1,1)
			colorpicker.hsv[1] = h
			colorpicker.current = Color3.fromHSV(colorpicker.hsv[1],colorpicker.hsv[2],colorpicker.hsv[3])
			colorpicker.cpcolor.BackgroundColor3 = colorpicker.current
			colorpicker.huecursor:TweenPosition(UDim2.new(0.5,0,h,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true)
		end
		--
		local function movecp()
			colorpicker.hsv[2] = s
			colorpicker.hsv[3] = v
			colorpicker.current = Color3.fromHSV(colorpicker.hsv[1],colorpicker.hsv[2],colorpicker.hsv[3])
			colorpicker.cpcolor.BackgroundColor3 = colorpicker.current
			colorpicker.cpcursor:TweenPosition(UDim2.new(s,0,1-v,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true)
		end
		--
		movehue()
		movecp()
		updateboxes()
		colorpicker.callback(colorpicker.current)
	end
end


--
function sections:configloader(props)
	-- // properties
	local folder = props.folder or props.Folder
	-- // variables
	local configloader = {}
	-- // main
	local clholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,222),
			Parent = self.content
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = clholder
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = outline
		}
	)
	--
	local title = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,3),
			Font = self.library.font,
			Text = "configs",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Center",
			Parent = outline
		}
	)
	--
	self.library.labels[#self.library.labels+1] = title
	--
	local color = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = self.library.theme.accent,
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-6,0,1),
			Position = UDim2.new(0.5,0,0,19),
			Parent = outline
		}
	)
	--
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],color)
	--
	local buttonsholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,0,64),
			Position = UDim2.new(0,0,0,150),
			Parent = outline
		}
	)
	--
	local configsholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-10,0,120),
			Position = UDim2.new(0.5,0,0,25),
			Parent = outline
		}
	)
	--
	local outline3 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = configsholder
		}
	)
	--
	local outline4 = utility.new(
		"ScrollingFrame",
		{
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			ClipsDescendants = true,
			AutomaticCanvasSize = "Y",
			CanvasSize = UDim2.new(0,0,0,0),
			ScrollBarImageTransparency = 0.25,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 5,
			VerticalScrollBarInset = "ScrollBar",
			VerticalScrollBarPosition = "Right",
			Parent = outline3
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,0),
			Parent = outline4
		}
	)
	--
	local createdbuttons = {}
	local selected
	--
	local makebutton = function(name,toggled)
		local createdbutton = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,18),
				Position = UDim2.new(0,0,0,0),
				Text = "",
				Parent = outline4
			}
		)
		--
		local grey = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundColor3 = Color3.fromRGB(125, 125, 125),
				BackgroundTransparency = 0.9,
				BorderSizePixel = 0,
				Size = UDim2.new(1,-4,1,0),
				Position = UDim2.new(0.5,0,0,0),
				Visible = false,
				Parent = createdbutton
			}
		)
		--
		local createdtitle = utility.new(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,-10,1,0),
				Position = UDim2.new(0.5,0,0,0),
				Font = self.library.font,	
				Text = name,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Left",
				Parent = createdbutton
			}
		)
		--
		self.library.labels[#self.library.labels+1] = createdtitle
		--
		local createdb = {
			["button"] = createdbutton,
			["grey"] = grey,
			["title"] = createdtitle,
			["name"] = name
		}
		--
		table.insert(createdbuttons,createdb)
		--
		if toggled then
			createdb.grey.Visible = true
			createdb.title.TextColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["TextColor3"],createdb.title)
			selected = createdb
		end
		--
		createdbutton.MouseButton1Down:Connect(function()
			for i,v in pairs(createdbuttons) do
				if v ~= createdb then
					v.grey.Visible = false
					v.title.TextColor3 = Color3.fromRGB(255,255,255)
					local find = table.find(self.library.themeitems["accent"]["TextColor3"],v.title)
					if find then
						table.remove(self.library.themeitems["accent"]["TextColor3"],find)
					end
				end
			end
			--
			createdb.grey.Visible = true
			createdb.title.TextColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["TextColor3"],createdb.title)
			selected = createdb
		end)
	end
	--
	local newbutton = function(parent,name)
		local button_holder = utility.new(
			"Frame",
			{
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 5,
				Parent = parent
			}
		)
		--
		local button_outline = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(12, 12, 12),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = button_holder
			}
		)
		--
		local button_outline2 = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(56, 56, 56),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = button_outline
			}
		)
		--
		local button_color = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,0,0),
				Position = UDim2.new(0,0,0,0),
				ZIndex = 5,
				Parent = button_outline2
			}
		)
		--
		utility.new(
			"UIGradient",
			{
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
				Rotation = 90,
				Parent = button_color
			}
		)
		--
		local button_button = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0,0,0,0),
				Text = name,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				Font = self.library.font,
				ZIndex = 5,
				Parent = button_holder
			}
		)
		--
		self.library.labels[#self.library.labels+1] = button_button
		--
		return {button_holder,button_outline,button_button}
	end
	--
	local function textbox(parent)
		local textbox_holder = utility.new(
			"Frame",
			{
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 5,
				Parent = parent
			}
		)
		--
		local outline5 = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(12, 12, 12),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = textbox_holder
			}
		)
		--
		local outline6 = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(56, 56, 56),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = outline5
			}
		)
		--
		local color2 = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,0,0),
				Position = UDim2.new(0,0,0,0),
				ZIndex = 5,
				Parent = outline6
			}
		)
		--
		utility.new(
			"UIGradient",
			{
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
				Rotation = 90,
				Parent = color2
			}
		)
		--
		local tbox = utility.new(
			"TextBox",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0.5,0,0,0),
				PlaceholderColor3 = Color3.fromRGB(178, 178, 178),
				PlaceholderText = "",
				Text = "",
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				Font = self.library.font,
				ZIndex = 5,
				Parent = textbox_holder
			}
		)
		--
		local tbox_button = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0,0,0,0),
				Text = "",
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				Font = self.library.font,
				ZIndex = 5,
				Parent = textbox_holder
			}
		)
		--
		tbox_button.MouseButton1Down:Connect(function()
			tbox:CaptureFocus()
		end)
		--
		return {textbox_holder,tbox,outline5}
	end
	--
	local refresh = function()
		for i,v in pairs(createdbuttons) do
			v.button:Remove()
			v.grey:Remove()
			v.title:Remove()
		end
		createdbuttons = {}
		for i,v in pairs(listfiles(folder)) do
			if v:sub(-4) == ".cfg" then
				if i == 1 then 
					makebutton(v:sub(#tostring(folder)+2, -5),true)
				else
					makebutton(v:sub(#tostring(folder)+2, -5),false)
				end
			end
		end
	end
	--
	refresh()
	--
	local name = textbox(buttonsholder)
	local load = newbutton(buttonsholder,"Load")
	local delete = newbutton(buttonsholder,"Delete")
	local save = newbutton(buttonsholder,"Save")
	local create = newbutton(buttonsholder,"Create")
	--
	name[1].Size = UDim2.new(1,-10,0,20)
	load[1].Size = UDim2.new(0.5,-6,0,20)
	delete[1].Size = UDim2.new(0.5,-6,0,20)
	save[1].Size = UDim2.new(0.5,-6,0,20)
	create[1].Size = UDim2.new(0.5,-6,0,20)
	--
	name[1].Position = UDim2.new(0.5,0,0,0)
	name[1].AnchorPoint = Vector2.new(0.5,0)
	--
	load[1].Position = UDim2.new(0,5,0,22)
	load[1].AnchorPoint = Vector2.new(0,0)
	--
	delete[1].Position = UDim2.new(1,-5,0,22)
	delete[1].AnchorPoint = Vector2.new(1,0)
	--
	save[1].Position = UDim2.new(0,5,0,44)
	save[1].AnchorPoint = Vector2.new(0,0)
	--
	create[1].Position = UDim2.new(1,-5,0,44)
	create[1].AnchorPoint = Vector2.new(1,0)
	--
	name[2].PlaceholderText = "Name"
	--
	local currentname = nil
	--
	name[2].Focused:Connect(function()
		name[3].BorderColor3 = self.library.theme.accent
	end)
	--
	name[2].FocusLost:Connect(function()
		local saved = name[2].Text
		if #saved >= 3 and #saved <= 15 then
			currentname = saved
		else
			name[2].Text = ""
			currentname = nil
		end
		name[3].BorderColor3 = Color3.fromRGB(12,12,12)
	end)
	--
	load[3].MouseButton1Down:Connect(function()
		self.library:loadconfig(folder..selected.name..".cfg")
		load[2].BorderColor3 = self.library.theme.accent
		wait(0.05)
		load[2].BorderColor3 = Color3.fromRGB(12,12,12)
		if selected then
			self.library:loadconfig(folder..selected.name..".cfg")
			load[2].BorderColor3 = self.library.theme.accent
			wait(0.05)
			load[2].BorderColor3 = Color3.fromRGB(12,12,12)
		else
			if self.library.notify then
				self.library.notify({Title = "Config Error", Description = "Please select a config first.", Duration = 3})
			end
		end
	end)
	--
	delete[3].MouseButton1Down:Connect(function()
		delfile(folder..selected.name..".cfg")
		delete[2].BorderColor3 = self.library.theme.accent
		wait(0.05)
		delete[2].BorderColor3 = Color3.fromRGB(12,12,12)
		wait()
		refresh()
		if selected then
			delfile(folder..selected.name..".cfg")
			delete[2].BorderColor3 = self.library.theme.accent
			wait(0.05)
			delete[2].BorderColor3 = Color3.fromRGB(12,12,12)
			wait()
			refresh()
		else
			if self.library.notify then
				self.library.notify({Title = "Config Error", Description = "Please select a config first.", Duration = 3})
			end
		end
	end)
	--
	save[3].MouseButton1Down:Connect(function()
		writefile(folder..selected.name..".cfg", self.library:saveconfig())
		save[2].BorderColor3 = self.library.theme.accent
		wait(0.05)
		save[2].BorderColor3 = Color3.fromRGB(12,12,12)
		wait()
		refresh()
		if selected then
			writefile(folder..selected.name..".cfg", self.library:saveconfig())
			save[2].BorderColor3 = self.library.theme.accent
			wait(0.05)
			save[2].BorderColor3 = Color3.fromRGB(12,12,12)
			wait()
			refresh()
		else
			if self.library.notify then
				self.library.notify({Title = "Config Error", Description = "Please select a config first.", Duration = 3})
			end
		end
	end)
	--
	create[3].MouseButton1Down:Connect(function()
		writefile(folder..currentname..".cfg", self.library:saveconfig())
		create[2].BorderColor3 = self.library.theme.accent
		wait(0.05)
		create[2].BorderColor3 = Color3.fromRGB(12,12,12)
		wait()
		refresh()
		if currentname then
			writefile(folder..currentname..".cfg", self.library:saveconfig())
			create[2].BorderColor3 = self.library.theme.accent
			wait(0.05)
			create[2].BorderColor3 = Color3.fromRGB(12,12,12)
			wait()
			refresh()
		else
			if self.library.notify then
				self.library.notify({Title = "Config Error", Description = "Please enter a valid name (3-15 chars).", Duration = 3})
			end
		end
	end)
	-- // button tbl
	configloader = {
		["library"] = self.library
	}
	-- // metatable indexing + return
	setmetatable(configloader, configloaders)
	return configloader 
end

function library:destroy()
	-- Disconnect all connections created by this window and its children
	for _, connection in ipairs(self.connections) do
		connection:Disconnect()
	end
	self.connections = {}

	-- Destroy the main ScreenGui, which will cascade to all children
	self.screen:Destroy()
	if self.hudScreen then self.hudScreen:Destroy() end
end

function library:hud(props)
	local title = props.title or "HUD"
	local draggableBody = props.draggableBody
	local width = props.width -- Optional fixed width
	local hud = {}

	local mainFrame = utility.new("Frame", {
		Name = "HUD_Frame",
		AnchorPoint = width and Vector2.new(0, 0) or Vector2.new(0.5, 0),
		BackgroundColor3 = self.theme.background,
		BorderColor3 = self.theme.outline,
		BorderSizePixel = 1,
		Size = width and UDim2.new(0, width, 0, 0) or UDim2.new(0, 0, 0, 0),
		Position = width and UDim2.new(0, 10, 0.3, 0) or UDim2.new(0.5, 0, 0.3, 0),
		AutomaticSize = width and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
		Visible = false, -- Hidden by default
		Parent = self.hudScreen,
	})

	local titleBar = utility.new("Frame", {
		Name = "TitleBar",
		BackgroundColor3 = self.theme.accent,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 20),
		Visible = not draggableBody,
		Parent = mainFrame,
	})
	table.insert(self.themeitems["accent"]["BackgroundColor3"], titleBar)

	local titleLabel = utility.new("TextLabel", {
		Name = "TitleLabel",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -10, 1, 0),
		Position = UDim2.new(0, 5, 0, 0),
		Font = self.font,
		Text = title,
		TextColor3 = self.theme.text,
		TextSize = self.textsize,
		TextXAlignment = Enum.TextXAlignment.Left,
		Parent = titleBar,
	})
	self.labels[#self.labels + 1] = titleLabel

	local contentFrame = utility.new("Frame", {
		Name = "ContentFrame",
		BackgroundTransparency = 1,
		Size = width and UDim2.new(1, 0, 0, 0) or UDim2.new(0, 0, 0, 0),
		Position = draggableBody and UDim2.new(0, 0, 0, 5) or UDim2.new(0, 0, 0, 20),
		AutomaticSize = width and Enum.AutomaticSize.Y or Enum.AutomaticSize.XY,
		Parent = mainFrame,
	})

	utility.new("UIListLayout", {
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Parent = contentFrame,
	})

	utility.new("UIPadding", {
		PaddingTop = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 5),
		Parent = contentFrame,
	})

	if draggableBody then
		utility.dragify(mainFrame, mainFrame, function() return self.isOpen end)
	else
		utility.dragify(titleBar, mainFrame, function() return self.isOpen end)
	end

	-- Register HUD elements for theming
	self:register("background", "BackgroundColor3", mainFrame)
	self:register("outline", "BorderColor3", mainFrame)
	self:register("text", "TextColor3", titleLabel)

	hud = {
		frame = mainFrame,
		content = contentFrame,
		theme = self.theme,
		labels = {}, -- [key] = label
		Add = function(self, key, text)
			if self.labels[key] then
				self.labels[key].Text = text
				return
			end
			
			-- Fallback: Check if label exists in UI but missing from cache (Prevents spamming)
			local existing = self.content:FindFirstChild(tostring(key))
			if existing then
				self.labels[key] = existing
				existing.Text = text
				return
			end

			local label = utility.new("TextLabel", {
				Name = tostring(key),
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 0, 16),
				AutomaticSize = Enum.AutomaticSize.X,
				Font = Enum.Font.SourceSans,
				TextSize = 14,
				TextColor3 = self.theme.text,
				TextXAlignment = Enum.TextXAlignment.Center,
				Text = text,
				Parent = self.content,
			})
			self:register("text", "TextColor3", label)
			self.labels[key] = label
		end,
		Remove = function(self, key)
			if self.labels[key] then
				self.labels[key]:Destroy()
				self.labels[key] = nil
			else
				local existing = self.content:FindFirstChild(tostring(key))
				if existing then existing:Destroy() end
			end
		end,
		Clear = function(self)
			for key, label in pairs(self.labels) do
				label:Destroy()
			end
			self.labels = {}
		end,
		SetVisible = function(self, visible)
			self.frame.Visible = visible
		end,
		SetTransparency = function(self, transparency)
			self.frame.BackgroundTransparency = transparency
			local titleBar = self.frame:FindFirstChild("TitleBar")
			if titleBar then
				titleBar.BackgroundTransparency = transparency
			end
		end,
	}

	setmetatable(hud, huds)
	return hud
end

-- Centralized Heartbeat Loop for Performance (Moved to end to ensure utility is defined)
rs.Heartbeat:Connect(function()
	for cp, _ in pairs(activeRainbows) do
		if cp.rainbowEnabled then
			local speed = cp.rainbowSpeed
			local cycleTime = 10.1 - speed -- Map speed 1-10 to cycle time
			local hue = (tick() % cycleTime) / cycleTime
			local rainbowColor = Color3.fromHSV(hue, 1, 1)
			
			-- Update internal state
			cp.current = rainbowColor
			local h,s,v = rainbowColor:ToHSV()
			cp.hsv = {h,s,v}

			-- Update UI elements
			cp.cpcolor.BackgroundColor3 = rainbowColor
			cp.outline3.BackgroundColor3 = Color3.fromHSV(h,1,1)
			cp.huecursor_inline.BackgroundColor3 = Color3.fromHSV(h,1,1)
			cp.huecursor.Position = UDim2.new(0.5,0,h,0)
			cp.cpcursor.Position = UDim2.new(s,0,1-v,0)

			-- Update Rainbow Button Text
			if cp.rainbowButton then
				cp.rainbowButton.TextColor3 = rainbowColor
			end

			-- Update text boxes (Visual only, no callback trigger to prevent recursion)
			cp.red.PlaceholderText = "R: "..tostring(math.floor(rainbowColor.R*255))
			cp.green.PlaceholderText = "G: "..tostring(math.floor(rainbowColor.G*255))
			cp.blue.PlaceholderText = "B: "..tostring(math.floor(rainbowColor.B*255))
			cp.hex.PlaceholderText = "Hex: "..utility.to_hex(rainbowColor)

			-- Trigger callback
			cp.callback(rainbowColor)
		end
	end
end)

return library
