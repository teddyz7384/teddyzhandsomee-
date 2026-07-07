-- LocalScript trong StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local SHIRT_ID = 3204384330
local connections = {}
local toggledOn = true
local currentTargetName = nil

-- ====== Load Fluent UI ======
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Thành Phố Vina RP ❄️",
    SubTitle = "made by snow family",
    TabWidth = 130,
    Size = UDim2.fromOffset(460, 440),
    Acrylic = true,
    Theme = "Dark"
})

local MainTab = Window:AddTab({ Title = "Main", Icon = "shirt" })
Window:SelectTab(1)

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
        Fluent:Notify({ Title = "Lỗi", Content = "Không tìm thấy người chơi: " .. name, Duration = 3 })  
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

    Fluent:Notify({ Title = "Thành công", Content = "Đã áp dụng áo cho " .. name, Duration = 3 })
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
            Fluent:Notify({ Title = "Lỗi", Content = "Bạn chưa chọn người chơi", Duration = 3 })
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
        Fluent:Notify({ Title = "Trạng thái", Content = toggledOn and "Đã bật" or "Đã tắt", Duration = 2 })
    end
})

-- =========================================================
-- ============ FEATURE 2: BEANBAG RED TROLL ===============
-- =========================================================
MainTab:AddSection("BeanBag Red")

local BEANBAG_TP_CFRAME = CFrame.new(-45.22, -96.33, 3118.56)
local BEANBAG_CHECK_DURATION = 4
local BEANBAG_ARRIVE_TIMEOUT = 3
local BEANBAG_ARRIVE_RADIUS = 5
local BEANBAG_EXTRA_SETTLE = 1.5
local BEANBAG_PRE_TP_DELAY = 0.1

local bbSelectedName = nil
local bbSeatConnection = nil
local currentBeanbagTool = nil
local scriptRemovingTool = false
local beanbagEnabled = false

local activeTricks = {}

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
        Fluent:Notify({ Title = "Lỗi", Content = "Không tìm thấy người chơi: " .. targetName, Duration = 3 })
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

local function playBeanbagTrick(targetCharacter, seat, equippedTool)
    local hrp = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local state = { cancelled = false }  
    activeTricks[targetCharacter] = state  

    task.wait(BEANBAG_PRE_TP_DELAY)  
    if state.cancelled then return end  

    local targetPos = BEANBAG_TP_CFRAME.Position + Vector3.new(0, 1.5, 0)
    local targetCFrame = CFrame.new(targetPos)  
    local currentHrp = targetCharacter:FindFirstChild("HumanoidRootPart")  
    if currentHrp then  
        currentHrp.CFrame = targetCFrame  
    end  

    local arriveElapsed = 0  
    while arriveElapsed < BEANBAG_ARRIVE_TIMEOUT and not state.cancelled do  
        local hrpNow = targetCharacter:FindFirstChild("HumanoidRootPart")  
        if hrpNow and (hrpNow.Position - targetPos).Magnitude <= BEANBAG_ARRIVE_RADIUS then  
            break  
        end  
        local dt = task.wait()  
        arriveElapsed += dt  
    end  
    if state.cancelled then return end  

    task.wait(BEANBAG_EXTRA_SETTLE)  
    if state.cancelled then return end  

    repeat
        task.wait()
    until seat.Occupant == nil or (seat.Occupant and seat.Occupant.Parent == targetCharacter) or state.cancelled

    if state.cancelled then return end

    if equippedTool and equippedTool.Parent == player.Character then
        scriptRemovingTool = true
        equippedTool.Parent = player.Backpack
        task.defer(function()
            scriptRemovingTool = false
        end)
    end

    local elapsed = 0  
    while elapsed < BEANBAG_CHECK_DURATION and not state.cancelled do  
        local occ = seat.Occupant  
        local occChar = occ and occ.Parent  
        if occChar ~= targetCharacter then  
            break  
        end  
        local dt = task.wait()  
        elapsed += dt  
    end  

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
        Fluent:Notify({ Title = "BeanBag", Content = "Đã tự động bật vì có tool", Duration = 2 })
    end
    if not bbSelectedName then return end
    local seat = findSeatInTool(tool)
    if seat then
        watchSeat(seat, tool)
        Fluent:Notify({ Title = "BeanBag Red", Content = "Đang theo dõi ghế cho " .. bbSelectedName, Duration = 3 })
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
        Fluent:Notify({ Title = "BeanBag", Content = "Đã tắt vì không cầm tool", Duration = 2 })
    end

    if not scriptRemovingTool then  
        for _, state in pairs(activeTricks) do  
            state.cancelled = true  
        end  
    end
end

local function hookCharacter(character)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name == "BeanBag Red" then
            onBeanbagEquipped(child)
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
    end
})

MainTab:AddToggle("FollowToggle", {
    Title = "Bật/Tắt Bám Theo",
    Default = false,
    Callback = function(value)
        if value then
            if bbSelectedName then
                startFollow(bbSelectedName)
                Fluent:Notify({ Title = "Bám theo", Content = "Đang bám theo " .. bbSelectedName, Duration = 3 })
            else
                Fluent:Notify({ Title = "Lỗi", Content = "Bạn chưa chọn người chơi", Duration = 3 })
            end
        else
            stopFollow()
            Fluent:Notify({ Title = "Bám theo", Content = "Đã tắt", Duration = 2 })
        end
    end
})

MainTab:AddButton({
    Title = "Làm mới danh sách",
    Callback = function()
        Dropdown:SetValues(getPlayerNames())
        BeanbagDropdown:SetValues(getPlayerNames())
        Fluent:Notify({ Title = "Làm mới", Content = "Đã cập nhật danh sách người chơi", Duration = 2 })
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

-- Tìm RemoteEvent UpdateSign trong tool
local function getUpdateSignRemote(tool)
    if not tool then return nil end
    -- Tìm trong tool trước
    local remote = tool:FindFirstChild("UpdateSign")
    if remote and remote:IsA("RemoteEvent") then
        return remote
    end
    -- Tìm trong các con của tool
    for _, child in ipairs(tool:GetDescendants()) do
        if child:IsA("RemoteEvent") and child.Name == "UpdateSign" then
            return child
        end
    end
    return nil
end

-- Lấy tool Dark Sign
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

-- Gửi yêu cầu update bảng qua RemoteEvent
local function updateSignViaRemote(text)
    local tool = findDarkSignTool()
    if not tool then
        Fluent:Notify({ Title = "Dark Sign", Content = "Không tìm thấy Dark Sign trong Backpack/tay", Duration = 3 })
        return false
    end
    
    local remote = getUpdateSignRemote(tool)
    if not remote then
        Fluent:Notify({ Title = "Dark Sign", Content = "Không tìm thấy RemoteEvent UpdateSign trong tool", Duration = 3 })
        return false
    end
    
    -- Gửi yêu cầu update bảng lên server
    remote:FireServer(text)
    return true
end

-- Đọc danh sách câu từ file (tùy chọn, vẫn giữ để có thể đọc từ file nếu muốn)
local SIGN_TEXT_URL = "https://raw.githubusercontent.com/teddyz7384/teddyzhandsomee-/refs/heads/main/ngon.txt"
local signLines = {}
local signCycling = false
local signCurrentIndex = 0

local function loadSignLines()
    local ok, content = pcall(function()
        return game:HttpGet(SIGN_TEXT_URL)
    end)

    if not ok or not content or content == "" then
        -- Nếu không tải được, dùng danh sách mặc định
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

-- Hàm chính để nháy bảng (gửi qua RemoteEvent)
local function startSignCycling()
    if signCycling then return end

    if #signLines == 0 then
        if not loadSignLines() then
            Fluent:Notify({ Title = "Dark Sign", Content = "Không có dữ liệu để hiển thị", Duration = 3 })
            return
        end
    end

    -- Kiểm tra tool và remote
    local tool = findDarkSignTool()
    if not tool then
        Fluent:Notify({ Title = "Dark Sign", Content = "Không tìm thấy Sign trong Backpack/tay", Duration = 3 })
        return
    end
    
    local remote = getUpdateSignRemote(tool)
    if not remote then
        Fluent:Notify({ Title = "Dark Sign", Content = "Không tìm thấy UpdateSign trong tool", Duration = 3 })
        return
    end

    signCycling = true
    signCurrentIndex = 1
    
    -- Gửi câu đầu tiên
    updateSignViaRemote(signLines[signCurrentIndex])
    
    Fluent:Notify({ Title = "Dark Sign", Content = "Đã bật nháy bảng", Duration = 2 })

    task.spawn(function()
        while signCycling do
            task.wait(0.06) -- Đã đổi từ 1s xuống 0.3s
            if not signCycling then break end
            if #signLines == 0 then break end

            signCurrentIndex = (signCurrentIndex % #signLines) + 1
            local success = updateSignViaRemote(signLines[signCurrentIndex])
            
            -- Nếu gửi thất bại, thử tìm lại tool và remote
            if not success then
                local toolRetry = findDarkSignTool()
                if toolRetry then
                    local remoteRetry = getUpdateSignRemote(toolRetry)
                    if remoteRetry then
                        remoteRetry:FireServer(signLines[signCurrentIndex])
                    end
                end
            end
        end
    end)
end

local function stopSignCycling()
    signCycling = false
end

MainTab:AddToggle("SignBlinkToggle", {
    Title = "Bật/Tắt Nháy Bảng",
    Default = false,
    Callback = function(value)
        if value then
            startSignCycling()
        else
            stopSignCycling()
            Fluent:Notify({ Title = "Dark Sign", Content = "Đã tắt nháy bảng", Duration = 2 })
        end
    end
})

Fluent:Notify({
    Title = "Thành Phố Vina RP ❄️",
    Content = "Đã tải xong",
    Duration = 4
})
