--[[
    KILASIK's Auto Multi-Target Fling Exploit
    Phiên bản tiếng Việt với UI đẹp và danh sách phân trang
    Tính năng:
    - Tự động fling tất cả người chơi
    - Hiển thị danh sách đã fling (10 người/trang)
    - UI hiện đại với hiệu ứng
    - Tương thích JJSploit, Synapse X, etc.
]]

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KilasikAutoFlingGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 470)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -235)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = false
MainFrame.Parent = ScreenGui

-- Shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.7
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.ZIndex = 0
Shadow.Parent = MainFrame

-- Corner rounding
local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

-- Gradient Background
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
}
Gradient.Rotation = 45
Gradient.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

-- Title gradient
local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 100, 100))
}
TitleGradient.Rotation = 90
TitleGradient.Parent = TitleBar

-- Title Icon
local TitleIcon = Instance.new("TextLabel")
TitleIcon.Size = UDim2.new(0, 40, 0, 40)
TitleIcon.Position = UDim2.new(0, 5, 0.5, -20)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "⚡"
TitleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleIcon.Font = Enum.Font.SourceSansBold
TitleIcon.TextSize = 28
TitleIcon.Parent = TitleBar

-- Title Text
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 45, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "TỰ ĐỘNG FLING"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

-- Status Badge
local StatusBadge = Instance.new("Frame")
StatusBadge.Size = UDim2.new(0, 80, 0, 24)
StatusBadge.Position = UDim2.new(1, -90, 0.5, -12)
StatusBadge.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
StatusBadge.BorderSizePixel = 0
StatusBadge.Parent = TitleBar

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 12)
BadgeCorner.Parent = StatusBadge

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, 0, 1, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "HOẠT ĐỘNG"
StatusText.TextColor3 = Color3.fromRGB(0, 0, 0)
StatusText.Font = Enum.Font.SourceSansBold
StatusText.TextSize = 12
StatusText.Parent = StatusBadge

-- Close Button
local CloseButton = Instance.new("TextButton")
CloseButton.Position = UDim2.new(1, -40, 0.5, -15)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.BackgroundTransparency = 0.9
CloseButton.BorderSizePixel = 0
CloseButton.Text = "✕"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextSize = 18
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 15)
CloseCorner.Parent = CloseButton

-- Stats Container
local StatsContainer = Instance.new("Frame")
StatsContainer.Position = UDim2.new(0, 15, 0, 65)
StatsContainer.Size = UDim2.new(1, -30, 0, 70)
StatsContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
StatsContainer.BorderSizePixel = 0
StatsContainer.Parent = MainFrame

local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 10)
StatsCorner.Parent = StatsContainer

-- Target Count Stat
local TargetStat = Instance.new("Frame")
TargetStat.Size = UDim2.new(0.48, 0, 1, 0)
TargetStat.Position = UDim2.new(0, 0, 0, 0)
TargetStat.BackgroundTransparency = 1
TargetStat.Parent = StatsContainer

local TargetIcon = Instance.new("TextLabel")
TargetIcon.Size = UDim2.new(0, 35, 0, 35)
TargetIcon.Position = UDim2.new(0, 10, 0.5, -17)
TargetIcon.BackgroundTransparency = 1
TargetIcon.Text = "🎯"
TargetIcon.TextSize = 24
TargetIcon.Parent = TargetStat

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, -50, 0, 20)
TargetLabel.Position = UDim2.new(0, 45, 0, 8)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "MỤC TIÊU"
TargetLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
TargetLabel.Font = Enum.Font.SourceSans
TargetLabel.TextSize = 12
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetLabel.Parent = TargetStat

local TargetCount = Instance.new("TextLabel")
TargetCount.Size = UDim2.new(1, -50, 0, 30)
TargetCount.Position = UDim2.new(0, 45, 0, 28)
TargetCount.BackgroundTransparency = 1
TargetCount.Text = "0"
TargetCount.TextColor3 = Color3.fromRGB(255, 255, 255)
TargetCount.Font = Enum.Font.SourceSansBold
TargetCount.TextSize = 24
TargetCount.TextXAlignment = Enum.TextXAlignment.Left
TargetCount.Parent = TargetStat

-- Flinged Count Stat
local FlingedStat = Instance.new("Frame")
FlingedStat.Size = UDim2.new(0.48, 0, 1, 0)
FlingedStat.Position = UDim2.new(0.52, 0, 0, 0)
FlingedStat.BackgroundTransparency = 1
FlingedStat.Parent = StatsContainer

local FlingedIcon = Instance.new("TextLabel")
FlingedIcon.Size = UDim2.new(0, 35, 0, 35)
FlingedIcon.Position = UDim2.new(0, 10, 0.5, -17)
FlingedIcon.BackgroundTransparency = 1
FlingedIcon.Text = "💥"
FlingedIcon.TextSize = 24
FlingedIcon.Parent = FlingedStat

local FlingedLabel = Instance.new("TextLabel")
FlingedLabel.Size = UDim2.new(1, -50, 0, 20)
FlingedLabel.Position = UDim2.new(0, 45, 0, 8)
FlingedLabel.BackgroundTransparency = 1
FlingedLabel.Text = "ĐÃ FLING"
FlingedLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
FlingedLabel.Font = Enum.Font.SourceSans
FlingedLabel.TextSize = 12
FlingedLabel.TextXAlignment = Enum.TextXAlignment.Left
FlingedLabel.Parent = FlingedStat

local FlingedCount = Instance.new("TextLabel")
FlingedCount.Size = UDim2.new(1, -50, 0, 30)
FlingedCount.Position = UDim2.new(0, 45, 0, 28)
FlingedCount.BackgroundTransparency = 1
FlingedCount.Text = "0"
FlingedCount.TextColor3 = Color3.fromRGB(0, 255, 100)
FlingedCount.Font = Enum.Font.SourceSansBold
FlingedCount.TextSize = 24
FlingedCount.TextXAlignment = Enum.TextXAlignment.Left
FlingedCount.Parent = FlingedStat

-- List Title
local ListTitle = Instance.new("TextLabel")
ListTitle.Position = UDim2.new(0, 15, 0, 150)
ListTitle.Size = UDim2.new(1, -30, 0, 25)
ListTitle.BackgroundTransparency = 1
ListTitle.Text = "📋 DANH SÁCH ĐÃ FLING"
ListTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ListTitle.Font = Enum.Font.SourceSansBold
ListTitle.TextSize = 16
ListTitle.TextXAlignment = Enum.TextXAlignment.Left
ListTitle.Parent = MainFrame

-- List Container
local ListContainer = Instance.new("Frame")
ListContainer.Position = UDim2.new(0, 15, 0, 180)
ListContainer.Size = UDim2.new(1, -30, 0, 220)
ListContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
ListContainer.BorderSizePixel = 0
ListContainer.Parent = MainFrame

local ListCorner = Instance.new("UICorner")
ListCorner.CornerRadius = UDim.new(0, 10)
ListCorner.Parent = ListContainer

-- Scrolling Frame for list
local ListScroll = Instance.new("ScrollingFrame")
ListScroll.Position = UDim2.new(0, 5, 0, 5)
ListScroll.Size = UDim2.new(1, -10, 1, -10)
ListScroll.BackgroundTransparency = 1
ListScroll.BorderSizePixel = 0
ListScroll.ScrollBarThickness = 4
ListScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 60, 60)
ListScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
ListScroll.Parent = ListContainer

-- Pagination Controls
local PageContainer = Instance.new("Frame")
PageContainer.Position = UDim2.new(0, 15, 0, 410)
PageContainer.Size = UDim2.new(1, -30, 0, 35)
PageContainer.BackgroundTransparency = 1
PageContainer.Parent = MainFrame

local PrevButton = Instance.new("TextButton")
PrevButton.Size = UDim2.new(0, 80, 0, 35)
PrevButton.Position = UDim2.new(0, 0, 0, 0)
PrevButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
PrevButton.BorderSizePixel = 0
PrevButton.Text = "◀ TRƯỚC"
PrevButton.TextColor3 = Color3.fromRGB(255, 255, 255)
PrevButton.Font = Enum.Font.SourceSansBold
PrevButton.TextSize = 14
PrevButton.Parent = PageContainer

local PrevCorner = Instance.new("UICorner")
PrevCorner.CornerRadius = UDim.new(0, 8)
PrevCorner.Parent = PrevButton

local PageLabel = Instance.new("TextLabel")
PageLabel.Size = UDim2.new(1, -170, 0, 35)
PageLabel.Position = UDim2.new(0, 85, 0, 0)
PageLabel.BackgroundTransparency = 1
PageLabel.Text = "Trang 1"
PageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PageLabel.Font = Enum.Font.SourceSansBold
PageLabel.TextSize = 16
PageLabel.Parent = PageContainer

local NextButton = Instance.new("TextButton")
NextButton.Size = UDim2.new(0, 80, 0, 35)
NextButton.Position = UDim2.new(1, -80, 0, 0)
NextButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
NextButton.BorderSizePixel = 0
NextButton.Text = "SAU ▶"
NextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
NextButton.Font = Enum.Font.SourceSansBold
NextButton.TextSize = 14
NextButton.Parent = PageContainer

local NextCorner = Instance.new("UICorner")
NextCorner.CornerRadius = UDim.new(0, 8)
NextCorner.Parent = NextButton

-- Stop Button
local StopButton = Instance.new("TextButton")
StopButton.Position = UDim2.new(0, 15, 1, -45)
StopButton.Size = UDim2.new(1, -30, 0, 40)
StopButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
StopButton.BorderSizePixel = 0
StopButton.Text = "⏹ DỪNG TỰ ĐỘNG FLING"
StopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
StopButton.Font = Enum.Font.SourceSansBold
StopButton.TextSize = 16
StopButton.Parent = MainFrame

local StopCorner = Instance.new("UICorner")
StopCorner.CornerRadius = UDim.new(0, 10)
StopCorner.Parent = StopButton

-- Variables
local FlingActive = true
local ActiveTargets = {}
local FlingedPlayers = {} -- {name, time}
local CurrentPage = 1
local ItemsPerPage = 10
getgenv().OldPos = nil
getgenv().FPDH = workspace.FallenPartsDestroyHeight

-- Show notification
local function Message(Title, Text, Time)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = Title,
        Text = Text,
        Duration = Time or 5
    })
end

-- Update pagination display
local function UpdatePagination()
    local totalItems = #FlingedPlayers
    local totalPages = math.max(1, math.ceil(totalItems / ItemsPerPage))
    
    PageLabel.Text = "Trang " .. CurrentPage .. "/" .. totalPages
    
    PrevButton.BackgroundColor3 = CurrentPage > 1 and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(30, 30, 40)
    NextButton.BackgroundColor3 = CurrentPage < totalPages and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(30, 30, 40)
end

-- Update flinged players list
local function UpdateFlingedList()
    -- Clear current list
    for _, child in pairs(ListScroll:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
    
    -- Calculate page items
    local startIndex = (CurrentPage - 1) * ItemsPerPage + 1
    local endIndex = math.min(startIndex + ItemsPerPage - 1, #FlingedPlayers)
    
    -- Create list items for current page
    local yPos = 0
    for i = startIndex, endIndex do
        local data = FlingedPlayers[i]
        if data then
            local ItemFrame = Instance.new("Frame")
            ItemFrame.Size = UDim2.new(1, -10, 0, 30)
            ItemFrame.Position = UDim2.new(0, 5, 0, yPos)
            ItemFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            ItemFrame.BorderSizePixel = 0
            ItemFrame.Parent = ListScroll
            
            local ItemCorner = Instance.new("UICorner")
            ItemCorner.CornerRadius = UDim.new(0, 6)
            ItemCorner.Parent = ItemFrame
            
            -- Player number
            local Number = Instance.new("TextLabel")
            Number.Size = UDim2.new(0, 30, 1, 0)
            Number.BackgroundTransparency = 1
            Number.Text = i .. "."
            Number.TextColor3 = Color3.fromRGB(255, 60, 60)
            Number.Font = Enum.Font.SourceSansBold
            Number.TextSize = 14
            Number.Parent = ItemFrame
            
            -- Player name
            local NameLabel = Instance.new("TextLabel")
            NameLabel.Size = UDim2.new(1, -80, 1, 0)
            NameLabel.Position = UDim2.new(0, 35, 0, 0)
            NameLabel.BackgroundTransparency = 1
            NameLabel.Text = data.name
            NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            NameLabel.Font = Enum.Font.SourceSans
            NameLabel.TextSize = 14
            NameLabel.TextXAlignment = Enum.TextXAlignment.Left
            NameLabel.Parent = ItemFrame
            
            -- Time indicator
            local TimeLabel = Instance.new("TextLabel")
            TimeLabel.Size = UDim2.new(0, 45, 1, 0)
            TimeLabel.Position = UDim2.new(1, -45, 0, 0)
            TimeLabel.BackgroundTransparency = 1
            TimeLabel.Text = data.time
            TimeLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
            TimeLabel.Font = Enum.Font.SourceSans
            TimeLabel.TextSize = 11
            TimeLabel.Parent = ItemFrame
            
            yPos = yPos + 35
        end
    end
    
    ListScroll.CanvasSize = UDim2.new(0, 0, 0, yPos)
    UpdatePagination()
end

-- Add player to flinged list
local function AddToFlingedList(playerName)
    -- Check if already in list
    for _, data in ipairs(FlingedPlayers) do
        if data.name == playerName then
            return
        end
    end
    
    -- Get current time
    local timeStr = os.date("%H:%M:%S")
    
    -- Add to list
    table.insert(FlingedPlayers, 1, {name = playerName, time = timeStr}) -- Add to beginning
    
    -- Update display
    FlingedCount.Text = tostring(#FlingedPlayers)
    UpdateFlingedList()
    
    -- Animate count
    local tween = TweenService:Create(FlingedCount, TweenInfo.new(0.3, Enum.EasingStyle.Elastic), {
        TextSize = 28
    })
    tween:Play()
    tween.Completed:Connect(function()
        TweenService:Create(FlingedCount, TweenInfo.new(0.2), {TextSize = 24}):Play()
    end)
end

-- Update status display
local function UpdateStatus()
    local count = 0
    for _ in pairs(ActiveTargets) do
        count = count + 1
    end
    
    TargetCount.Text = tostring(count)
end

-- The fling function
local function SkidFling(TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    if not TCharacter then return end
    
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle
    
    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessory and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end
    
    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        
        if THumanoid and THumanoid.Sit then
            return
        end
        
        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end
        
        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end
        
        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end
        
        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                end
            until Time + TimeToWait < tick() or not FlingActive
        end
        
        workspace.FallenPartsDestroyHeight = 0/0
        
        local BV = Instance.new("BodyVelocity")
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        
        if TRootPart then
            SFBasePart(TRootPart)
        elseif THead then
            SFBasePart(THead)
        elseif Handle then
            SFBasePart(Handle)
        else
            return
        end
        
        -- Add to flinged list after successful fling
        AddToFlingedList(TargetPlayer.Name)
        
        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid
        
        if getgenv().OldPos then
            repeat
                RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                Humanoid:ChangeState("GettingUp")
                for _, part in pairs(Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Velocity, part.RotVelocity = Vector3.new(), Vector3.new()
                    end
                end
                task.wait()
            until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
            workspace.FallenPartsDestroyHeight = getgenv().FPDH
        end
    end
end

-- Add all current players
local function AddAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player and not ActiveTargets[player.Name] then
            ActiveTargets[player.Name] = player
        end
    end
    UpdateStatus()
end

-- Auto-fling loop
spawn(function()
    while FlingActive do
        local validTargets = {}
        
        for name, player in pairs(ActiveTargets) do
            if player and player.Parent then
                validTargets[name] = player
            else
                ActiveTargets[name] = nil
            end
        end
        
        for _, player in pairs(validTargets) do
            if FlingActive then
                SkidFling(player)
                wait(0.1)
            else
                break
            end
        end
        
        UpdateStatus()
        wait(0.5)
    end
end)

-- Handle new players joining
Players.PlayerAdded:Connect(function(player)
    if player ~= Player then
        wait(2)
        ActiveTargets[player.Name] = player
        UpdateStatus()
        Message("Mục Tiêu Mới", player.Name .. " đã được thêm vào danh sách!", 2)
    end
end)

-- Handle players leaving
Players.PlayerRemoving:Connect(function(player)
    if ActiveTargets[player.Name] then
        ActiveTargets[player.Name] = nil
        UpdateStatus()
    end
end)

-- Pagination buttons
PrevButton.MouseButton1Click:Connect(function()
    if CurrentPage > 1 then
        CurrentPage = CurrentPage - 1
        UpdateFlingedList()
    end
end)

NextButton.MouseButton1Click:Connect(function()
    local totalPages = math.max(1, math.ceil(#FlingedPlayers / ItemsPerPage))
    if CurrentPage < totalPages then
        CurrentPage = CurrentPage + 1
        UpdateFlingedList()
    end
end)

-- Button hover effects
local function AddHoverEffect(button, normalColor, hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
    end)
end

AddHoverEffect(CloseButton, Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 100, 100))
AddHoverEffect(StopButton, Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 100, 100))
AddHoverEffect(PrevButton, Color3.fromRGB(50, 50, 70), Color3.fromRGB(70, 70, 90))
AddHoverEffect(NextButton, Color3.fromRGB(50, 50, 70), Color3.fromRGB(70, 70, 90))

-- Stop button
StopButton.MouseButton1Click:Connect(function()
    FlingActive = false
    ActiveTargets = {}
    UpdateStatus()
    
    StatusBadge.BackgroundColor3 = Color3.fromRGB(150, 150, 150)
    StatusText.Text = "ĐÃ DỪNG"
    Title.Text = "ĐÃ DỪNG"
    StopButton.Text = "✓ ĐÃ DỪNG"
    StopButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    
    Message("Đã Dừng", "Tự động fling đã được tắt", 2)
end)

-- Close button
CloseButton.MouseButton1Click:Connect(function()
    FlingActive = false
    ScreenGui:Destroy()
end)

-- Animate UI on load (simplified)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -300)
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    Position = UDim2.new(0.5, -175, 0.5, -235)
}):Play()

-- Initialize
AddAllPlayers()
UpdateFlingedList()

-- Success message
Message("Đã Kích Hoạt!", "Tự động fling tất cả người chơi đang hoạt động!", 3)
