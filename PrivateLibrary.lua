-- loadstring(game:HttpGet("https://raw.githubusercontent.com/FZGecko/Nothing/refs/heads/main/PrivateLibrary.lua"))()
-- main.lua
local function GetSafeService(service_name)
    local service = game:GetService(service_name)
    if cloneref and type(cloneref) == "function" then
        return cloneref(service)
    end
    return service
end

local UserInputService = GetSafeService("UserInputService")
local TweenService = GetSafeService("TweenService")
local RunService = GetSafeService("RunService")
local CoreGui = GetSafeService("CoreGui")
local Players = GetSafeService("Players")
local HttpService = GetSafeService("HttpService")
local TextService = GetSafeService("TextService")
local MarketplaceService = GetSafeService("MarketplaceService")
local Stats = GetSafeService("Stats")

local function GetGlobalEnv()
    return (getgenv and getgenv()) or _G
end

local GlobalEnv = GetGlobalEnv()

local Library = {}
Library.__index = Library
Library.Version = "1.0.0"
Library.Keybinds = {}
Library.Rainbows = setmetatable({}, {__mode = "k"}) -- [Optimization] Weak keys to prevent memory leaks
Library.ThemeObjects = setmetatable({}, {__mode = "k"}) -- [Optimization] Registry for themed objects

local Utility = {}

-- [Optimization] Cached TweenInfos to prevent object churning
local function SafeTweenInfo(t, s, d)
    if not (TweenInfo and TweenInfo.new) then return nil end
    if s and d then
        return TweenInfo.new(t, s, d)
    elseif s then
        return TweenInfo.new(t, s)
    end
    return TweenInfo.new(t)
end

local TI_01 = SafeTweenInfo(0.1)
local TI_02 = SafeTweenInfo(0.2)
local TI_QuadOut = (Enum and Enum.EasingStyle) and SafeTweenInfo(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out) or nil

function Utility.RandomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local str = ""
    for i = 1, length do
        local rand = math.random(1, #chars)
        str = str .. string.sub(chars, rand, rand)
    end
    return str
end

function Utility.Create(instanceType, properties, themeBindings)
    local instance = Instance.new(instanceType)
    if properties then
        for property, value in pairs(properties) do
            instance[property] = value
        end
    end
    if themeBindings then
        for property, themeKey in pairs(themeBindings) do
            if not Library.ThemeObjects[instance] then Library.ThemeObjects[instance] = {} end
            Library.ThemeObjects[instance][property] = themeKey
            -- Apply immediately if theme exists
            if Library.Theme and Library.Theme[themeKey] then instance[property] = Library.Theme[themeKey] end
        end
    end
    return instance
end

function Utility.Drag(frame, dragHandle, library)
    dragHandle = dragHandle or frame
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            library.DraggingFrame = {
                Frame = frame,
                DragStart = input.Position,
                StartPos = frame.Position,
                Input = input
            }
        end
    end)
end

function Utility.GetSafeContainer()
    if gethui then
        return gethui()
    elseif syn and syn.protect_gui then 
        return CoreGui
    elseif CoreGui then
        return CoreGui
    else
        return Players.LocalPlayer:WaitForChild("PlayerGui")
    end
end

function Utility.AddRowHover(frame, theme)
    frame.BackgroundColor3 = theme.Sidebar
    frame.BackgroundTransparency = 1
    if not Library.ThemeObjects[frame] then Library.ThemeObjects[frame] = {} end
    Library.ThemeObjects[frame]["BackgroundColor3"] = "Sidebar"

    -- [Optimization] Create tweens once, reuse them.
    if TI_02 then
        local tIn = TweenService:Create(frame, TI_02, { BackgroundTransparency = 0 })
        local tOut = TweenService:Create(frame, TI_02, { BackgroundTransparency = 1 })

        frame.MouseEnter:Connect(function() tIn:Play() end)
        frame.MouseLeave:Connect(function() tOut:Play() end)
    else
        -- Fallback if TweenInfo failed
        frame.MouseEnter:Connect(function() frame.BackgroundTransparency = 0 end)
        frame.MouseLeave:Connect(function() frame.BackgroundTransparency = 1 end)
    end
end

function Utility.SafeSave(data)
    local success, encoded = pcall(HttpService.JSONEncode, HttpService, data)
    if not success then return nil end
    return encoded
end

function Utility.SafeLoad(str)
    local success, decoded = pcall(HttpService.JSONDecode, HttpService, str)
    if not success then return nil end
    return decoded
end

function Utility.ColorToTable(color)
    return {R = color.R, G = color.G, B = color.B}
end

function Utility.TableToColor(tbl)
    if not tbl then return Color3.new(1,1,1) end
    return Color3.new(tbl.R, tbl.G, tbl.B)
end

function Utility.ToHex(color)
    return string.format("#%02X%02X%02X", color.R * 255, color.G * 255, color.B * 255)
end

function Utility.UDim2ToTable(udim2)
    return {SX = udim2.X.Scale, OX = udim2.X.Offset, SY = udim2.Y.Scale, OY = udim2.Y.Offset}
end

function Utility.TableToUDim2(tbl)
    return UDim2.new(tbl.SX or 0, tbl.OX or 0, tbl.SY or 0, tbl.OY or 0)
end

function Utility.pcallNotify(library, func, ...)
    if not func then return end
    local success, err = pcall(func, ...)
    if not success then
        library:Notify({
            Title = "Script Error",
            Content = tostring(err),
            Duration = 10
        })
    end
end

local Janitor = {}
Janitor.__index = Janitor
function Janitor.new()
    return setmetatable({ Tasks = {} }, Janitor)
end
function Janitor:Add(task)
    if type(task) == "function" then
        table.insert(self.Tasks, task)
    elseif typeof(task) == "RBXScriptConnection" then
        table.insert(self.Tasks, function() task:Disconnect() end)
    elseif typeof(task) == "Instance" then
        table.insert(self.Tasks, function() task:Destroy() end)
    end
    return task
end
function Janitor:Destroy()
    for i = #self.Tasks, 1, -1 do
        pcall(self.Tasks[i])
        table.remove(self.Tasks, i)
    end
end

local function AttachBindLogic(button, initialBind, onBindChanged, theme, library)
    local currentBind = initialBind
    local listening = false
    local connection = nil -- [Fix] Store connection to disconnect later
    local function UpdateText()
        local text = "None"
        if currentBind then
            if currentBind.Name == "MouseButton1" then text = "M1"
            elseif currentBind.Name == "MouseButton2" then text = "M2"
            elseif currentBind.Name == "MouseButton3" then text = "M3"
            else text = currentBind.Name end
        end
        button.Text = text
    end
    UpdateText()

    local function StopListening()
        listening = false
        if connection then
            connection:Disconnect()
            connection = nil
        end
        UpdateText()
        button.TextColor3 = theme.TextDim
    end

    button.MouseButton1Click:Connect(function()
        if not listening then
            button.Text = "..."
            button.TextColor3 = theme.Accent
            task.wait(0.2)
            listening = true
            
            -- [Fix] Only connect to InputBegan when actually listening
            connection = UserInputService.InputBegan:Connect(function(input)
                local bind = nil
                if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                    if input.KeyCode == Enum.KeyCode.Escape then
                        StopListening()
                        currentBind = nil
                        Utility.pcallNotify(library, onBindChanged, nil)
                        return
                    end
                    bind = input.KeyCode
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
                    bind = input.UserInputType
                end

                if bind then
                    currentBind = bind
                    StopListening()
                    Utility.pcallNotify(library, onBindChanged, bind)
                end
            end)
        end
    end)
    
    button.Destroying:Connect(function() 
        if connection then connection:Disconnect() end 
    end)
    return function() return currentBind end
end

local function AttachColorLogic(previewBtn, colorFill, state, library, callback)
    local function Open()
        library:OpenColorPicker(state, previewBtn, function(c, t, r, s)
            state.Color = c
            state.Transparency = t
            state.Rainbow = r
            state.Speed = s
            colorFill.BackgroundColor3 = c
            colorFill.BackgroundTransparency = t
            Utility.pcallNotify(library, callback, c, t, r, s)
        end)
    end

    previewBtn.MouseButton1Click:Connect(Open)
    previewBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            Open()
            library.CP_Hex:CaptureFocus()
        end
    end)
end

local function AttachTooltip(parent, text, library)
    if not text then return end
    local theme = library.Theme
    local isLeftAligned = (parent:IsA("TextLabel") or parent:IsA("TextButton")) and (parent.TextXAlignment == Enum.TextXAlignment.Left)
    local xPos = UDim2.new(1, -20, 0.5, 0)
    
    if isLeftAligned then
        local bounds = TextService:GetTextSize(parent.Text, parent.TextSize, parent.Font, Vector2.new(1000, 20))
        xPos = UDim2.new(0, bounds.X + 8, 0.5, 0)
    end
    
    local HelpBtn = Utility.Create("TextButton", {
        Parent = parent,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 14, 0, 14),
        Position = xPos,
        AnchorPoint = Vector2.new(0, 0.5),
        Text = "?",
        TextColor3 = theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 10
    }, { TextColor3 = "TextDim" })
    
    HelpBtn.MouseEnter:Connect(function()
        library:ShowTooltip(text)
        TweenService:Create(HelpBtn, TI_02, { TextColor3 = theme.Accent }):Play()
    end)
    
    HelpBtn.MouseLeave:Connect(function()
        library:HideTooltip()
        TweenService:Create(HelpBtn, TI_02, { TextColor3 = theme.TextDim }):Play()
    end)
end

local function AttachBindTrigger(button, getBindFunc, callbackBegin, callbackEnd, library)
    local hook = {
        GetBind = getBindFunc,
        CallbackBegin = callbackBegin,
        CallbackEnd = callbackEnd
    }
    table.insert(library.BindHooks, hook)
    button.Destroying:Connect(function()
        for i, h in ipairs(library.BindHooks) do
            if h == hook then table.remove(library.BindHooks, i) break end
        end
    end)
end

local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

function Window:AddTab(name)
    local tab = setmetatable({
        Window = self,
        Name = name,
        Left = nil,
        Right = nil,
        Elements = {}
    }, Tab)

    tab.Button = Utility.Create("TextButton", {
        Name = Utility.RandomString(8),
        Parent = self.TabContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = self.Library.Theme.TextDim,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 3
    }, { TextColor3 = "TextDim" })
    Utility.Create("UIPadding", { Parent = tab.Button, PaddingLeft = UDim.new(0, 15), PaddingRight = UDim.new(0, 15) })

    tab.Indicator = Utility.Create("Frame", {
        Parent = tab.Button,
        BackgroundColor3 = self.Library.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        BackgroundTransparency = 1
    }, { BackgroundColor3 = "Accent" })
    
    tab.Page = Utility.Create("ScrollingFrame", {
        Name = Utility.RandomString(8),
        Parent = self.Content,
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        BorderSizePixel = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(1, 0, 0, 0),
        Size = UDim2.fromScale(1, 1),
        Visible = false
    })
    
    tab.Left = Utility.Create("Frame", {
        Name = "Left",
        Parent = tab.Page,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -15, 0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    tab.Right = Utility.Create("Frame", {
        Name = "Right",
        Parent = tab.Page,
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, -15, 0, 0),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    })

    for _, col in pairs({tab.Left, tab.Right}) do
        Utility.Create("UIListLayout", { Parent = col, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10) })
    end

    Utility.Create("UIPadding", {
        Parent = tab.Page,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10)
    })

    tab.Button.MouseButton1Click:Connect(function()
        tab:Activate()
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then
        tab:Activate()
    end

    return tab
end

function Tab:Activate()
    local window = self.Window
    local library = window.Library

    for _, t in ipairs(window.Tabs) do
        t.Page.Visible = false
        TweenService:Create(t.Button, TI_02, { TextColor3 = library.Theme.TextDim }):Play()
        if not Library.ThemeObjects[t.Button] then Library.ThemeObjects[t.Button] = {} end Library.ThemeObjects[t.Button]["TextColor3"] = "TextDim"
        TweenService:Create(t.Indicator, TI_02, { BackgroundTransparency = 1 }):Play()
    end
    self.Page.Visible = true
    TweenService:Create(self.Button, TI_02, { TextColor3 = library.Theme.Text }):Play()
    if not Library.ThemeObjects[self.Button] then Library.ThemeObjects[self.Button] = {} end Library.ThemeObjects[self.Button]["TextColor3"] = "Text"
    TweenService:Create(self.Indicator, TI_02, { BackgroundTransparency = 0 }):Play()
    library.ColorPickerWindow.Visible = false
    
    window.ActiveTab = self
end

function Tab:AddSection(name, side)
    side = side or "Left"
    local parent = (side == "Right" and self.Right) or self.Left
    
    local section = setmetatable({
        Window = self.Window,
        Page = self.Page,
        Container = nil,
        Root = nil -- [Feature] Expose Root for visibility toggling
    }, Section)

    local SectionFrame = Utility.Create("Frame", {
        Name = Utility.RandomString(8),
        Parent = parent,
        BackgroundColor3 = self.Window.Library.Theme.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y
    }, { BackgroundColor3 = "Card" })
    
    Utility.Create("UIStroke", {
        Parent = SectionFrame,
        Color = self.Window.Library.Theme.Outline,
        Thickness = 1
    }, { Color = "Outline" })
    Utility.Create("UICorner", { Parent = SectionFrame, CornerRadius = UDim.new(0, 4) })
    
    Utility.Create("Frame", {
        Parent = SectionFrame,
        BackgroundColor3 = self.Window.Library.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2),
        ZIndex = 2
    }, { BackgroundColor3 = "Accent" })
    
    Utility.Create("UIListLayout", {
        Parent = SectionFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0)
    })

    Utility.Create("TextLabel", {
        Parent = SectionFrame,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = "  " .. name,
        TextColor3 = self.Window.Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1
    }, { TextColor3 = "Text" })

    Utility.Create("Frame", {
        Parent = SectionFrame,
        BackgroundColor3 = self.Window.Library.Theme.Outline,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundTransparency = 0.5,
        LayoutOrder = 2
    }, { BackgroundColor3 = "Outline" })

    section.Container = Utility.Create("Frame", {
        Name = "Content",
        Parent = SectionFrame,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 3
    })
    
    Utility.Create("UIPadding", {
        Parent = section.Container,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })
    
    section.Root = SectionFrame
    local ListLayout = Utility.Create("UIListLayout", {
        Parent = section.Container,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    return section
end

function Section:AddLabel(text)
    local LabelFrame = Utility.Create("Frame", {
        Name = "Label",
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20)
    })

    Utility.Create("TextLabel", {
        Parent = LabelFrame,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = self.Window.Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, { TextColor3 = "Text" })
    return LabelFrame
end

function Section:AddButton(options)
    options = options or {}
    local name = options.Name or "Button"
    local callback = options.Callback or function() end
    local extra_bind = options.Keybind
    local bindID = Utility.RandomString(10)

    local ButtonFrame = Utility.Create("Frame", {
        Name = "Button",
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30)
    })
    Utility.AddRowHover(ButtonFrame, self.Window.Library.Theme)

    local Button = Utility.Create("TextButton", {
        Name = "MainBtn",
        Parent = ButtonFrame,
        BackgroundColor3 = self.Window.Library.Theme.Sidebar,
        Size = extra_bind and UDim2.new(1, -80, 1, 0) or UDim2.new(1, 0, 1, 0),
        Text = name,
        TextColor3 = self.Window.Library.Theme.Text,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        AutoButtonColor = false
    }, { BackgroundColor3 = "Sidebar", TextColor3 = "Text" })
    Utility.Create("UICorner", { Parent = Button, CornerRadius = UDim.new(0, 4) })
    
    
    local Stroke = Utility.Create("UIStroke", {
        Parent = Button,
        Color = self.Window.Library.Theme.Outline,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, { Color = "Outline" })

    Button.MouseEnter:Connect(function()
        Button.BackgroundColor3 = self.Window.Library.Theme.Outline
        Button.BackgroundTransparency = 0.2
        Stroke.Color = self.Window.Library.Theme.Accent
    end)

    Button.MouseLeave:Connect(function()
        Button.BackgroundColor3 = self.Window.Library.Theme.Sidebar
        Button.BackgroundTransparency = 0
        Stroke.Color = self.Window.Library.Theme.Outline
    end)
    
    Button.MouseButton1Down:Connect(function()
        TweenService:Create(Button, TI_01, { TextSize = 11 }):Play()
    end)
    
    Button.MouseButton1Up:Connect(function()
        TweenService:Create(Button, TI_01, { TextSize = 12 }):Play()
    end)

    Button.MouseButton1Click:Connect(function() Utility.pcallNotify(self.Window.Library, callback) end)
    
    AttachTooltip(Button, options.Description, self.Window.Library)

    if extra_bind then
        local currentBind = extra_bind.Default
        local bind_cb = extra_bind.Callback or function() end
        local bind_flag = extra_bind.Flag

        local BindBtn = Utility.Create("TextButton", {
            Name = "Keybind",
            Parent = ButtonFrame,
            Size = UDim2.new(0, 75, 1, 0),
            Position = UDim2.new(1, -75, 0, 0),
            BackgroundColor3 = self.Window.Library.Theme.Sidebar,
            Text = (not currentBind and "None") or (currentBind.Name == "MouseButton1" and "M1") or (currentBind.Name == "MouseButton2" and "M2") or (currentBind.Name == "MouseButton3" and "M3") or currentBind.Name,
            TextColor3 = self.Window.Library.Theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            AutoButtonColor = false
        }, { BackgroundColor3 = "Sidebar", TextColor3 = "TextDim" })
        Utility.Create("UICorner", { Parent = BindBtn, CornerRadius = UDim.new(0, 4) })
        Utility.Create("UIStroke", { Parent = BindBtn, Color = self.Window.Library.Theme.Outline, Thickness = 1 }, { Color = "Outline" })

        local GetBind = AttachBindLogic(BindBtn, currentBind, function(newBind)
            currentBind = newBind
            if bind_flag then self.Window.Library.Flags[bind_flag] = (newBind and newBind.Name) or nil end
            Utility.pcallNotify(self.Window.Library, bind_cb, newBind)
            self.Window.Library:UpdateKeybind(bindID, name, newBind, false) -- False because buttons don't have "Active" state
        end, self.Window.Library.Theme, self.Window.Library)

        AttachBindTrigger(BindBtn, GetBind, function() Utility.pcallNotify(self.Window.Library, callback) end, nil, self.Window.Library)
    end
    
    return ButtonFrame
end

function Section:AddToggle(options)
    options = options or {}
    local name = options.Name or "Toggle"
    local state = options.Default or false
    local callback = options.Callback or function() end
    local extra_color = options.Color
    local extra_color2 = options.Color2
    local extra_bind = options.Keybind
    local flag = options.Flag
    local currentBind = extra_bind and extra_bind.Default -- [Fix] Lift scope so SetState sees updates
    local mode_flag = extra_bind and extra_bind.ModeFlag
    local label_callback = options.CallbackLabel -- [Feature] Separate callback for clicking the text
    local bindID = Utility.RandomString(10)

    local ToggleFrame = Utility.Create("Frame", {
        Name = "Toggle",
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30)
    })

    Utility.AddRowHover(ToggleFrame, self.Window.Library.Theme)

    local Controls = Utility.Create("Frame", {
        Name = "Controls",
        Parent = ToggleFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -5, 0, 0),
        Size = UDim2.new(0, 0, 1, 0),
        AnchorPoint = Vector2.new(1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 2
    })
    
    Utility.Create("UIListLayout", {
        Parent = Controls,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })

    local Label = Utility.Create("TextButton", { -- [Feature] Changed to TextButton for interaction
        Parent = ToggleFrame,
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.Window.Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false
    }, { TextColor3 = "Text" })
    
    AttachTooltip(Label, options.Description, self.Window.Library)

    local SwitchContainer = Utility.Create("TextButton", {
        Name = "Switch",
        Parent = Controls,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 40, 0, 20),
        LayoutOrder = 3,
        Text = "",
        AutoButtonColor = false
    })

    local Switch = Utility.Create("Frame", {
        Parent = SwitchContainer,
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = state and self.Window.Library.Theme.Accent or self.Window.Library.Theme.Background
    }, { BackgroundColor3 = state and "Accent" or "Background" })
    Utility.Create("UIStroke", { Parent = Switch, Color = self.Window.Library.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    Utility.Create("UICorner", { Parent = Switch, CornerRadius = UDim.new(1, 0) })
    
    local Knob = Utility.Create("Frame", {
        Parent = Switch,
        Size = UDim2.new(0, 16, 0, 16),
        Position = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = state and self.Window.Library.Theme.Text or self.Window.Library.Theme.TextDim
    }, { BackgroundColor3 = state and "Text" or "TextDim" })
    Utility.Create("UICorner", { Parent = Knob, CornerRadius = UDim.new(1, 0) })

    local function SetState(newState, silent)
        state = newState
        local targetPos = state and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        local targetColor = state and self.Window.Library.Theme.Accent or self.Window.Library.Theme.Background
        local targetKnobColor = state and self.Window.Library.Theme.Text or self.Window.Library.Theme.TextDim
        
        TweenService:Create(Knob, TI_QuadOut, { Position = targetPos, BackgroundColor3 = targetKnobColor }):Play()
        TweenService:Create(Switch, TI_QuadOut, { BackgroundColor3 = targetColor }):Play()
        
        if not Library.ThemeObjects[Switch] then Library.ThemeObjects[Switch] = {} end
        Library.ThemeObjects[Switch]["BackgroundColor3"] = state and "Accent" or "Background"
        if not Library.ThemeObjects[Knob] then Library.ThemeObjects[Knob] = {} end
        Library.ThemeObjects[Knob]["BackgroundColor3"] = state and "Text" or "TextDim"
        
        if flag then self.Window.Library.Flags[flag] = state end
        if not silent then
            Utility.pcallNotify(self.Window.Library, callback, state)
        end
        self.Window.Library:UpdateKeybind(bindID, name, currentBind, state) -- [Fix] Use dynamic currentBind
    end

    SwitchContainer.MouseButton1Click:Connect(function()
        SetState(not state)
    end)

    if label_callback then
        Label.MouseButton1Click:Connect(function() Utility.pcallNotify(self.Window.Library, label_callback) end)
    end
    
    if flag then
        self.Window.Library.Flags[flag] = state
        self.Window.Library.ConfigRegistry[flag] = { Set = SetState, Type = "Toggle" }
    end

    local function AddColorButton(opts)
        if not opts then return end
        
        local color_default = opts.Default or Color3.fromRGB(255, 255, 255)
        local color_trans = opts.Transparency or 0.5
        local color_cb = opts.Callback or function() end
        local colorState = { 
            Color = color_default, 
            Transparency = color_trans, 
            Rainbow = false, 
            Speed = 1 
        }
        local color_flag = opts.Flag
        
        local ColorPreview = Utility.Create("TextButton", {
            Name = "Color",
            Parent = Controls,
            Size = UDim2.new(0, 30, 0, 15),
            BackgroundTransparency = 1,
            Text = "",
            ClipsDescendants = true,
            AutoButtonColor = false,
            LayoutOrder = 2
        })
        Utility.Create("UICorner", { Parent = ColorPreview, CornerRadius = UDim.new(0, 4) })
        Utility.Create("UIStroke", { Parent = ColorPreview, Color = self.Window.Library.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
        
        local Checker = Utility.Create("ImageLabel", {
            Parent = ColorPreview,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Image = "rbxassetid://3887014957",
            ScaleType = Enum.ScaleType.Tile,
            TileSize = UDim2.new(0, 10, 0, 10),
            ZIndex = 1
        })
        
        local ColorFill = Utility.Create("Frame", {
            Parent = ColorPreview,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = color_default,
            BackgroundTransparency = color_trans,
            BorderSizePixel = 0,
            ZIndex = 2
        })

        local function UpdateColor(c, t, r, s)
            colorState.Color = c
            colorState.Transparency = t
            colorState.Rainbow = r
            colorState.Speed = s
            ColorFill.BackgroundColor3 = c
            ColorFill.BackgroundTransparency = t
            if color_flag then
                self.Window.Library.Flags[color_flag] = { Color = Utility.ColorToTable(c), Transparency = t, Rainbow = r, Speed = s }
            end
            Utility.pcallNotify(self.Window.Library, color_cb, c, t, r, s)
        end

        AttachColorLogic(ColorPreview, ColorFill, colorState, self.Window.Library, UpdateColor)
        
        if color_flag then
            -- [Fix] Initialize flag immediately so it's not nil before interaction
            self.Window.Library.Flags[color_flag] = { Color = Utility.ColorToTable(color_default), Transparency = color_trans, Rainbow = false, Speed = 1 }
            self.Window.Library.ConfigRegistry[color_flag] = { Set = function(v) UpdateColor(Utility.TableToColor(v.Color), v.Transparency, v.Rainbow, v.Speed) end, Type = "Color" }
        end
    end

    AddColorButton(extra_color)
    AddColorButton(extra_color2)

    if extra_bind then
        local bind_cb = extra_bind.Callback or function() end
        local bind_flag = extra_bind.Flag
        
        local BindBtn = Utility.Create("TextButton", {
            Name = "Keybind",
            Parent = Controls,
            Size = UDim2.new(0, 0, 0, 18),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = self.Window.Library.Theme.Sidebar,
            Text = (not currentBind and "None") or (currentBind.Name == "MouseButton1" and "M1") or (currentBind.Name == "MouseButton2" and "M2") or (currentBind.Name == "MouseButton3" and "M3") or currentBind.Name,
            TextColor3 = self.Window.Library.Theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            AutoButtonColor = false,
            LayoutOrder = 1
        }, { BackgroundColor3 = "Sidebar", TextColor3 = "TextDim" })
        Utility.Create("UICorner", { Parent = BindBtn, CornerRadius = UDim.new(0, 4) })
        Utility.Create("UIStroke", { Parent = BindBtn, Color = self.Window.Library.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
        Utility.Create("UIPadding", { Parent = BindBtn, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) })

        local GetBind = AttachBindLogic(BindBtn, currentBind, function(newBind)
            currentBind = newBind
            if bind_flag then self.Window.Library.Flags[bind_flag] = (newBind and newBind.Name) or nil end
            Utility.pcallNotify(self.Window.Library, bind_cb, newBind)
            self.Window.Library:UpdateKeybind(bindID, name, newBind, state)
        end, self.Window.Library.Theme, self.Window.Library)

        AttachBindTrigger(BindBtn, GetBind, 
            function() -- Input Began
                local mode = "Toggle"
                if mode_flag and self.Window.Library.Flags[mode_flag] then
                    mode = self.Window.Library.Flags[mode_flag]
                end
                if mode == "Toggle" then
                    SetState(not state)
                elseif mode == "Hold" then
                    SetState(true)
                end
            end,
            function() -- Input Ended
                local mode = (mode_flag and self.Window.Library.Flags[mode_flag]) or "Toggle"
                if mode == "Hold" then
                    SetState(false)
                end
            end, 
        self.Window.Library)

        if currentBind then
            self.Window.Library:UpdateKeybind(bindID, name, currentBind, state)
            if bind_flag then self.Window.Library.Flags[bind_flag] = currentBind.Name end
        end
    end

    return ToggleFrame
end

function Section:AddSlider(options)
    options = options or {}
    local name = options.Name or "Slider"
    local min = options.Min or 0
    local max = options.Max or 100
    local default = options.Default or min
    local decimals = options.Decimals or 0
    local callback = options.Callback or function() end
    local flag = options.Flag
    local currentValue = default

    local SliderFrame = Utility.Create("Frame", {
        Name = "Slider",
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 45)
    })
    Utility.AddRowHover(SliderFrame, self.Window.Library.Theme)

    local Label = Utility.Create("TextLabel", {
        Parent = SliderFrame,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.Window.Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, { TextColor3 = "Text" })
    
    AttachTooltip(Label, options.Description, self.Window.Library)

    local ValueLabel = Utility.Create("TextBox", {
        Parent = SliderFrame,
        Size = UDim2.new(0, 50, 0, 20),
        Position = UDim2.new(1, -55, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(default),
        TextColor3 = self.Window.Library.Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Right,
        ClearTextOnFocus = false
    }, { TextColor3 = "TextDim" })

    local Track = Utility.Create("TextButton", {
        Parent = SliderFrame,
        Size = UDim2.new(1, -10, 0, 6),
        Position = UDim2.new(0, 5, 0, 30),
        BackgroundColor3 = self.Window.Library.Theme.Sidebar,
        Text = "",
        AutoButtonColor = false
    }, { BackgroundColor3 = "Sidebar" })
    Utility.Create("UIStroke", { Parent = Track, Color = self.Window.Library.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    Utility.Create("UICorner", { Parent = Track, CornerRadius = UDim.new(1, 0) })

    local Fill = Utility.Create("Frame", {
        Parent = Track,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        BackgroundColor3 = self.Window.Library.Theme.Accent,
        BorderSizePixel = 0
    }, { BackgroundColor3 = "Accent" })
    Utility.Create("UICorner", { Parent = Fill, CornerRadius = UDim.new(1, 0) })

    local dragging = false

    local function SetValue(v, silent)
        local n = math.clamp(v, min, max)
        n = math.floor(n * (10 ^ decimals)) / (10 ^ decimals)
        currentValue = n
        ValueLabel.Text = tostring(n)
        Fill.Size = UDim2.new((n - min) / (max - min), 0, 1, 0)
        if flag then self.Window.Library.Flags[flag] = n end
        if not silent then
            Utility.pcallNotify(self.Window.Library, callback, n)
        end
    end
    
    local function Update(input)
        local SizeX = Track.AbsoluteSize.X
        local PositionX = Track.AbsolutePosition.X
        local Percent = math.clamp((input.Position.X - PositionX) / SizeX, 0, 1)
        local Value = min + (max - min) * Percent
        SetValue(Value)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            self.Window.Library.DraggingSlider = Update
            Update(input)
        end
    end)

    SliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            ValueLabel:CaptureFocus()
        end
    end)

    ValueLabel.FocusLost:Connect(function()
        local n = tonumber(ValueLabel.Text)
        if n then
            SetValue(n)
        else
            SetValue(currentValue)
        end
    end)

    if flag then
        self.Window.Library.Flags[flag] = default
        self.Window.Library.ConfigRegistry[flag] = { Set = SetValue, Type = "Slider" }
    end

    return SliderFrame
end

function Section:AddInput(options)
    options = options or {}
    local name = options.Name or "Input"
    local default = options.Default or ""
    local placeholder = options.Placeholder or "..."
    local callback = options.Callback or function() end
    local flag = options.Flag
    
    local InputFrame = Utility.Create("Frame", {
        Name = "Input",
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 45)
    })
    Utility.AddRowHover(InputFrame, self.Window.Library.Theme)

    local Label = Utility.Create("TextLabel", {
        Parent = InputFrame,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.Window.Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, { TextColor3 = "Text" })
    
    AttachTooltip(Label, options.Description, self.Window.Library)

    local InputBox = Utility.Create("TextBox", {
        Parent = InputFrame,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 22),
        BackgroundColor3 = self.Window.Library.Theme.Sidebar,
        Text = default,
        PlaceholderText = placeholder,
        TextColor3 = self.Window.Library.Theme.Text,
        PlaceholderColor3 = self.Window.Library.Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false
    }, { BackgroundColor3 = "Sidebar", TextColor3 = "Text", PlaceholderColor3 = "TextDim" })
    
    Utility.Create("UICorner", { Parent = InputBox, CornerRadius = UDim.new(0, 4) })
    Utility.Create("UIStroke", { Parent = InputBox, Color = self.Window.Library.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    
    local function Update(text, silent)
        if flag then self.Window.Library.Flags[flag] = text end
        if not silent then
            Utility.pcallNotify(self.Window.Library, callback, text)
        end
    end

    InputBox.FocusLost:Connect(function()
        Update(InputBox.Text)
    end)
    
    if flag then
        self.Window.Library.Flags[flag] = default
        self.Window.Library.ConfigRegistry[flag] = {
            Set = function(val, silent)
                InputBox.Text = tostring(val)
                Update(tostring(val), silent)
            end,
            Type = "Input"
        }
    end
    
    return InputFrame
end

function Section:AddDropdown(options)
    options = options or {}
    local name = options.Name or "Dropdown"
    local items = options.Items or {}
    local multi = options.Multi or false
    local default = options.Default
    if default == nil and multi then default = {} end
    local flag = options.Flag
    local callback = options.Callback or function() end

    local state = {
        single = nil,
        multi = {}
    }

    if multi then
        for _, item in pairs(items) do state.multi[item] = false end
        if type(default) == "table" then
            for _, v in pairs(default) do state.multi[v] = true end
        end
    else
        state.single = default
    end

    local DropdownFrame = Utility.Create("Frame", {
        Name = "Dropdown",
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 50),
        ClipsDescendants = true
    })
    Utility.AddRowHover(DropdownFrame, self.Window.Library.Theme)

    local Label = Utility.Create("TextLabel", {
        Parent = DropdownFrame,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.Window.Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, { TextColor3 = "Text" })
    
    AttachTooltip(Label, options.Description, self.Window.Library)

    local Header = Utility.Create("TextButton", {
        Parent = DropdownFrame,
        Size = UDim2.new(1, -10, 0, 25),
        Position = UDim2.new(0, 5, 0, 22),
        BackgroundColor3 = self.Window.Library.Theme.Sidebar,
        Text = "  ...",
        TextColor3 = self.Window.Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false
    }, { BackgroundColor3 = "Sidebar", TextColor3 = "Text" })
    Utility.Create("UICorner", { Parent = Header, CornerRadius = UDim.new(0, 4) })
    local Stroke = Utility.Create("UIStroke", { Parent = Header, Color = self.Window.Library.Theme.Outline, Thickness = 1 }, { Color = "Outline" })

    local Arrow = Utility.Create("ImageLabel", {
        Parent = Header,
        Size = UDim2.new(0, 15, 0, 15),
        Position = UDim2.new(1, -20, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031091004", -- Arrow Icon
        ImageColor3 = self.Window.Library.Theme.TextDim,
        Rotation = 0
    }, { ImageColor3 = "TextDim" })

    Header.MouseEnter:Connect(function()
        Header.BackgroundColor3 = self.Window.Library.Theme.Outline
        Stroke.Color = self.Window.Library.Theme.Accent
    end)
    Header.MouseLeave:Connect(function()
        Header.BackgroundColor3 = self.Window.Library.Theme.Sidebar
        Stroke.Color = self.Window.Library.Theme.Outline
    end)

    local ListContainer = Utility.Create("Frame", {
        Parent = DropdownFrame,
        Size = UDim2.new(1, -10, 0, 0),
        Position = UDim2.new(0, 5, 0, 50),
        BackgroundColor3 = self.Window.Library.Theme.Sidebar,
        BorderSizePixel = 0,
        Visible = false
    }, { BackgroundColor3 = "Sidebar" })
    Utility.Create("UICorner", { Parent = ListContainer, CornerRadius = UDim.new(0, 4) })
    
    local ListLayout = Utility.Create("UIListLayout", {
        Parent = ListContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2)
    })
    Utility.Create("UIPadding", { Parent = ListContainer, PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4) })

    local function UpdateText()
        if multi then
            local active = {}
            for k, v in pairs(state.multi) do
                if v then table.insert(active, k) end
            end
            
            if #active == 0 then
                Header.Text = "  None"
            elseif #active == #items then
                Header.Text = "  All"
            else
                Header.Text = "  " .. table.concat(active, ", ")
            end
        else
            Header.Text = "  " .. tostring(state.single or "None")
        end
    end
    UpdateText() -- Initial set

    local isOpen = false

    local function Toggle()
        isOpen = not isOpen
        ListContainer.Visible = isOpen
        
        TweenService:Create(Arrow, TI_02, { Rotation = isOpen and 180 or 0 }):Play()
        
        if isOpen then
            local count = #items
            local height = (count * 26) + 6
            ListContainer.Size = UDim2.new(1, -10, 0, height)
            DropdownFrame.Size = UDim2.new(1, 0, 0, 50 + height + 5)
        else
            DropdownFrame.Size = UDim2.new(1, 0, 0, 50)
        end
    end

    Header.MouseButton1Click:Connect(Toggle)

    local function RebuildItems()
        for _, child in pairs(ListContainer:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for i, item in ipairs(items) do
            local isSelected = false
            if multi then isSelected = state.multi[item] else isSelected = (state.single == item) end

            local ItemBtn = Utility.Create("TextButton", {
                Parent = ListContainer,
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                BackgroundColor3 = self.Window.Library.Theme.Accent, -- Used for hover
                Text = item,
                TextColor3 = isSelected and self.Window.Library.Theme.Accent or self.Window.Library.Theme.TextDim,
                TextSize = 12,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false
            }, { BackgroundColor3 = "Accent", TextColor3 = isSelected and "Accent" or "TextDim" })
            Utility.Create("UIPadding", { Parent = ItemBtn, PaddingLeft = UDim.new(0, 8) })
            Utility.Create("UICorner", { Parent = ItemBtn, CornerRadius = UDim.new(0, 4) })
            if i < #items then
                Utility.Create("Frame", {
                    Parent = ItemBtn,
                    BackgroundColor3 = self.Window.Library.Theme.Outline,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -10, 0, 1),
                    Position = UDim2.new(0, 5, 1, -1),
                    BackgroundTransparency = 0.7
                }, { BackgroundColor3 = "Outline" })
            end
            
            ItemBtn.MouseButton1Click:Connect(function()
                if multi then
                    state.multi[item] = not state.multi[item]
                    ItemBtn.TextColor3 = state.multi[item] and self.Window.Library.Theme.Accent or self.Window.Library.Theme.TextDim
                    UpdateText()
                    if not Library.ThemeObjects[ItemBtn] then Library.ThemeObjects[ItemBtn] = {} end
                    Library.ThemeObjects[ItemBtn]["TextColor3"] = state.multi[item] and "Accent" or "TextDim"
                    if flag then self.Window.Library.Flags[flag] = state.multi end
                    Utility.pcallNotify(self.Window.Library, callback, state.multi)
                else
                    state.single = item
                    for _, btn in pairs(ListContainer:GetChildren()) do
                        if btn:IsA("TextButton") then
                            btn.TextColor3 = (btn.Text == item) and self.Window.Library.Theme.Accent or self.Window.Library.Theme.TextDim
                            if not Library.ThemeObjects[btn] then Library.ThemeObjects[btn] = {} end
                            Library.ThemeObjects[btn]["TextColor3"] = (btn.Text == item) and "Accent" or "TextDim"
                        end
                    end
                    UpdateText()
                    Toggle()
                    if flag then self.Window.Library.Flags[flag] = state.single end
                    Utility.pcallNotify(self.Window.Library, callback, item)
                end
            end)

            ItemBtn.MouseEnter:Connect(function()
                TweenService:Create(ItemBtn, TI_01, { BackgroundTransparency = 0.85 }):Play()
                if (multi and state.multi[item]) or (not multi and state.single == item) then return end
                TweenService:Create(ItemBtn, TI_01, { TextColor3 = self.Window.Library.Theme.Text }):Play()
            end)
            ItemBtn.MouseLeave:Connect(function()
                TweenService:Create(ItemBtn, TI_01, { BackgroundTransparency = 1 }):Play()
                if (multi and state.multi[item]) or (not multi and state.single == item) then return end
                TweenService:Create(ItemBtn, TI_01, { TextColor3 = self.Window.Library.Theme.TextDim }):Play()
            end)
        end
        
        if isOpen then
            local count = #items
            local height = (count * 26) + 6
            ListContainer.Size = UDim2.new(1, -10, 0, height)
            DropdownFrame.Size = UDim2.new(1, 0, 0, 50 + height + 5)
        end
    end

    RebuildItems()

    local DropdownController = { Root = DropdownFrame }

    function DropdownController:Refresh(newItems)
        items = newItems or {}
        if multi then
            state.multi = {}
            for _, item in pairs(items) do state.multi[item] = false end
        else
            state.single = default -- Reset to default or nil? Keeping default for safety
        end
        UpdateText()
        RebuildItems()
    end

    if flag then
        self.Window.Library.Flags[flag] = multi and state.multi or state.single
        self.Window.Library.ConfigRegistry[flag] = { 
            Set = function(val, silent) 
                if multi then
                    state.multi = val
                else
                    state.single = val
                end
                UpdateText()
            end, 
            Type = "Dropdown" 
        }
    end

    return DropdownController
end

function Section:AddKeybind(options)
    options = options or {}
    local name = options.Name or "Keybind"
    local currentBind = options.Default
    local flag = options.Flag
    local callback = options.Callback or function() end
    local bindID = Utility.RandomString(10)

    local KeybindFrame = Utility.Create("Frame", {
        Name = "Keybind",
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30)
    })
    Utility.AddRowHover(KeybindFrame, self.Window.Library.Theme)

    local Label = Utility.Create("TextLabel", {
        Parent = KeybindFrame,
        Size = UDim2.new(1, -80, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.Window.Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, { TextColor3 = "Text" })
    
    AttachTooltip(Label, options.Description, self.Window.Library)

    local BindBtn = Utility.Create("TextButton", {
        Parent = KeybindFrame,
        Size = UDim2.new(0, 70, 0, 20),
        Position = UDim2.new(1, -75, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = self.Window.Library.Theme.Sidebar,
        Text = (not currentBind and "None") or (currentBind.Name == "MouseButton1" and "M1") or (currentBind.Name == "MouseButton2" and "M2") or (currentBind.Name == "MouseButton3" and "M3") or currentBind.Name,
        TextColor3 = self.Window.Library.Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false
    }, { BackgroundColor3 = "Sidebar", TextColor3 = "TextDim" })
    Utility.Create("UICorner", { Parent = BindBtn, CornerRadius = UDim.new(0, 4) })
    Utility.Create("UIStroke", { Parent = BindBtn, Color = self.Window.Library.Theme.Outline, Thickness = 1 }, { Color = "Outline" })

    local GetBind = AttachBindLogic(BindBtn, currentBind, function(newBind)
        currentBind = newBind
        if flag then self.Window.Library.Flags[flag] = (newBind and newBind.Name) or nil end
        Utility.pcallNotify(self.Window.Library, callback, newBind)
        self.Window.Library:UpdateKeybind(bindID, name, newBind, true)
    end, self.Window.Library.Theme, self.Window.Library)
    
    AttachBindTrigger(BindBtn, GetBind, callback, nil, self.Window.Library)
    
    if currentBind then
        self.Window.Library:UpdateKeybind(bindID, name, currentBind, true)
    end
    
    if flag then
        self.Window.Library.Flags[flag] = (currentBind and currentBind.Name) or nil
        self.Window.Library.ConfigRegistry[flag] = { 
            Set = function(val, silent) 
                local key
                pcall(function() key = Enum.KeyCode[val] end)
                if not key then pcall(function() key = Enum.UserInputType[val] end) end
                GetBind(key) -- This needs to update the internal state of AttachBindLogic, which is tricky with closures.
            end, 
            Type = "Keybind" 
        }
    end

    return KeybindFrame
end

function Section:AddColorPicker(options)
    options = options or {}
    local name = options.Name or "Color"
    local default = options.Default or Color3.fromRGB(255, 255, 255)
    local transparency = options.Transparency or 0.5
    local flag = options.Flag
    local callback = options.Callback or function() end

    local colorState = { 
        Color = default, 
        Transparency = transparency, 
        Rainbow = false, 
        Speed = 1 
    }

    local PickerFrame = Utility.Create("Frame", {
        Name = "ColorPicker",
        Parent = self.Container,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 30)
    })
    Utility.AddRowHover(PickerFrame, self.Window.Library.Theme)

    Utility.Create("TextLabel", {
        Parent = PickerFrame,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.Window.Library.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, { TextColor3 = "Text" })
    
    AttachTooltip(Label, options.Description, self.Window.Library)

    local Preview = Utility.Create("TextButton", {
        Name = "Preview",
        Parent = PickerFrame,
        Position = UDim2.new(1, -35, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 30, 0, 15),
        BackgroundTransparency = 1,
        Text = "",
        ClipsDescendants = true,
        AutoButtonColor = false
    })
    Utility.Create("UICorner", { Parent = Preview, CornerRadius = UDim.new(0, 4) })
    
    local Checker = Utility.Create("ImageLabel", {
        Parent = Preview,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Image = "rbxassetid://3887014957",
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.new(0, 10, 0, 10),
        ZIndex = 1
    })
    
    local ColorFill = Utility.Create("Frame", {
        Parent = Preview,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = default,
        BackgroundTransparency = transparency,
        BorderSizePixel = 0,
        ZIndex = 2
    })

    Utility.Create("UIStroke", {
        Parent = Preview,
        Color = self.Window.Library.Theme.Outline,
        Thickness = 1
    }, { Color = "Outline" })

    local function UpdateColor(c, t, r, s, silent)
        colorState.Color = c or colorState.Color
        colorState.Transparency = t or 0
        if r ~= nil then colorState.Rainbow = r end
        colorState.Speed = s or 1
        ColorFill.BackgroundColor3 = c
        ColorFill.BackgroundTransparency = t
        if flag then
            self.Window.Library.Flags[flag] = { Color = Utility.ColorToTable(c), Transparency = t, Rainbow = r, Speed = s }
        end
        if not silent then
            Utility.pcallNotify(self.Window.Library, callback, c, t, r, s)
        end
    end

    AttachColorLogic(Preview, ColorFill, colorState, self.Window.Library, UpdateColor)

    if flag then
        -- [Fix] Initialize flag immediately
        self.Window.Library.Flags[flag] = { Color = Utility.ColorToTable(default), Transparency = transparency, Rainbow = false, Speed = 1 }
        self.Window.Library.ConfigRegistry[flag] = { Set = function(v, silent) UpdateColor(Utility.TableToColor(v.Color), v.Transparency, v.Rainbow, v.Speed, silent) end, Type = "Color" }
    end

    return PickerFrame
end

function Section:AddThemeManager()
    local library = self.Window.Library
    local themes = {}
    for name, _ in pairs(library.Themes) do
        table.insert(themes, name)
    end
    table.sort(themes)

    self:AddDropdown({
        Name = "Theme",
        Items = themes,
        Default = "Default",
        Callback = function(v)
            library:SetTheme(v)
            -- Update color pickers to match the new theme
            for key, _ in pairs(library.Theme) do
                local flag = "ThemeManager_" .. key
                if library.ConfigRegistry[flag] then
                    library.ConfigRegistry[flag].Set({
                        Color = library.Theme[key],
                        Transparency = 0,
                        Rainbow = false,
                        Speed = 1
                    })
                end
            end
        end
    })

    local order = {"Accent", "Background", "Card", "Sidebar", "Text", "TextDim", "Outline"}
    for _, key in ipairs(order) do
        self:AddColorPicker({
            Name = key,
            Default = library.Theme[key],
            Flag = "ThemeManager_" .. key,
            Callback = function(c) library:SetThemeColor(key, c) end
        })
    end
end

function Library.new(options)
    local self = setmetatable({}, Library)
    
    options = options or {}
    self.Name = options.Name or "Library"
    self.ID = options.ID
    self.Keys = options.Keys
    self.ConfigFolder = options.ConfigFolder or "GeminiHub"
    
    if not self.ID then
        error("[Library] ID is required in Library.new({ ID = '...' })")
    end
    
    if GlobalEnv[self.ID] then
        if GlobalEnv[self.ID].Destroy then
            GlobalEnv[self.ID]:Destroy()
        end
        GlobalEnv[self.ID] = nil
    end
    
    self.Themes = {
        Default = {
            Accent = Color3.fromRGB(65, 140, 255),
            Background = Color3.fromRGB(15, 15, 15),
            Card = Color3.fromRGB(24, 24, 24),
            Sidebar = Color3.fromRGB(32, 32, 32),
            Text = Color3.fromRGB(240, 240, 240),
            TextDim = Color3.fromRGB(120, 120, 120),
            Outline = Color3.fromRGB(50, 50, 50)
        },
        Midnight = {
            Accent = Color3.fromRGB(115, 80, 255),
            Background = Color3.fromRGB(15, 15, 25),
            Card = Color3.fromRGB(25, 25, 35),
            Sidebar = Color3.fromRGB(30, 30, 45),
            Text = Color3.fromRGB(240, 240, 255),
            TextDim = Color3.fromRGB(120, 120, 150),
            Outline = Color3.fromRGB(50, 50, 80)
        },
        Rust = {
            Accent = Color3.fromRGB(255, 85, 65),
            Background = Color3.fromRGB(20, 15, 15),
            Card = Color3.fromRGB(30, 20, 20),
            Sidebar = Color3.fromRGB(40, 25, 25),
            Text = Color3.fromRGB(255, 240, 240),
            TextDim = Color3.fromRGB(150, 120, 120),
            Outline = Color3.fromRGB(80, 50, 50)
        },
        Nature = {
            Accent = Color3.fromRGB(100, 200, 100),
            Background = Color3.fromRGB(15, 20, 15),
            Card = Color3.fromRGB(20, 30, 20),
            Sidebar = Color3.fromRGB(25, 35, 25),
            Text = Color3.fromRGB(240, 255, 240),
            TextDim = Color3.fromRGB(120, 150, 120),
            Outline = Color3.fromRGB(50, 70, 50)
        }
    }
    
    self.Theme = {}
    local source = self.Themes.Default
    if options.Theme then
        if type(options.Theme) == "string" and self.Themes[options.Theme] then
            source = self.Themes[options.Theme]
        elseif type(options.Theme) == "table" then
            source = options.Theme
        end
    end
    
    for k, v in pairs(source) do
        self.Theme[k] = v
    end
    
    -- The ScreenGui (Root)
    self.Gui = Instance.new("ScreenGui")
    self.Gui.Name = Utility.RandomString(15)
    self.Gui.IgnoreGuiInset = true
    self.Gui.ResetOnSpawn = false
    self.Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if syn and syn.protect_gui then
        syn.protect_gui(self.Gui)
    end
    self.Gui.Parent = Utility.GetSafeContainer()
    
    self.Janitor = Janitor.new()
    GlobalEnv[self.ID] = self
    self.Keybinds = {} -- Reset registry
    self.Rainbows = {}
    self.Flags = {}
    self.BindHooks = {}
    self.ConfigRegistry = {}
    self.NotificationsEnabled = false
    self.CustomWindows = {}
    self.NotificationTransparency = 0.1
    self.NotificationAnchorTransparency = 0.5
    self.KeybindTransparency = 0
    self.InfoTransparency = 0
    self.WatermarkTransparency = 0
    self.MainTransparency = 0
    self.RainbowConnection = nil
    self._dead = false
    self.Utility = Utility

    -- Centralized Input Handling
    self.Janitor:Add(UserInputService.InputBegan:Connect(function(input, gameProcessed)
        for _, hook in ipairs(self.BindHooks) do
            local bind = hook.GetBind()
            if bind then
                local isKeyboard = (input.UserInputType == Enum.UserInputType.Keyboard)
                local safeToPress = (isKeyboard and not UserInputService:GetFocusedTextBox()) or (not isKeyboard and not gameProcessed)
                if safeToPress then
                    if input.KeyCode == bind or input.UserInputType == bind then
                        Utility.pcallNotify(self, hook.CallbackBegin, bind)
                    end
                end
            end
        end
    end))

    self.Janitor:Add(UserInputService.InputChanged:Connect(function(input)
        if self.DraggingFrame and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - self.DraggingFrame.DragStart
            local startPos = self.DraggingFrame.StartPos
            self.DraggingFrame.Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        elseif self.DraggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            self.DraggingSlider(input)
        elseif self.DraggingColor and input.UserInputType == Enum.UserInputType.MouseMovement then
            self.DraggingColor.Update(input)
        end
    end))

    self.Janitor:Add(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.DraggingFrame = nil
            self.DraggingSlider = nil
            self.DraggingColor = nil
        end
        
        -- Handle Bind Releases
        for _, hook in ipairs(self.BindHooks) do
            local bind = hook.GetBind()
            if bind and (input.KeyCode == bind or input.UserInputType == bind) then
                Utility.pcallNotify(self, hook.CallbackEnd, bind)
            end
        end
    end))
    
    return self
end

function Library:CreateWatermark()
    local Watermark = Utility.Create("Frame", {
        Name = "Watermark",
        Parent = self.Gui,
        BackgroundColor3 = self.Theme.Card,
        BackgroundTransparency = self.WatermarkTransparency,
        Size = UDim2.fromOffset(200, 24),
        Position = UDim2.new(0, 20, 0, 20), -- Top left
        ZIndex = 200,
        Visible = false
    }, { BackgroundColor3 = "Card" })
    
    Utility.Create("UICorner", { Parent = Watermark, CornerRadius = UDim.new(0, 4) })
    Utility.Create("UIStroke", { Parent = Watermark, Color = self.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    Utility.Drag(Watermark, nil, self)
    
    -- Accent Line
    Utility.Create("Frame", {
        Parent = Watermark,
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1)
    }, { BackgroundColor3 = "Accent" })
    
    local Label = Utility.Create("TextLabel", {
        Parent = Watermark,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = self.Name .. " | Made by FZ | FPS: 0 | Ping: 0ms",
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold
    }, { TextColor3 = "Text" })
    
    local active = true
    self.Janitor:Add(function() active = false end)

    local function UpdateWatermark()
        task.spawn(function()
            while not self._dead and active and Watermark.Visible and Watermark.Parent do
                local fps = math.floor(workspace:GetRealPhysicsFPS())
                local ping = 0
                pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
                local time = os.date("%H:%M:%S")
                
                Label.Text = string.format("%s | Made by FZ | FPS: %d | Ping: %dms | %s", self.Name, fps, ping, time)
                Watermark.Size = UDim2.fromOffset(TextService:GetTextSize(Label.Text, 12, Enum.Font.GothamBold, Vector2.new(1000, 24)).X + 20, 24)
                
                task.wait(1)
            end
        end)
    end

    Watermark:GetPropertyChangedSignal("Visible"):Connect(function()
        if Watermark.Visible then UpdateWatermark() end
    end)
    
    if Watermark.Visible then UpdateWatermark() end
    
    self.Watermark = Watermark
end

function Library:CreateCustomWindow(options)
    options = options or {}
    local name = options.Name or "CustomWindow"
    local size = options.Size or UDim2.fromOffset(200, 200)
    local position = options.Position or UDim2.fromScale(0.5, 0.5)
    local title = options.Title
    local draggable = options.Draggable
    local titleAlignment = options.TitleAlignment or Enum.TextXAlignment.Left
    if draggable == nil then draggable = true end

    local WindowFrame = Utility.Create("Frame", {
        Name = name,
        Parent = self.Gui,
        BackgroundColor3 = self.Theme.Card,
        Size = size,
        Position = position,
        ZIndex = 50,
        Visible = false
    }, { BackgroundColor3 = "Card" })

    Utility.Create("UICorner", { Parent = WindowFrame, CornerRadius = UDim.new(0, 4) })
    Utility.Create("UIStroke", { Parent = WindowFrame, Color = self.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    
    if draggable then
        Utility.Drag(WindowFrame, nil, self)
    end
    
    -- Accent Line
    Utility.Create("Frame", {
        Parent = WindowFrame,
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2)
    }, { BackgroundColor3 = "Accent" })

    local Content = WindowFrame

    if title then
        local labelPos = UDim2.new(0, 10, 0, 0)
        local labelSize = UDim2.new(1, -10, 0, 25)
        
        if titleAlignment == Enum.TextXAlignment.Center then
            labelPos = UDim2.new(0, 0, 0, 0)
            labelSize = UDim2.new(1, 0, 0, 25)
        end

        Utility.Create("TextLabel", {
            Parent = WindowFrame,
            Size = labelSize,
            Position = labelPos,
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = self.Theme.Text,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextXAlignment = titleAlignment
        }, { TextColor3 = "Text" })

        Content = Utility.Create("Frame", {
            Name = "Content",
            Parent = WindowFrame,
            Size = UDim2.new(1, 0, 1, -25),
            Position = UDim2.new(0, 0, 0, 25),
            BackgroundTransparency = 1
        })
    end

    self.CustomWindows[name] = WindowFrame
    WindowFrame.Destroying:Connect(function()
        self.CustomWindows[name] = nil
    end)

    return {
        Root = WindowFrame,
        Content = Content,
        Destroy = function() WindowFrame:Destroy() end
    }
end

function Library:CreateKeybindList()
    local KeybindFrame = Utility.Create("Frame", {
        Name = "KeybindList",
        Parent = self.Gui,
        BackgroundColor3 = self.Theme.Card,
        BackgroundTransparency = self.KeybindTransparency,
        Size = UDim2.new(0, 200, 0, 30),
        Position = UDim2.new(0, 10, 0.5, 0),
        Visible = false,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 50
    }, { BackgroundColor3 = "Card" })
    Utility.Create("UICorner", { Parent = KeybindFrame, CornerRadius = UDim.new(0, 4) })
    Utility.Create("UIStroke", { Parent = KeybindFrame, Color = self.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    Utility.Drag(KeybindFrame, nil, self)
    
    Utility.Create("UIGradient", {
        Parent = KeybindFrame,
        Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0.85,0.85,0.85)),
        Rotation = 45
    })
    
    Utility.Create("Frame", {
        Parent = KeybindFrame,
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2)
    }, { BackgroundColor3 = "Accent" })

    Utility.Create("TextLabel", {
        Parent = KeybindFrame,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = "Keybinds",
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold
    }, { TextColor3 = "Text" })

    self.KeybindContainer = Utility.Create("Frame", {
        Parent = KeybindFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 25),
        AutomaticSize = Enum.AutomaticSize.Y
    })
    
    Utility.Create("UIListLayout", {
        Parent = self.KeybindContainer,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    
    self.KeybindFrame = KeybindFrame
end

function Library:CreateWindow(options)
    options = options or {}
    local Title = options.Title or "Library"
    
    local RootFrame = Utility.Create("CanvasGroup", {
        Name = Utility.RandomString(10),
        Parent = self.Gui,
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(630, 580),
        Active = true,
        GroupTransparency = 1,
        Visible = false
    })

    local Shadow = Utility.Create("ImageLabel", {
        Name = "Shadow",
        Parent = RootFrame,
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        Position = UDim2.fromScale(0, 0),
        Size = UDim2.fromScale(1, 1),
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0
    })

    local MainFrame = Utility.Create("Frame", {
        Name = "Main",
        Parent = RootFrame,
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = self.MainTransparency,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -30, 1, -30),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 1
    }, { BackgroundColor3 = "Background" })

    Utility.Create("UICorner", { Parent = MainFrame, CornerRadius = UDim.new(0, 6) })
    
    local BorderFrame = Utility.Create("Frame", {
        Name = "Border",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        ZIndex = 10
    })
    Utility.Create("UICorner", { Parent = BorderFrame, CornerRadius = UDim.new(0, 6) })
    
    local Stroke = Utility.Create("UIStroke", {
        Parent = BorderFrame,
        Color = self.Theme.Accent,
        Thickness = 1
    }, { Color = "Accent" })

    local Header = Utility.Create("Frame", {
        Name = "Header",
        Parent = MainFrame,
        BackgroundColor3 = self.Theme.Card,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50),
        ZIndex = 2
    }, { BackgroundColor3 = "Card" })
    
    Utility.Create("TextLabel", {
        Parent = Header,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 5),
        BackgroundTransparency = 1,
        Text = Title,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Center
    }, { TextColor3 = "Text" })

    local TabContainer = Utility.Create("ScrollingFrame", {
        Name = "Tabs",
        Parent = Header,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 1, -25),
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 2
    })
    
    Utility.Create("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5)
    })

    Utility.Create("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = self.Theme.Outline,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 50),
        ZIndex = 3
    }, { BackgroundColor3 = "Outline" })

    local Content = Utility.Create("Frame", {
        Name = Utility.RandomString(10),
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 60),
        Size = UDim2.new(1, -20, 1, -70),
        ZIndex = 2
    })

    self.NotificationHolder = Utility.Create("Frame", {
        Name = "Notifications",
        Parent = self.Gui,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 250, 0, 20),
        Position = UDim2.new(1, -260, 0, 10),
        ZIndex = 10000,
        AutomaticSize = Enum.AutomaticSize.Y,
        Active = true
    })
    Utility.Create("UICorner", { Parent = self.NotificationHolder, CornerRadius = UDim.new(0, 4) })
    self.NotificationHolderTitle = Utility.Create("TextLabel", {
        Parent = self.NotificationHolder,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "Notifications (Drag)",
        TextColor3 = self.Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        Visible = false
    }, { TextColor3 = "TextDim" })
    Utility.Drag(self.NotificationHolder, nil, self)
    
    Utility.Create("UIListLayout", {
        Parent = self.NotificationHolder,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })

    self:CreateColorPickerWindow()
    
    Utility.Drag(RootFrame, nil, self)

    local window = setmetatable({
        Library = self,
        Root = RootFrame,
        MainFrame = MainFrame,
        TabContainer = TabContainer,
        Content = Content,
        Tabs = {},
        ActiveTab = nil
    }, Window)
    self.MainWindow = window
    
    return window
end

function Library:CreateInfoWindow()
    local InfoFrame = Utility.Create("Frame", {
        Name = "InfoWindow",
        Parent = self.Gui,
        BackgroundColor3 = self.Theme.Card,
        BackgroundTransparency = self.InfoTransparency,
        Size = UDim2.new(0, 200, 0, 80),
        Position = UDim2.new(0, 10, 0, 10),
        ZIndex = 50,
        Visible = false
    }, { BackgroundColor3 = "Card" })
    Utility.Create("UICorner", { Parent = InfoFrame, CornerRadius = UDim.new(0, 4) })
    Utility.Create("UIStroke", { Parent = InfoFrame, Color = self.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    Utility.Drag(InfoFrame, nil, self)
    self.InfoWindow = InfoFrame

    Utility.Create("UIGradient", {
        Parent = InfoFrame,
        Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0.85,0.85,0.85)),
        Rotation = 45
    })

    Utility.Create("Frame", {
        Parent = InfoFrame,
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2)
    }, { BackgroundColor3 = "Accent" })

    Utility.Create("TextLabel", {
        Parent = InfoFrame,
        Size = UDim2.new(1, 0, 0, 25),
        BackgroundTransparency = 1,
        Text = "Information",
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold
    }, { TextColor3 = "Text" })

    local Content = Utility.Create("TextLabel", {
        Parent = InfoFrame,
        Size = UDim2.new(1, -20, 1, -30),
        Position = UDim2.new(0, 10, 0, 25),
        BackgroundTransparency = 1,
        Text = "Loading...",
        TextColor3 = self.Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    }, { TextColor3 = "TextDim" })

    -- [Optimization] Cache static info once
    local gameName = "Unknown"
    task.spawn(function()
        local success, result = pcall(function() return MarketplaceService:GetProductInfo(game.PlaceId) end)
        if success and result then gameName = result.Name end
    end)

    local active = true
    self.Janitor:Add(function() active = false end)

    local function UpdateInfo()
        task.spawn(function()
            while not self._dead and active and InfoFrame.Visible and InfoFrame.Parent do
                local fps = math.floor(workspace:GetRealPhysicsFPS())
                local ping = 0
                pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)

                local time = os.date("%H:%M:%S")
                
                Content.Text = string.format(
                    "Game: %s\nUser: %s\nFPS: %d  |  Ping: %d ms\nTime: %s",
                    gameName,
                    Players.LocalPlayer.Name,
                    fps,
                    ping,
                    time
                )
                task.wait(1)
            end
        end)
    end

    InfoFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if InfoFrame.Visible then UpdateInfo() end
    end)

    if InfoFrame.Visible then UpdateInfo() end
end

function Library:KeySystem(options)
    options = options or {}
    local Title = options.Title or "Key System"
    local SubTitle = options.Subtitle or "Enter key to access"
    local Link = options.Link
    local Keys = options.Keys or self.Keys or ""
    local Callback = options.Callback or function() end
    local Folder = self.ConfigFolder
    local File = Folder .. "/" .. (self.ID or "default") .. "_auth.bin" -- [Security] Randomized/ID-based filename
    
    if type(Keys) == "string" then Keys = {Keys} end

    local function Hash(str)
        local h = 0
        for i = 1, #str do
            h = (h * 31 + string.byte(str, i)) % 104729
        end
        return tostring(h)
    end
    
    local function Validate(input)
        for _, key in pairs(Keys) do
            if input == Hash(key) then return true end
        end
        return false
    end
    
    if isfolder(Folder) and isfile(File) then
        local content = readfile(File)
        if Validate(content) then
            Callback()
            return
        end
    end
    
    local KeyFrame = Utility.Create("Frame", {
        Name = "KeySystem",
        Parent = self.Gui,
        Size = UDim2.fromOffset(350, 160),
        Position = UDim2.fromScale(0.5, 0.5),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Theme.Card,
        ZIndex = 1000
    }, { BackgroundColor3 = "Card" })
    
    Utility.Create("UICorner", { Parent = KeyFrame, CornerRadius = UDim.new(0, 6) })
    Utility.Create("UIStroke", { Parent = KeyFrame, Color = self.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    Utility.Drag(KeyFrame, nil, self)
    
    -- Accent Top
    Utility.Create("Frame", {
        Parent = KeyFrame,
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0
    }, { BackgroundColor3 = "Accent" })
    
    -- Title
    Utility.Create("TextLabel", {
        Parent = KeyFrame,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 15),
        BackgroundTransparency = 1,
        Text = Title,
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    }, { TextColor3 = "Text" })
    
    -- Subtitle
    Utility.Create("TextLabel", {
        Parent = KeyFrame,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundTransparency = 1,
        Text = SubTitle,
        TextColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    }, { TextColor3 = "TextDim" })
    
    -- Input
    local Input = Utility.Create("TextBox", {
        Parent = KeyFrame,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 0, 65),
        BackgroundColor3 = self.Theme.Sidebar,
        TextColor3 = self.Theme.Text,
        PlaceholderText = "Enter Key...",
        PlaceholderColor3 = self.Theme.TextDim,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        Text = "",
        ClearTextOnFocus = false
    }, { BackgroundColor3 = "Sidebar", TextColor3 = "Text", PlaceholderColor3 = "TextDim" })
    Utility.Create("UICorner", { Parent = Input, CornerRadius = UDim.new(0, 4) })
    Utility.Create("UIStroke", { Parent = Input, Color = self.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    
    -- Buttons
    local ButtonContainer = Utility.Create("Frame", {
        Parent = KeyFrame,
        Size = UDim2.new(1, -20, 0, 30),
        Position = UDim2.new(0, 10, 1, -40),
        BackgroundTransparency = 1
    })
    
    local function CreateBtn(text, size, pos, cb)
        local Btn = Utility.Create("TextButton", {
            Parent = ButtonContainer,
            Size = size,
            Position = pos,
            BackgroundColor3 = self.Theme.Sidebar,
            Text = text,
            TextColor3 = self.Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            AutoButtonColor = false
        }, { BackgroundColor3 = "Sidebar", TextColor3 = "Text" })
        Utility.Create("UICorner", { Parent = Btn, CornerRadius = UDim.new(0, 4) })
        local Stroke = Utility.Create("UIStroke", { Parent = Btn, Color = self.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
        
        Btn.MouseEnter:Connect(function()
            TweenService:Create(Btn, TI_02, { BackgroundColor3 = self.Theme.Outline }):Play()
            TweenService:Create(Stroke, TI_02, { Color = self.Theme.Accent }):Play()
        end)
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Btn, TI_02, { BackgroundColor3 = self.Theme.Sidebar }):Play()
            TweenService:Create(Stroke, TI_02, { Color = self.Theme.Outline }):Play()
        end)
        Btn.MouseButton1Click:Connect(cb)
        return Btn
    end
    
    local SubmitBtn = CreateBtn("Submit", UDim2.new(Link and 0.48 or 1, 0, 1, 0), UDim2.new(0, 0, 0, 0), function()
        if Validate(Hash(Input.Text)) then
            if not isfolder(Folder) then makefolder(Folder) end
            task.delay(2, function()
                writefile(File, Hash(Input.Text))
            end)
            self:Notify({ Title = "Success", Content = "Key Validated!", Duration = 3 })
            KeyFrame:Destroy()
            Callback()
        else
            self:Notify({ Title = "Error", Content = "Invalid Key", Duration = 3 })
            Input.Text = ""
        end
    end)
    
    if Link then
        CreateBtn("Get Key", UDim2.new(0.48, 0, 1, 0), UDim2.new(0.52, 0, 0, 0), function()
            if setclipboard then
                setclipboard(Link)
                self:Notify({ Title = "Link Copied", Content = Link, Duration = 5 })
            else
                self:Notify({ Title = "Error", Content = "Clipboard not supported", Duration = 3 })
            end
        end)
    end
end

function Library:CreateLoader(options)
    options = options or {}
    local title = options.Title or "Loader"
    local libraryInstance = self
    
    local LoaderGroup = Utility.Create("CanvasGroup", {
        Name = "Loader",
        Parent = self.Gui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(350, 100),
        BackgroundColor3 = self.Theme.Card,
        BorderSizePixel = 0,
        GroupTransparency = 0,
        ZIndex = 300
    }, { BackgroundColor3 = "Card" })
    Utility.Create("UICorner", { Parent = LoaderGroup, CornerRadius = UDim.new(0, 6) })
    Utility.Create("UIStroke", { Parent = LoaderGroup, Color = self.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    
    -- Accent Strip
    Utility.Create("Frame", {
        Parent = LoaderGroup,
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2)
    }, { BackgroundColor3 = "Accent" })

    -- Title
    Utility.Create("TextLabel", {
        Parent = LoaderGroup,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.Theme.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, { TextColor3 = "Text" })

    -- Status Text
    local StatusLabel = Utility.Create("TextLabel", {
        Parent = LoaderGroup,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 10, 0, 45),
        BackgroundTransparency = 1,
        Text = "Initializing...",
        TextColor3 = self.Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left
    }, { TextColor3 = "TextDim" })

    -- Progress Bar Background
    local BarBG = Utility.Create("Frame", {
        Parent = LoaderGroup,
        Size = UDim2.new(1, -20, 0, 4),
        Position = UDim2.new(0, 10, 0, 75),
        BackgroundColor3 = self.Theme.Outline,
        BorderSizePixel = 0
    }, { BackgroundColor3 = "Outline" })
    Utility.Create("UICorner", { Parent = BarBG, CornerRadius = UDim.new(1, 0) })

    -- Progress Bar Fill
    local BarFill = Utility.Create("Frame", {
        Parent = BarBG,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0
    }, { BackgroundColor3 = "Accent" })
    Utility.Create("UICorner", { Parent = BarFill, CornerRadius = UDim.new(1, 0) })

    return {
        Update = function(self, text, progress)
            StatusLabel.Text = text
            TweenService:Create(BarFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(progress, 0, 1, 0) }):Play()
        end,
        Finish = function(self)
            TweenService:Create(LoaderGroup, TweenInfo.new(0.5), { GroupTransparency = 1 }):Play()
            task.wait(0.5)
            LoaderGroup:Destroy()
            if libraryInstance.MainWindow and libraryInstance.MainWindow.Root then
                libraryInstance.MainWindow.Root.Visible = true
                TweenService:Create(libraryInstance.MainWindow.Root, TweenInfo.new(0.5), { GroupTransparency = 0 }):Play()
            end
        end
    }
end

function Library:CreateColorPickerWindow()
    local CP = Utility.Create("TextButton", {
        Name = "ColorPickerWindow",
        Parent = self.Gui,
        BackgroundColor3 = self.Theme.Card,
        Size = UDim2.fromOffset(220, 270),
        Position = UDim2.fromScale(0.5, 0.5),
        Visible = false,
        ZIndex = 200,
        Active = true,
        Text = "",
        AutoButtonColor = false
    }, { BackgroundColor3 = "Card" })
    Utility.Create("UICorner", { Parent = CP, CornerRadius = UDim.new(0, 6) })
    Utility.Create("UIStroke", { Parent = CP, Color = self.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    Utility.Drag(CP, nil, self)
    self.ColorPickerWindow = CP
    local Tooltip = Utility.Create("Frame", {
        Name = "Tooltip",
        Parent = self.Gui,
        BackgroundColor3 = self.Theme.Card,
        Size = UDim2.fromOffset(0, 0),
        AutomaticSize = Enum.AutomaticSize.XY,
        Visible = false,
        ZIndex = 500
    }, { BackgroundColor3 = "Card" })
    Utility.Create("UICorner", { Parent = Tooltip, CornerRadius = UDim.new(0, 4) })
    Utility.Create("UIStroke", { Parent = Tooltip, Color = self.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    
    local TooltipText = Utility.Create("TextLabel", {
        Parent = Tooltip,
        BackgroundTransparency = 1,
        TextColor3 = self.Theme.Text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        Size = UDim2.fromOffset(0, 0),
        AutomaticSize = Enum.AutomaticSize.XY
    }, { TextColor3 = "Text" })
    Utility.Create("UIPadding", { Parent = Tooltip, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) })
    
    self.Tooltip = Tooltip
    self.TooltipText = TooltipText
    
    self.PickerHSV = { h = 0, s = 1, v = 1 }
    
    Utility.Create("UIGradient", {
        Parent = CP,
        Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(0.9,0.9,0.9)),
        Rotation = 45
    })
    
    Utility.Create("Frame", {
        Parent = CP,
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 2)
    }, { BackgroundColor3 = "Accent" })
    
    local Overlay = Utility.Create("TextButton", {
        Name = "ModalOverlay",
        Parent = self.Gui,
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Visible = false,
        ZIndex = 199,
        Text = "",
        AutoButtonColor = false
    })
    self.ModalOverlay = Overlay
    
    Overlay.MouseButton1Click:Connect(function()
        self:CloseColorPicker()
    end)

    Utility.Create("TextLabel", {
        Parent = CP,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = "Color Picker",
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    }, { TextColor3 = "Text" })

    local SVMap = Utility.Create("ImageButton", {
        Parent = CP,
        Size = UDim2.new(0, 160, 0, 160),
        Position = UDim2.new(0, 10, 0, 35),
        BackgroundColor3 = Color3.new(1, 0, 0),
        Image = "rbxassetid://4155801252",
        AutoButtonColor = false
    })
    Utility.Create("UICorner", { Parent = SVMap, CornerRadius = UDim.new(0, 4) })
    self.CP_SV = SVMap

    local SVCursor = Utility.Create("Frame", {
        Parent = SVMap,
        Size = UDim2.new(0, 4, 0, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    })
    Utility.Create("UIStroke", { Parent = SVCursor, Color = Color3.new(0, 0, 0), Thickness = 1 })
    self.CP_SVCursor = SVCursor

    local HueSlider = Utility.Create("ImageButton", {
        Parent = CP,
        Size = UDim2.new(0, 20, 0, 160),
        Position = UDim2.new(0, 180, 0, 35),
        BackgroundColor3 = Color3.new(1, 1, 1),
        AutoButtonColor = false
    })
    Utility.Create("UICorner", { Parent = HueSlider, CornerRadius = UDim.new(0, 4) })
    Utility.Create("UIGradient", {
        Parent = HueSlider,
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(1, 1, 1)),
            ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.833, 1, 1)),
            ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.667, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
            ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.333, 1, 1)),
            ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.167, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1))
        })
    })
    self.CP_Hue = HueSlider

    local HueCursor = Utility.Create("Frame", {
        Parent = HueSlider,
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0
    })
    Utility.Create("UIStroke", { Parent = HueCursor, Color = Color3.new(0, 0, 0), Thickness = 1 })
    self.CP_HueCursor = HueCursor

    local AlphaSlider = Utility.Create("TextButton", {
        Parent = CP,
        Size = UDim2.new(0, 160, 0, 10),
        Position = UDim2.new(0, 10, 0, 205),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 1
    })
    Utility.Create("UICorner", { Parent = AlphaSlider, CornerRadius = UDim.new(0, 4) })
    
    local AlphaChecker = Utility.Create("ImageLabel", {
        Parent = AlphaSlider,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://3887014957",
        ScaleType = Enum.ScaleType.Tile,
        TileSize = UDim2.new(0, 10, 0, 10),
        ZIndex = 1
    })
    Utility.Create("UICorner", { Parent = AlphaChecker, CornerRadius = UDim.new(0, 4) })
    
    local AlphaGradient = Utility.Create("Frame", {
        Parent = AlphaSlider,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        ZIndex = 2
    })
    Utility.Create("UICorner", { Parent = AlphaGradient, CornerRadius = UDim.new(0, 4) })
    Utility.Create("UIGradient", { Parent = AlphaGradient, Transparency = NumberSequence.new(0, 1) })
    self.CP_Alpha = AlphaSlider
    self.CP_AlphaGradient = AlphaGradient

    local AlphaCursor = Utility.Create("Frame", {
        Parent = AlphaSlider,
        Size = UDim2.new(0, 2, 1, 0),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 3
    })
    Utility.Create("UIStroke", { Parent = AlphaCursor, Color = Color3.new(0, 0, 0), Thickness = 1 })
    self.CP_AlphaCursor = AlphaCursor

    local AlphaInput = Utility.Create("TextBox", {
        Parent = CP,
        Size = UDim2.new(0, 35, 0, 16),
        Position = UDim2.new(0, 175, 0, 202),
        BackgroundColor3 = self.Theme.Sidebar,
        Text = "0.00",
        TextColor3 = self.Theme.Text,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false
    }, { BackgroundColor3 = "Sidebar", TextColor3 = "Text" })
    Utility.Create("UIStroke", { Parent = AlphaInput, Color = self.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    Utility.Create("UICorner", { Parent = AlphaInput, CornerRadius = UDim.new(0, 4) })
    self.CP_AlphaInput = AlphaInput

    local HexInput = Utility.Create("TextBox", {
        Parent = CP,
        Size = UDim2.new(0, 60, 0, 20),
        Position = UDim2.new(1, -70, 0, 5),
        BackgroundColor3 = self.Theme.Sidebar,
        Text = "#FFFFFF",
        TextColor3 = self.Theme.Text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        ClearTextOnFocus = false
    }, { BackgroundColor3 = "Sidebar", TextColor3 = "Text" })
    Utility.Create("UIStroke", { Parent = HexInput, Color = self.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    Utility.Create("UICorner", { Parent = HexInput, CornerRadius = UDim.new(0, 4) })
    
    HexInput:GetPropertyChangedSignal("Text"):Connect(function()
        if #HexInput.Text > 7 then
            HexInput.Text = string.sub(HexInput.Text, 1, 7)
        end
    end)
    
    self.CP_Hex = HexInput

    Utility.Create("Frame", {
        Parent = CP,
        BackgroundColor3 = self.Theme.Outline,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 225)
    }, { BackgroundColor3 = "Outline" })

    local RainbowToggle = Utility.Create("TextButton", {
        Parent = CP,
        Size = UDim2.new(0, 95, 0, 25),
        Position = UDim2.new(0, 10, 0, 235),
        BackgroundColor3 = self.Theme.Sidebar,
        Text = "Rainbow: Off",
        TextColor3 = self.Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        AutoButtonColor = false
    }, { BackgroundColor3 = "Sidebar", TextColor3 = "TextDim" })
    Utility.Create("UIStroke", { Parent = RainbowToggle, Color = self.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    Utility.Create("UICorner", { Parent = RainbowToggle, CornerRadius = UDim.new(0, 4) })
    self.CP_Rainbow = RainbowToggle

    local SpeedSlider = Utility.Create("TextButton", {
        Parent = CP,
        Size = UDim2.new(0, 95, 0, 25),
        Position = UDim2.new(0, 115, 0, 235),
        BackgroundColor3 = self.Theme.Sidebar,
        Text = "",
        AutoButtonColor = false,
        ClipsDescendants = true -- [Fix] Clip the fill so it looks like a proper bar
    }, { BackgroundColor3 = "Sidebar" })
    Utility.Create("UIStroke", { Parent = SpeedSlider, Color = self.Theme.Outline, Thickness = 1 }, { Color = "Outline" })
    Utility.Create("UICorner", { Parent = SpeedSlider, CornerRadius = UDim.new(0, 4) })
    
    local SpeedFill = Utility.Create("Frame", {
        Parent = SpeedSlider,
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundColor3 = self.Theme.Accent
    }, { BackgroundColor3 = "Accent" })
    -- [Fix] Removed inner UICorner to prevent "weird" pill-in-pill look
    
    local SpeedLabel = Utility.Create("TextLabel", {
        Parent = SpeedSlider,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "Speed: 1.0",
        TextColor3 = self.Theme.Text,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        ZIndex = 2
    }, { TextColor3 = "Text" })
    self.CP_Speed = SpeedSlider
    self.CP_SpeedFill = SpeedFill
    self.CP_SpeedLabel = SpeedLabel

    -- [Optimization] Conditional Heartbeat
    function self:UpdateRainbowLoop()
        if next(self.Rainbows) and not self.RainbowConnection then
            self.RainbowConnection = RunService.Heartbeat:Connect(function()
                for state, callback in pairs(self.Rainbows) do
                    if state.Rainbow then
                        local hue = (tick() * state.Speed) % 1
                        local color = Color3.fromHSV(hue, 1, 1)
                        state.Color = color
                        Utility.pcallNotify(self, callback, color, state.Transparency, state.Rainbow, state.Speed)
                        if self.CurrentPickerState == state then
                            self.CP_SV.BackgroundColor3 = color
                            self.CP_Hex.Text = Utility.ToHex(color)
                            self.CP_AlphaGradient.BackgroundColor3 = color
                        end
                    end
                end
            end)
            self.Janitor:Add(self.RainbowConnection)
        elseif not next(self.Rainbows) and self.RainbowConnection then
            self.RainbowConnection:Disconnect()
            self.RainbowConnection = nil
        end
    end

    local function UpdatePickerFromInput()
        local state = self.CurrentPickerState
        if not state then return end
        
        local h, s, v = self.PickerHSV.h, self.PickerHSV.s, self.PickerHSV.v
        local alpha = state.Transparency or 0
        local speed = state.Speed or 1
        local rainbow = state.Rainbow
        
        local color = Color3.fromHSV(h, s, v)
        state.Color = color
        state.Transparency = alpha
        state.Speed = speed
        
        self.CP_SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        self.CP_AlphaGradient.BackgroundColor3 = color
        self.CP_Hex.Text = Utility.ToHex(color)
        
        self.CP_SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
        self.CP_SVCursor.BackgroundColor3 = color
        self.CP_HueCursor.Position = UDim2.new(0, 0, 1 - h, 0)
        self.CP_AlphaCursor.Position = UDim2.new(alpha, 0, 0, 0)
        self.CP_AlphaInput.Text = string.format("%.2f", alpha)
        self.CP_SpeedFill.Size = UDim2.new(speed / 5, 0, 1, 0)
        self.CP_SpeedLabel.Text = string.format("Speed: %.1f", speed)

        if self.CurrentPickerCallback then
            Utility.pcallNotify(self, self.CurrentPickerCallback, color, alpha, rainbow, speed)
        end
        if rainbow then
            self.Rainbows[state] = self.CurrentPickerCallback
        else
            self.Rainbows[state] = nil
        end
        self:UpdateRainbowLoop()
    end

    self.CP_SV.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            self.DraggingColor = {
                Update = function(input)
                    local size = self.CP_SV.AbsoluteSize
                    local pos = self.CP_SV.AbsolutePosition
                    self.PickerHSV.s = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                    self.PickerHSV.v = 1 - math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
                    UpdatePickerFromInput()
                end
            }
            self.DraggingColor.Update(input)
        end 
    end)
    self.CP_Hue.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            self.DraggingColor = {
                Update = function(input)
                    local size = self.CP_Hue.AbsoluteSize
                    local pos = self.CP_Hue.AbsolutePosition
                    self.PickerHSV.h = 1 - math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
                    UpdatePickerFromInput()
                end
            }
            self.DraggingColor.Update(input)
        end 
    end)
    self.CP_Alpha.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            self.DraggingColor = {
                Update = function(input)
                    local size = self.CP_Alpha.AbsoluteSize
                    local pos = self.CP_Alpha.AbsolutePosition
                    self.CurrentPickerState.Transparency = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                    UpdatePickerFromInput()
                end
            }
            self.DraggingColor.Update(input)
        end 
    end)
    self.CP_Speed.InputBegan:Connect(function(input) 
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            self.DraggingColor = {
                Update = function(input)
                    local size = self.CP_Speed.AbsoluteSize
                    local pos = self.CP_Speed.AbsolutePosition
                    local pct = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
                    self.CurrentPickerState.Speed = pct * 5
                    UpdatePickerFromInput()
                end
            }
            self.DraggingColor.Update(input)
        end 
    end)

    self.CP_Hex.FocusLost:Connect(function()
        if not self.CurrentPickerState then return end
        local success, newColor = pcall(function() return Color3.fromHex(self.CP_Hex.Text) end)
        if success then
            local nh, ns, nv = newColor:ToHSV()
            self.PickerHSV.h, self.PickerHSV.s, self.PickerHSV.v = nh, ns, nv
            UpdatePickerFromInput()
        else
            self:Notify({Title="Color Error", Content="Invalid Hex code.", Duration=5})
            self.CP_Hex.Text = Utility.ToHex(self.CurrentPickerState.Color)
        end
    end)

    self.CP_AlphaInput.FocusLost:Connect(function()
        if not self.CurrentPickerState then return end
        local n = tonumber(self.CP_AlphaInput.Text)
        if n then
            self.CurrentPickerState.Transparency = math.clamp(n, 0, 1)
            UpdatePickerFromInput()
        else
            self.CP_AlphaInput.Text = string.format("%.2f", self.CurrentPickerState.Transparency or 0)
        end
    end)

    self.CP_Rainbow.MouseButton1Click:Connect(function()
        if not self.CurrentPickerState then return end
        self.CurrentPickerState.Rainbow = not self.CurrentPickerState.Rainbow
        self.CP_Rainbow.Text = "Rainbow: " .. (self.CurrentPickerState.Rainbow and "On" or "Off")
        self.CP_Rainbow.TextColor3 = self.CurrentPickerState.Rainbow and self.Theme.Accent or self.Theme.TextDim
        UpdatePickerFromInput()
    end, { TextColor3 = self.CurrentPickerState and self.CurrentPickerState.Rainbow and "Accent" or "TextDim" })
end

function Library:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local content = options.Content or "Message"
    local duration = options.Duration or 3
    local force = options.Force or false

    if not self.NotificationsEnabled and not force then return end

    -- [Optimization] Limit notifications
    local activeNotes = self.NotificationHolder:GetChildren()
    if #activeNotes >= 5 then
        -- Remove oldest (first child usually)
        for _, c in ipairs(activeNotes) do if c:IsA("Frame") then c:Destroy() break end end
    end

    local Frame = Utility.Create("Frame", {
        Parent = self.NotificationHolder,
        BackgroundColor3 = self.Theme.Card,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1
    }, { BackgroundColor3 = "Card" })
    Utility.Create("UICorner", { Parent = Frame, CornerRadius = UDim.new(0, 4) })
    local Stroke = Utility.Create("UIStroke", { Parent = Frame, Color = self.Theme.Outline, Thickness = 1, Transparency = 1 }, { Color = "Outline" })

    Utility.Create("Frame", {
        Name = "Accent",
        Parent = Frame,
        BackgroundColor3 = self.Theme.Accent,
        Size = UDim2.new(0, 2, 1, 0),
        BorderSizePixel = 0,
        BackgroundTransparency = 1
    }, { BackgroundColor3 = "Accent" })

    local TitleLabel = Utility.Create("TextLabel", {
        Parent = Frame,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 10, 0, 5),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = self.Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1
    }, { TextColor3 = "Text" })

    local ContentLabel = Utility.Create("TextLabel", {
        Parent = Frame,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 10, 0, 25),
        BackgroundTransparency = 1,
        Text = content,
        TextColor3 = self.Theme.TextDim,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTransparency = 1
    }, { TextColor3 = "TextDim" })

    TweenService:Create(Frame, TweenInfo.new(0.3), { BackgroundTransparency = self.NotificationTransparency }):Play()
    TweenService:Create(Stroke, TweenInfo.new(0.3), { Transparency = 0 }):Play()
    TweenService:Create(Frame.Accent, TweenInfo.new(0.3), { BackgroundTransparency = 0 }):Play()
    TweenService:Create(TitleLabel, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()
    TweenService:Create(ContentLabel, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()

    task.delay(duration, function()
        TweenService:Create(Frame, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        TweenService:Create(Stroke, TweenInfo.new(0.3), { Transparency = 1 }):Play()
        TweenService:Create(Frame.Accent, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
        TweenService:Create(TitleLabel, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        TweenService:Create(ContentLabel, TweenInfo.new(0.3), { TextTransparency = 1 }):Play()
        task.wait(0.3)
        Frame:Destroy()
    end)
end

function Library:OpenColorPicker(state, source, callback)
    if self.ColorPickerWindow.Visible and self.CurrentPickerState == state then
        self:CloseColorPicker()
        return
    end

    self.ColorPickerWindow.Visible = true
    self.ModalOverlay.Visible = true
    self.CurrentPickerState = state
    self.CurrentPickerCallback = callback
    
    if source then
        self.ColorPickerWindow.Position = UDim2.fromOffset(
            source.AbsolutePosition.X + source.AbsoluteSize.X + 10,
            source.AbsolutePosition.Y
        )
    end
    
    local h, s, v = state.Color:ToHSV()
    self.PickerHSV = { h = h, s = s, v = v }
    local alpha = state.Transparency
    local rainbow = state.Rainbow
    local speed = state.Speed

    -- Update UI to match State
    self.CP_SV.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
    self.CP_AlphaGradient.BackgroundColor3 = state.Color
    self.CP_Hex.Text = Utility.ToHex(state.Color)
    self.CP_Rainbow.Text = "Rainbow: " .. (rainbow and "On" or "Off")
    self.CP_Rainbow.TextColor3 = rainbow and self.Theme.Accent or self.Theme.TextDim
    self.CP_SpeedFill.Size = UDim2.new(speed / 5, 0, 1, 0)
    self.CP_SpeedLabel.Text = string.format("Speed: %.1f", speed)
    
    self.CP_SVCursor.Position = UDim2.new(s, 0, 1 - v, 0)
    self.CP_SVCursor.BackgroundColor3 = state.Color
    self.CP_HueCursor.Position = UDim2.new(0, 0, 1 - h, 0)
    self.CP_AlphaCursor.Position = UDim2.new(alpha, 0, 0, 0)
end

function Library:CloseColorPicker()
    self.ColorPickerWindow.Visible = false
    self.ModalOverlay.Visible = false
    self.CurrentPickerState = nil
    self.CurrentPickerCallback = nil
end

function Library:ShowTooltip(text)
    self.TooltipText.Text = text
    self.Tooltip.Visible = true
    
    if self.TooltipConnection then self.TooltipConnection:Disconnect() end
    -- [Optimization] Use InputChanged instead of RenderStepped
    self.TooltipConnection = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = UserInputService:GetMouseLocation()
            self.Tooltip.Position = UDim2.fromOffset(mouse.X + 15, mouse.Y + 15)
        end
    end)
end

function Library:HideTooltip()
    self.Tooltip.Visible = false
    if self.TooltipConnection then
        self.TooltipConnection:Disconnect()
        self.TooltipConnection = nil
    end
end

function Library:Toggle()
    if self.MainWindow and self.MainWindow.Root then
        self.MainWindow.Root.Visible = not self.MainWindow.Root.Visible
        if not self.MainWindow.Root.Visible then
            self:CloseColorPicker()
            self.NotificationHolder.BackgroundTransparency = 1
            self.NotificationHolderTitle.Visible = false
        else
            if self.NotificationsEnabled then
                self.NotificationHolder.BackgroundTransparency = self.NotificationAnchorTransparency
                self.NotificationHolderTitle.Visible = true
            end
        end
    end
end

function Library:UpdateKeybind(id, name, key, state)
    -- [Fix] Handle unbinding/removal correctly
    if not key or key == Enum.KeyCode.Unknown then
        if self.Keybinds[id] then
            self.Keybinds[id]:Destroy()
            self.Keybinds[id] = nil
        end
        return
    end
    
    if not self.KeybindContainer then return end
    
    if not self.Keybinds[id] then
        local Label = Utility.Create("TextLabel", {
            Parent = self.KeybindContainer,
            Size = UDim2.new(1, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = string.format("[%s] %s", (key.Name == "MouseButton1" and "M1") or (key.Name == "MouseButton2" and "M2") or (key.Name == "MouseButton3" and "M3") or key.Name, name),
            TextColor3 = self.Theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.Gotham
        }, { TextColor3 = "TextDim" })
        self.Keybinds[id] = Label
    end

    local Label = self.Keybinds[id]
    Label.Text = string.format("[%s] %s", (key.Name == "MouseButton1" and "M1") or (key.Name == "MouseButton2" and "M2") or (key.Name == "MouseButton3" and "M3") or key.Name, name)
    Label.TextColor3 = state and self.Theme.Accent or self.Theme.TextDim
    if not Library.ThemeObjects[Label] then Library.ThemeObjects[Label] = {} end
    Library.ThemeObjects[Label]["TextColor3"] = state and "Accent" or "TextDim"
end

function Library:SetTheme(themeName)
    local theme = self.Themes[themeName]
    if not theme then return end
    
    for k, v in pairs(theme) do self.Theme[k] = v end
    self:UpdateThemeObjects()
end

function Library:UpdateThemeObjects()
    -- [Optimization] Use Registry instead of GetDescendants
    for obj, bindings in pairs(self.ThemeObjects) do
        for prop, themeKey in pairs(bindings) do
            if self.Theme[themeKey] then
                pcall(function() obj[prop] = self.Theme[themeKey] end)
            end
        end
    end
end

function Library:AddTheme(name, theme)
    self.Themes[name] = theme
end

function Library:SetThemeColor(key, color)
    self.Theme[key] = color
    -- [Optimization] Use Registry
    for obj, bindings in pairs(self.ThemeObjects) do
        for prop, themeKey in pairs(bindings) do
            if themeKey == key then
                pcall(function() obj[prop] = color end)
            end
        end
    end
end

function Library:SaveConfig(name)
    if not name or name == "" then return end
    
    local data = {
        Flags = self.Flags,
        Theme = {},
        Positions = {}
    }
    
    for k, v in pairs(self.Theme) do data.Theme[k] = Utility.ColorToTable(v) end
    
    -- Saving Extra Windows (Excluding Main as requested)
    if self.Watermark then data.Positions.Watermark = Utility.UDim2ToTable(self.Watermark.Position) end
    if self.KeybindFrame then data.Positions.KeybindList = Utility.UDim2ToTable(self.KeybindFrame.Position) end
    if self.InfoWindow then data.Positions.InfoWindow = Utility.UDim2ToTable(self.InfoWindow.Position) end
    
    for winName, winFrame in pairs(self.CustomWindows) do
        data.Positions[winName] = Utility.UDim2ToTable(winFrame.Position)
    end
    
    local json = Utility.SafeSave(data)
    if json then
        if not isfolder(self.ConfigFolder) then makefolder(self.ConfigFolder) end
        writefile(self.ConfigFolder .. "/" .. name .. ".json", json)
        self:Notify({ Title = "Config", Content = "Saved " .. name, Duration = 3 })
    end
end

function Library:LoadConfig(name)
    if not name or name == "" then return end
    if not isfile(self.ConfigFolder .. "/" .. name .. ".json") then return end
    
    local content = readfile(self.ConfigFolder .. "/" .. name .. ".json")
    local data = Utility.SafeLoad(content)
    
    if data then
        -- Load Theme
        if data.Theme then
            for k, v in pairs(data.Theme) do
                self:SetThemeColor(k, Utility.TableToColor(v))
            end
        end
        
        -- Load Positions
        if data.Positions then
            if data.Positions.Watermark and self.Watermark then
                self.Watermark.Position = Utility.TableToUDim2(data.Positions.Watermark)
            end
            if data.Positions.KeybindList and self.KeybindFrame then
                self.KeybindFrame.Position = Utility.TableToUDim2(data.Positions.KeybindList)
            end
            if data.Positions.InfoWindow and self.InfoWindow then
                self.InfoWindow.Position = Utility.TableToUDim2(data.Positions.InfoWindow)
            end
            
            for winName, pos in pairs(data.Positions) do
                if winName ~= "Main" and self.CustomWindows[winName] then
                    self.CustomWindows[winName].Position = Utility.TableToUDim2(pos)
                end
            end
        end
        
        -- Load Flags
        local flags = data.Flags or data -- Support legacy format if exists
        for flag, value in pairs(flags) do
            if self.ConfigRegistry[flag] then
                self.ConfigRegistry[flag].Set(value, true) -- [Optimization] Silent load
            end
        end
        self:Notify({ Title = "Config", Content = "Loaded " .. name, Duration = 3 })
    end
end

function Library:GetConfigs()
    if not isfolder(self.ConfigFolder) then makefolder(self.ConfigFolder) end
    local files = listfiles(self.ConfigFolder)
    local configs = {}
    for _, file in ipairs(files) do
        if file:sub(-5) == ".json" then
            table.insert(configs, file:match("([^/\\]+)%.json$"))
        end
    end
    return configs
end

function Library:Destroy()
    self._dead = true
    if self.Gui then
        self.Gui:Destroy()
    end
    self.Janitor:Destroy()
    if self.TooltipConnection then
        self.TooltipConnection:Disconnect()
        self.TooltipConnection = nil
    end
    if self.ID and GlobalEnv[self.ID] == self then
        GlobalEnv[self.ID] = nil
    end
end

return Library
