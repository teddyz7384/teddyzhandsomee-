-- LocalScript trong StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local SHIRT_ID = 3204384330
local connections = {}
local toggledOn = true
local currentTargetName = nil

-- ====== Load Fluent UI với xử lý lỗi ======
local Fluent
local success, err = pcall(function()
    Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
end)

if not success or not Fluent then
    warn("Không thể tải Fluent UI:", err)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Parent = player.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.Parent = screenGui
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, -20)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.Text = "Lỗi tải Fluent UI\nVui lòng thử lại"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 18
    label.BackgroundTransparency = 1
    label.Parent = frame
    
    return
end

-- ====== Tạo Window với xử lý lỗi ======
local Window
success, err = pcall(function()
    Window = Fluent:CreateWindow({
        Title = "Thành Phố Vina RP ❄️",
        SubTitle = "made by snow family",
        TabWidth = 130,
        Size = UDim2.fromOffset(460, 440),
        Acrylic = true,
        Theme = "Dark"
    })
end)

if not success or not Window then
    warn("Không thể tạo Window:", err)
    return
end

local MainTab = Window:AddTab({ Title = "Main", Icon = "shirt" })
local SignTab = Window:AddTab({ Title = "Sign", Icon = "sign" })
Window:SelectTab(1)

-- ====== Tạo nút toggle UI trên màn hình (cho mobile) ======
local function createUIToggleButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UIToggleGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player.PlayerGui
    
    local button = Instance.new("TextButton")
    button.Name = "ToggleButton"
    button.Size = UDim2.new(0, 60, 0, 60)
    button.Position = UDim2.new(1, -70, 0.5, -30)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.BackgroundTransparency = 0.2
    button.Text = "UI"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 18
    button.TextScaled = true
    button.Font = Enum.Font.GothamBold
    button.BorderSizePixel = 0
    button.Parent = screenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = button
    
    button.MouseEnter:Connect(function()
        button.BackgroundTransparency = 0.1
        button.Size = UDim2.new(0, 65, 0, 65)
    end)
    
    button.MouseLeave:Connect(function()
        button.BackgroundTransparency = 0.2
        button.Size = UDim2.new(0, 60, 0, 60)
    end)
    
    local uiVisible = true
    
    local function toggleUI()
        uiVisible = not uiVisible
        
        local fluentGui = nil
        for _, gui in ipairs(player.PlayerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and (gui.Name:find("Fluent") or gui.Name:find("FluentUI")) then
                fluentGui = gui
                break
            end
        end
        
        if fluentGui then
            fluentGui.Enabled = uiVisible
        else
            if Window and Window._container then
                local parent = Window._container.Parent
                if parent and parent:IsA("ScreenGui") then
                    parent.Enabled = uiVisible
                end
            end
        end
        
        if uiVisible then
            button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            button.Text = "UI"
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            button.Text = "OFF"
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
        end
    end
    
    button.MouseButton1Click:Connect(toggleUI)
    button.TouchTap:Connect(toggleUI)
    
    return button
end

local toggleButton = createUIToggleButton()

-- ====== Danh sách người chơi (dùng chung) ======
local function getPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player then
            table.insert(names, p.Name)
        end
    end
    return names
end

-- =========================================================
-- ================ FEATURE 1: SHIRT TROLL =================
-- =========================================================
local selectedName = nil

local function applyShirt(character)
    if not toggledOn then return end
    local shirt = character:FindFirstChildOfClass("Shirt")
    if not shirt then
        shirt = Instance.new("Shirt")
        shirt.Parent = character
    end
    shirt.ShirtTemplate = "rbxassetid://" .. SHIRT_ID
end

local function removeShirt(character)
    local shirt = character:FindFirstChildOfClass("Shirt")
    if shirt then
        shirt.ShirtTemplate = ""
    end
end

local function clearConnections()
    for _, conn in ipairs(connections) do
        conn:Disconnect()
    end
    connections = {}
end

local function setTarget(name)
    clearConnections()

    local targetPlayer = Players:FindFirstChild(name)  
    if not targetPlayer then  
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "Lỗi", Content = "Không tìm thấy người chơi: " .. name, Duration = 3 })
        end
        return  
    end  

    currentTargetName = name  

    if targetPlayer.Character and toggledOn then  
        applyShirt(targetPlayer.Character)  
    end  

    local conn = targetPlayer.CharacterAdded:Connect(function(character)  
        applyShirt(character)  
    end)  
    table.insert(connections, conn)  

    if Fluent and Fluent.Notify then
        Fluent:Notify({ Title = "Thành công", Content = "Đã áp dụng áo cho " .. name, Duration = 3 })
    end
end

local Dropdown = MainTab:AddDropdown("PlayerDropdown", {
    Title = "Chọn người chơi",
    Values = getPlayerNames(),
    Multi = false,
    Default = 1,
    Callback = function(value)
        selectedName = value
    end
})

MainTab:AddButton({
    Title = "Áp dụng áo Catalan",
    Callback = function()
        if selectedName then
            setTarget(selectedName)
        else
            if Fluent and Fluent.Notify then
                Fluent:Notify({ Title = "Lỗi", Content = "Bạn chưa chọn người chơi", Duration = 3 })
            end
        end
    end
})

MainTab:AddToggle("ShirtToggle", {
    Title = "Bật/Tắt Áo Catalan",
    Default = true,
    Callback = function(value)
        toggledOn = value
        if currentTargetName then
            local targetPlayer = Players:FindFirstChild(currentTargetName)
            if targetPlayer and targetPlayer.Character then
                if toggledOn then
                    applyShirt(targetPlayer.Character)
                else
                    removeShirt(targetPlayer.Character)
                end
            end
        end
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "Trạng thái", Content = toggledOn and "Đã bật" or "Đã tắt", Duration = 2 })
        end
    end
})

-- =========================================================
-- ============ FEATURE 2: BEANBAG RED TROLL ===============
-- =========================================================
MainTab:AddSection("BeanBag Red")

local BEANBAG_TP_CFRAME = CFrame.new(-45.22, -96.33, 3118.56)
local BEANBAG_CHECK_DURATION = 4
local BEANBAG_ARRIVE_TIMEOUT = 2
local BEANBAG_ARRIVE_RADIUS = 5
local BEANBAG_EXTRA_SETTLE = 1.5
local BEANBAG_PRE_TP_DELAY = 0.1

local bbSelectedName = nil
local bbSeatConnection = nil
local currentBeanbagTool = nil
local scriptRemovingTool = false
local beanbagEnabled = false
local followToggleValue = false

local activeTricks = {}
local teleportLock = {}

local platformPart = nil
local function createPlatform()
    if platformPart and platformPart.Parent then
        return
    end
    platformPart = Instance.new("Part")
    platformPart.Size = Vector3.new(50, 2, 50)
    platformPart.Position = BEANBAG_TP_CFRAME.Position - Vector3.new(0, 2.5, 0)
    platformPart.Anchored = true
    platformPart.CanCollide = true
    platformPart.BrickColor = BrickColor.new("Medium stone grey")
    platformPart.Transparency = 0.3
    platformPart.Parent = workspace
end
createPlatform()

local followConnection = nil
local isFollowing = false

local function stopFollow()
    isFollowing = false
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
end

local function startFollow(targetName)
    stopFollow()
    local targetPlayer = Players:FindFirstChild(targetName)
    if not targetPlayer then
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "Lỗi", Content = "Không tìm thấy người chơi: " .. targetName, Duration = 3 })
        end
        return
    end

    isFollowing = true  
    followConnection = RunService.Heartbeat:Connect(function()  
        if not isFollowing then return end  

        local myChar = player.Character  
        local targetChar = targetPlayer.Character  
        if not myChar or not targetChar then return end  

        local myHRP = myChar:FindFirstChild("HumanoidRootPart")  
        local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")  
        if myHRP and targetHRP then  
            myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 3)
            local humanoid = myChar:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 50
            end
        end  
    end)
end

local function findSeatInTool(tool)
    local visual = tool:FindFirstChild("Visual")
    if not visual then return nil end
    local propSeat = visual:FindFirstChild("PropSeat")
    if not propSeat then return nil end
    if propSeat:IsA("Seat") or propSeat:IsA("VehicleSeat") then
        return propSeat
    end
    return propSeat:FindFirstChildWhichIsA("Seat", true)
        or propSeat:FindFirstChildWhichIsA("VehicleSeat", true)
end

local function holdPosition(character, targetCFrame)
    if not character or not targetCFrame then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    for _, child in ipairs(hrp:GetChildren()) do
        if child:IsA("BodyPosition") or child:IsA("BodyGyro") or child:IsA("BodyVelocity") then
            child:Destroy()
        end
    end
    
    local bodyPosition = Instance.new("BodyPosition")
    bodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
    bodyPosition.P = 2000
    bodyPosition.D = 500
    bodyPosition.Position = targetCFrame.Position
    bodyPosition.Parent = hrp
    
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(4000, 4000, 4000)
    bodyGyro.P = 2000
    bodyGyro.D = 500
    bodyGyro.CFrame = targetCFrame
    bodyGyro.Parent = hrp
    
    task.delay(2, function()
        if bodyPosition and bodyPosition.Parent then
            bodyPosition:Destroy()
        end
        if bodyGyro and bodyGyro.Parent then
            bodyGyro:Destroy()
        end
    end)
    
    return bodyPosition, bodyGyro
end

local function playBeanbagTrick(targetCharacter, seat, equippedTool)
    if teleportLock[targetCharacter] then
        return
    end
    
    local hrp = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local state = { cancelled = false }  
    activeTricks[targetCharacter] = state  
    teleportLock[targetCharacter] = true

    task.wait(BEANBAG_PRE_TP_DELAY)  
    if state.cancelled then 
        teleportLock[targetCharacter] = nil
        return 
    end  

    local targetPos = BEANBAG_TP_CFRAME.Position + Vector3.new(0, 1.5, 0)
    local targetCFrame = CFrame.new(targetPos)
    
    local function forceTeleport(char)
        local hrpNow = char:FindFirstChild("HumanoidRootPart")
        if not hrpNow then return false end
        
        hrpNow.CFrame = targetCFrame
        hrpNow.Velocity = Vector3.new(0, 0, 0)
        hrpNow.RotVelocity = Vector3.new(0, 0, 0)
        
        task.wait(0.1)
        if (hrpNow.Position - targetPos).Magnitude > 2 then
            hrpNow.CFrame = targetCFrame
            hrpNow.Velocity = Vector3.new(0, 0, 0)
            hrpNow.RotVelocity = Vector3.new(0, 0, 0)
        end
        
        holdPosition(char, targetCFrame)
        return true
    end
    
    forceTeleport(targetCharacter)
    
    local arriveElapsed = 0  
    while arriveElapsed < BEANBAG_ARRIVE_TIMEOUT and not state.cancelled do  
        local hrpNow = targetCharacter:FindFirstChild("HumanoidRootPart")  
        if hrpNow then
            local dist = (hrpNow.Position - targetPos).Magnitude
            if dist <= BEANBAG_ARRIVE_RADIUS then  
                break  
            end  
            if dist > BEANBAG_ARRIVE_RADIUS * 1.5 then
                forceTeleport(targetCharacter)
            end
        end  
        task.wait(0.1)  
        arriveElapsed += 0.1  
    end  
    
    if state.cancelled then 
        teleportLock[targetCharacter] = nil
        return 
    end  

    task.wait(BEANBAG_EXTRA_SETTLE)  
    if state.cancelled then 
        teleportLock[targetCharacter] = nil
        return 
    end  

    local waitCount = 0
    repeat
        task.wait(0.1)
        waitCount = waitCount + 1
        if state.cancelled then 
            teleportLock[targetCharacter] = nil
            return 
        end
        if waitCount > 50 then
            break
        end
    until seat.Occupant == nil or (seat.Occupant and seat.Occupant.Parent == targetCharacter)

    if state.cancelled then 
        teleportLock[targetCharacter] = nil
        return 
    end

    if equippedTool and equippedTool.Parent == player.Character then
        scriptRemovingTool = true
        equippedTool.Parent = player.Backpack
        task.defer(function()
            scriptRemovingTool = false
        end)
    end

    local elapsed = 0  
    local checkInterval = 0.1
    
    while elapsed < BEANBAG_CHECK_DURATION and not state.cancelled do  
        local occ = seat.Occupant  
        local occChar = occ and occ.Parent  
        if occChar ~= targetCharacter then  
            break  
        end  
        
        local hrpNow = targetCharacter:FindFirstChild("HumanoidRootPart")
        if hrpNow then
            local dist = (hrpNow.Position - targetPos).Magnitude
            if dist > BEANBAG_ARRIVE_RADIUS then
                hrpNow.CFrame = targetCFrame
                hrpNow.Velocity = Vector3.new(0, 0, 0)
                holdPosition(targetCharacter, targetCFrame)
            end
        end
        
        task.wait(checkInterval)  
        elapsed += checkInterval  
    end  

    teleportLock[targetCharacter] = nil
    activeTricks[targetCharacter] = nil
end

local function watchSeat(seat, tool)
    if bbSeatConnection then
        bbSeatConnection:Disconnect()
    end
    bbSeatConnection = seat:GetPropertyChangedSignal("Occupant"):Connect(function()
        if not beanbagEnabled then return end
        local occupant = seat.Occupant
        if occupant then
            local occupantChar = occupant.Parent
            local occupantPlayer = Players:GetPlayerFromCharacter(occupantChar)
            if occupantPlayer and bbSelectedName and occupantPlayer.Name == bbSelectedName then
                stopFollow()
                task.spawn(playBeanbagTrick, occupantChar, seat, tool)
            end
        end
    end)
end

local function onBeanbagEquipped(tool)
    currentBeanbagTool = tool
    if not beanbagEnabled then
        beanbagEnabled = true
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "BeanBag", Content = "Đã tự động bật vì có tool", Duration = 2 })
        end
    end
    if not bbSelectedName then return end
    local seat = findSeatInTool(tool)
    if seat then
        watchSeat(seat, tool)
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "BeanBag Red", Content = "Đang theo dõi ghế cho " .. bbSelectedName, Duration = 3 })
        end
    end
end

local function onBeanbagUnequipped()
    if bbSeatConnection then
        bbSeatConnection:Disconnect()
        bbSeatConnection = nil
    end
    currentBeanbagTool = nil
    if beanbagEnabled then
        beanbagEnabled = false
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "BeanBag", Content = "Đã tắt vì không cầm tool", Duration = 2 })
        end
    end

    if not scriptRemovingTool then  
        for _, state in pairs(activeTricks) do  
            state.cancelled = true  
        end  
        for char, _ in pairs(teleportLock) do
            teleportLock[char] = nil
        end
    end
end

local function hookCharacter(character)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name == "BeanBag Red" then
            onBeanbagEquipped(child)
            if followToggleValue and bbSelectedName then
                startFollow(bbSelectedName)
            end
        end
    end)
    character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child.Name == "BeanBag Red" then
            onBeanbagUnequipped()
        end
    end)
end

if player.Character then
    hookCharacter(player.Character)
end
player.CharacterAdded:Connect(hookCharacter)

local BeanbagDropdown = MainTab:AddDropdown("BeanbagPlayerDropdown", {
    Title = "Người chơi",
    Values = getPlayerNames(),
    Multi = false,
    Default = 1,
    Callback = function(value)
        bbSelectedName = value
        if player.Character then
            local tool = player.Character:FindFirstChild("BeanBag Red")
            if tool then
                onBeanbagEquipped(tool)
            end
        end
        if followToggleValue and value then
            startFollow(value)
        end
    end
})

local followToggle = MainTab:AddToggle("FollowToggle", {
    Title = "Bật/Tắt Bám Theo",
    Default = false,
    Callback = function(value)
        followToggleValue = value
        if value then
            if bbSelectedName then
                startFollow(bbSelectedName)
                if Fluent and Fluent.Notify then
                    Fluent:Notify({ Title = "Bám theo", Content = "Đang bám theo " .. bbSelectedName, Duration = 3 })
                end
            else
                if Fluent and Fluent.Notify then
                    Fluent:Notify({ Title = "Lỗi", Content = "Bạn chưa chọn người chơi", Duration = 3 })
                end
            end
        else
            stopFollow()
            if Fluent and Fluent.Notify then
                Fluent:Notify({ Title = "Bám theo", Content = "Đã tắt", Duration = 2 })
            end
        end
    end
})

MainTab:AddButton({
    Title = "Làm mới danh sách",
    Callback = function()
        Dropdown:SetValues(getPlayerNames())
        BeanbagDropdown:SetValues(getPlayerNames())
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "Làm mới", Content = "Đã cập nhật danh sách người chơi", Duration = 2 })
        end
    end
})

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    Dropdown:SetValues(getPlayerNames())
    BeanbagDropdown:SetValues(getPlayerNames())
end)

Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    Dropdown:SetValues(getPlayerNames())
    BeanbagDropdown:SetValues(getPlayerNames())
end)

-- =========================================================
-- ============ FEATURE 3: DARK SIGN - NHÁY BẢNG ===========
-- =========================================================
MainTab:AddSection("Dark Sign")

local function getUpdateSignRemote(tool)
    if not tool then return nil end
    local remote = tool:FindFirstChild("UpdateSign")
    if remote and remote:IsA("RemoteEvent") then
        return remote
    end
    for _, child in ipairs(tool:GetDescendants()) do
        if child:IsA("RemoteEvent") and child.Name == "UpdateSign" then
            return child
        end
    end
    return nil
end

local function findDarkSignTool()
    local character = player.Character
    if character then
        local tool = character:FindFirstChild("Dark Sign")
        if tool then return tool end
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild("Dark Sign")
        if tool then return tool end
    end
    return nil
end

local signQueue = {}
local isProcessingQueue = false
local SIGN_SEND_INTERVAL = 0.3

local function sendSignUpdate(text)
    local tool = findDarkSignTool()
    if not tool then return false end
    
    local remote = getUpdateSignRemote(tool)
    if not remote then return false end
    
    remote:FireServer(text)
    return true
end

local function processSignQueue()
    if isProcessingQueue or #signQueue == 0 then return end
    
    isProcessingQueue = true
    
    local function sendNext()
        if #signQueue == 0 then
            isProcessingQueue = false
            return
        end
        
        local text = table.remove(signQueue, 1)
        local success = sendSignUpdate(text)
        
        if not success then
            task.wait(0.5)
            table.insert(signQueue, 1, text)
        end
        
        task.wait(SIGN_SEND_INTERVAL)
        sendNext()
    end
    
    task.spawn(sendNext)
end

local function queueSignUpdate(text)
    if text and text ~= "" then
        table.insert(signQueue, text)
        processSignQueue()
    end
end

local SIGN_TEXT_URL = "https://raw.githubusercontent.com/teddyz7384/teddyzhandsomee-/refs/heads/main/ngon.txt"
local signLines = {}
local signCycling = false
local signCurrentIndex = 0

local function loadSignLines()
    local ok, content = pcall(function()
        return game:HttpGet(SIGN_TEXT_URL)
    end)

    if not ok or not content or content == "" then
        signLines = {
            "Ae snow no1 vina rp",
        }
        return true
    end

    signLines = {}
    for line in content:gmatch("[^\r\n]+") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if line ~= "" then
            table.insert(signLines, line)
        end
    end

    return #signLines > 0
end

local signCycleTask = nil

local function startSignCycling()
    if signCycling then return end

    if #signLines == 0 then
        if not loadSignLines() then
            if Fluent and Fluent.Notify then
                Fluent:Notify({ Title = "Dark Sign", Content = "Không có dữ liệu để hiển thị", Duration = 3 })
            end
            return
        end
    end

    local tool = findDarkSignTool()
    if not tool then
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "Dark Sign", Content = "Không tìm thấy Sign trong Backpack/tay", Duration = 3 })
        end
        return
    end

    signCycling = true
    signCurrentIndex = 1
    
    queueSignUpdate(signLines[signCurrentIndex])
    
    if Fluent and Fluent.Notify then
        Fluent:Notify({ Title = "Dark Sign", Content = "Đã bật nháy bảng", Duration = 2 })
    end

    if signCycleTask then
        task.cancel(signCycleTask)
        signCycleTask = nil
    end

    signCycleTask = task.spawn(function()
        while signCycling do
            task.wait(SIGN_SEND_INTERVAL * 0.5)
            if not signCycling then break end
            if #signLines == 0 then break end

            signCurrentIndex = (signCurrentIndex % #signLines) + 1
            queueSignUpdate(signLines[signCurrentIndex])
        end
    end)
end

local function stopSignCycling()
    signCycling = false
    if signCycleTask then
        task.cancel(signCycleTask)
        signCycleTask = nil
    end
    signQueue = {}
    isProcessingQueue = false
end

MainTab:AddToggle("SignBlinkToggle", {
    Title = "Bật/Tắt Nháy Bảng",
    Default = false,
    Callback = function(value)
        if value then
            startSignCycling()
        else
            stopSignCycling()
            if Fluent and Fluent.Notify then
                Fluent:Notify({ Title = "Dark Sign", Content = "Đã tắt nháy bảng", Duration = 2 })
            end
        end
    end
})

MainTab:AddButton({
    Title = "Reset Queue",
    Callback = function()
        signQueue = {}
        isProcessingQueue = false
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "Dark Sign", Content = "Đã reset queue", Duration = 2 })
        end
    end
})

-- =========================================================
-- ============ FEATURE 4: BIG RED SIGN PLACER =============
-- =========================================================
SignTab:AddSection("Big Red Sign Placer")

local signTextInput = SignTab:AddInput("SignTextInput", {
    Title = "Nội dung Sign",
    Default = "Ae snow no1 vina rp",
    Placeholder = "Nhập text cho sign...",
    Callback = function(value)
        _G.SignText = value
    end
})

_G.SignText = "Ae snow no1 vina rp"

local signPlacerEnabled = false
local signPlacerTask = nil
local placeRadius = 10

-- =========================================================
-- ====== TÌM REMOTEEVENT TRONG TOOLPROPSERVICE ===========
-- =========================================================
local function findToolPropService()
    -- Tìm Knit.Services
    local knit = game:GetService("ReplicatedStorage"):FindFirstChild("Knit")
    if not knit then
        -- Thử tìm trong Workspace
        knit = workspace:FindFirstChild("Knit")
    end
    if not knit then
        -- Thử tìm trong Player
        knit = player:FindFirstChild("Knit")
    end
    if not knit then
        return nil
    end
    
    local services = knit:FindFirstChild("Services")
    if not services then
        return nil
    end
    
    local toolPropService = services:FindFirstChild("ToolPropService")
    return toolPropService
end

-- Hàm tìm RemoteEvent từ ToolPropService
local function findRemoteFromToolPropService(remoteName)
    local toolPropService = findToolPropService()
    if not toolPropService then
        return nil
    end
    
    -- Tìm RemoteEvent theo tên
    local remote = toolPropService:FindFirstChild(remoteName)
    if remote and remote:IsA("RemoteEvent") then
        return remote
    end
    
    -- Tìm trong tất cả children
    for _, child in ipairs(toolPropService:GetChildren()) do
        if child:IsA("RemoteEvent") and child.Name == remoteName then
            return child
        end
    end
    
    return nil
end

-- Hàm tìm tất cả RemoteEvent trong ToolPropService
local function findAllRemotesInToolPropService()
    local toolPropService = findToolPropService()
    if not toolPropService then
        return {}
    end
    
    local remotes = {}
    for _, child in ipairs(toolPropService:GetChildren()) do
        if child:IsA("RemoteEvent") then
            table.insert(remotes, {
                Name = child.Name,
                Object = child
            })
        end
    end
    return remotes
end

-- Hàm tìm remote tốt nhất cho việc đặt sign
local function findBestRemoteForPlace()
    local remotes = findAllRemotesInToolPropService()
    
    -- Danh sách ưu tiên
    local priorityNames = {
        "PlaceToolVisual", "Place", "Deploy", "Spawn", "Create",
        "AddToBackpack", "EquipTool", "PlaceSign"
    }
    
    for _, priorityName in ipairs(priorityNames) do
        for _, remote in ipairs(remotes) do
            if remote.Name:lower():find(priorityName:lower()) then
                return remote.Object
            end
        end
    end
    
    -- Nếu không tìm thấy, trả về remote đầu tiên
    if #remotes > 0 then
        return remotes[1].Object
    end
    
    return nil
end

-- =========================================================
-- ====== TÌM TOOL BIG RED SIGN ============================
-- =========================================================
local function findBigRedSignTool()
    local character = player.Character
    if character then
        local tool = character:FindFirstChild("Big Red Sign")
        if tool then return tool end
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild("Big Red Sign")
        if tool then return tool end
    end
    return nil
end

-- =========================================================
-- ====== TẠO VỊ TRÍ NGẪU NHIÊN ===========================
-- =========================================================
local function getRandomPlacePosition()
    local character = player.Character
    if not character then return nil end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local pos = hrp.Position
    local angle = math.random() * 2 * math.pi
    local distance = math.random() * placeRadius
    
    if distance < 2 then distance = 2 end
    
    local newPos = pos + Vector3.new(
        math.cos(angle) * distance,
        0,
        math.sin(angle) * distance
    )
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character}
    
    local rayOrigin = newPos + Vector3.new(0, 10, 0)
    local rayDirection = Vector3.new(0, -20, 0)
    local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    if rayResult then
        newPos = rayResult.Position + Vector3.new(0, 0.5, 0)
    end
    
    return newPos
end

-- =========================================================
-- ====== ĐẶT SIGN ========================================
-- =========================================================
local function placeBigRedSign()
    -- Tìm tool
    local tool = findBigRedSignTool()
    if not tool then
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "Lỗi", Content = "Không tìm thấy Big Red Sign", Duration = 2 })
        end
        return false
    end
    
    -- Tìm remote từ ToolPropService
    local remote = findBestRemoteForPlace()
    if not remote then
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "Lỗi", Content = "Không tìm thấy RemoteEvent", Duration = 2 })
        end
        return false
    end
    
    -- Lấy vị trí
    local pos = getRandomPlacePosition()
    if not pos then
        return false
    end
    
    -- Gửi remote với nhiều cách khác nhau
    local success = false
    local text = _G.SignText or "Ae snow no1 vina rp"
    
    -- Cách 1: Gửi với vị trí và text
    success, err = pcall(function()
        remote:FireServer(pos, text)
    end)
    
    if not success then
        -- Cách 2: Gửi với vị trí
        success, err = pcall(function()
            remote:FireServer(pos)
        end)
    end
    
    if not success then
        -- Cách 3: Gửi với text
        success, err = pcall(function()
            remote:FireServer(text)
        end)
    end
    
    if not success then
        -- Cách 4: Gửi trống
        success, err = pcall(function()
            remote:FireServer()
        end)
    end
    
    return success
end

-- =========================================================
-- ====== BẬT/TẮT ĐẶT SIGN LIÊN TỤC =======================
-- =========================================================
local function startSignPlacer()
    if signPlacerEnabled then return end
    
    local tool = findBigRedSignTool()
    if not tool then
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "Lỗi", Content = "Không tìm thấy Big Red Sign", Duration = 3 })
        end
        return
    end
    
    signPlacerEnabled = true
    
    -- Đưa tool lên tay nếu đang ở Backpack
    if tool.Parent == player:FindFirstChild("Backpack") then
        local character = player.Character
        if character then
            tool.Parent = character
        end
    end
    
    if Fluent and Fluent.Notify then
        Fluent:Notify({ Title = "Big Red Sign", Content = "Đang đặt sign liên tục...", Duration = 2 })
    end
    
    signPlacerTask = task.spawn(function()
        local placeCount = 0
        while signPlacerEnabled do
            local success = placeBigRedSign()
            if success then
                placeCount = placeCount + 1
                if placeCount % 5 == 0 then
                    if Fluent and Fluent.Notify then
                        Fluent:Notify({ Title = "Big Red Sign", Content = "Đã đặt " .. placeCount .. " sign", Duration = 1 })
                    end
                end
            end
            task.wait(0.2)
        end
    end)
end

local function stopSignPlacer()
    signPlacerEnabled = false
    if signPlacerTask then
        task.cancel(signPlacerTask)
        signPlacerTask = nil
    end
    if Fluent and Fluent.Notify then
        Fluent:Notify({ Title = "Big Red Sign", Content = "Đã dừng đặt sign", Duration = 2 })
    end
end

-- =========================================================
-- ====== UI TRONG TAB SIGN ================================
-- =========================================================
-- Toggle đặt sign
SignTab:AddToggle("SignPlacerToggle", {
    Title = "Bật/Tắt Đặt Sign Liên Tục",
    Default = false,
    Callback = function(value)
        if value then
            startSignPlacer()
        else
            stopSignPlacer()
        end
    end
})

-- Điều chỉnh bán kính
SignTab:AddSlider("RadiusSlider", {
    Title = "Bán kính đặt",
    Description = "Khoảng cách đặt sign xung quanh nhân vật",
    Default = 10,
    Min = 3,
    Max = 25,
    Rounding = 1,
    Callback = function(value)
        placeRadius = value
    end
})

-- Nút đặt 1 lần
SignTab:AddButton({
    Title = "Đặt 1 Sign",
    Callback = function()
        placeBigRedSign()
    end
})

-- Nút tìm RemoteEvent trong ToolPropService
SignTab:AddButton({
    Title = "🔍 Tìm RemoteEvent",
    Callback = function()
        local remotes = findAllRemotesInToolPropService()
        if #remotes > 0 then
            local msg = "Tìm thấy " .. #remotes .. " RemoteEvent:\n"
            for i, remote in ipairs(remotes) do
                msg = msg .. i .. ". " .. remote.Name .. "\n"
            end
            if Fluent and Fluent.Notify then
                Fluent:Notify({ Title = "RemoteEvent", Content = msg, Duration = 5 })
            end
            print(msg)
        else
            if Fluent and Fluent.Notify then
                Fluent:Notify({ Title = "Lỗi", Content = "Không tìm thấy RemoteEvent nào!", Duration = 3 })
            end
        end
    end
})

-- Nút tìm Remote tốt nhất
SignTab:AddButton({
    Title = "🎯 Tìm Remote Tốt Nhất",
    Callback = function()
        local bestRemote = findBestRemoteForPlace()
        if bestRemote then
            if Fluent and Fluent.Notify then
                Fluent:Notify({ Title = "🎯 Tìm thấy", Content = "Remote tốt nhất: " .. bestRemote.Name, Duration = 4 })
            end
            print("=== Big Red Sign Remote Info ===")
            print("Best Remote: " .. bestRemote.Name)
            print("Path: " .. bestRemote:GetFullName())
            print("Parent: " .. (bestRemote.Parent and bestRemote.Parent.Name or "Unknown"))
            print("==================================")
        else
            if Fluent and Fluent.Notify then
                Fluent:Notify({ Title = "Lỗi", Content = "Không tìm thấy RemoteEvent nào!", Duration = 3 })
            end
        end
    end
})

-- Nút làm sạch sign
SignTab:AddButton({
    Title = "Làm sạch Sign đã đặt",
    Callback = function()
        local count = 0
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Part") and (obj.Name:find("Sign") or obj.Name:find("sign")) then
                local ownerLabel = obj:FindFirstChild("OwnerLabel")
                if ownerLabel and ownerLabel:IsA("SurfaceGui") then
                    local textLabel = ownerLabel:FindFirstChild("TextLabel")
                    if textLabel and textLabel:IsA("TextLabel") then
                        local parent = obj.Parent
                        if parent then
                            parent:Destroy()
                            count = count + 1
                        end
                    end
                end
            end
        end
        
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "Big Red Sign", Content = "Đã xóa " .. count .. " sign", Duration = 3 })
        end
    end
})

-- =========================================================
-- ============ NOTIFICATION ===============================
-- =========================================================
if Fluent and Fluent.Notify then
    Fluent:Notify({
        Title = "Thành Phố Vina RP ❄️",
        Content = "Đã tải xong",
        Duration = 4
    })
end
