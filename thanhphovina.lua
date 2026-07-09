-- LocalScript trong StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local player = Players.LocalPlayer

local SHIRT_ID = 3204384330
local connections = {}
local toggledOn = true
local currentTargetName = nil

-- ====== Load Fluent UI ======
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

-- ====== Tạo Window ======
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

-- ====== Danh sách người chơi ======
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
-- ============ FEATURE 2: PROPSEAT TROLL ==================
-- =========================================================
MainTab:AddSection("PropSeat Troll")

local TROLL_CFRAME = CFrame.new(-45.22, -96.33, 3118.56)
local CHECK_DURATION = 4
local ARRIVE_TIMEOUT = 2
local ARRIVE_RADIUS = 5
local EXTRA_SETTLE = 1.5
local PRE_TP_DELAY = 0.1

local selectedTarget = nil
local seatConnection = nil
local currentTool = nil
local scriptRemovingTool = false
local trollEnabled = false
local followToggleValue = false

local activeTricks = {}
local teleportLock = {}

-- Tạo bệ đỡ
local platformPart = nil
local function createPlatform()
    if platformPart and platformPart.Parent then return end
    platformPart = Instance.new("Part")
    platformPart.Size = Vector3.new(50, 2, 50)
    platformPart.Position = TROLL_CFRAME.Position - Vector3.new(0, 2.5, 0)
    platformPart.Anchored = true
    platformPart.CanCollide = true
    platformPart.BrickColor = BrickColor.new("Medium stone grey")
    platformPart.Transparency = 0.3
    platformPart.Parent = workspace
end
createPlatform()

-- Follow
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

-- Tìm ghế trong tool (bất kỳ tool nào có Visual.PropSeat)
local function findSeatInTool(tool)
    local visual = tool:FindFirstChild("Visual")
    if not visual then return nil end
    local propSeat = visual:FindFirstChild("PropSeat")
    if not propSeat then return nil end
    if propSeat:IsA("Seat") or propSeat:IsA("VehicleSeat") then
        return propSeat
    end
    return propSeat:FindFirstChildWhichIsA("Seat", true) or propSeat:FindFirstChildWhichIsA("VehicleSeat", true)
end

-- Hàm giữ vị trí mạnh mẽ
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
    bodyPosition.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyPosition.P = 20000
    bodyPosition.D = 1000
    bodyPosition.Position = targetCFrame.Position
    bodyPosition.Parent = hrp

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.P = 20000
    bodyGyro.D = 1000
    bodyGyro.CFrame = targetCFrame
    bodyGyro.Parent = hrp

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp

    task.delay(10, function()
        if bodyPosition and bodyPosition.Parent then bodyPosition:Destroy() end
        if bodyGyro and bodyGyro.Parent then bodyGyro:Destroy() end
        if bodyVelocity and bodyVelocity.Parent then bodyVelocity:Destroy() end
    end)

    return bodyPosition, bodyGyro, bodyVelocity
end

-- Hàm chính kéo người đến vị trí troll
local function performTroll(targetCharacter, seat, tool)
    if teleportLock[targetCharacter] then return end
    local hrp = targetCharacter:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local state = { cancelled = false }
    activeTricks[targetCharacter] = state
    teleportLock[targetCharacter] = true

    task.wait(PRE_TP_DELAY)
    if state.cancelled then
        teleportLock[targetCharacter] = nil
        return
    end

    local targetPos = TROLL_CFRAME.Position + Vector3.new(0, 1.5, 0)
    local targetCFrame = CFrame.new(targetPos)

    local function forceTeleport(char)
        local hrpNow = char:FindFirstChild("HumanoidRootPart")
        if not hrpNow then return false end
        hrpNow.CFrame = targetCFrame
        hrpNow.Velocity = Vector3.new(0, 0, 0)
        hrpNow.RotVelocity = Vector3.new(0, 0, 0)
        holdPosition(char, targetCFrame)
        return true
    end

    forceTeleport(targetCharacter)

    local arriveElapsed = 0
    while arriveElapsed < ARRIVE_TIMEOUT and not state.cancelled do
        local hrpNow = targetCharacter:FindFirstChild("HumanoidRootPart")
        if hrpNow then
            local dist = (hrpNow.Position - targetPos).Magnitude
            if dist <= ARRIVE_RADIUS then break end
            if dist > ARRIVE_RADIUS * 1.2 then
                forceTeleport(targetCharacter)
            end
        end
        task.wait(0.05)
        arriveElapsed = arriveElapsed + 0.05
    end

    if state.cancelled then
        teleportLock[targetCharacter] = nil
        return
    end

    task.wait(EXTRA_SETTLE)
    if state.cancelled then
        teleportLock[targetCharacter] = nil
        return
    end

    -- Đợi người ngồi vào ghế
    local waitCount = 0
    repeat
        task.wait(0.1)
        waitCount = waitCount + 1
        if state.cancelled then
            teleportLock[targetCharacter] = nil
            return
        end
        if waitCount > 50 then break end
    until seat.Occupant and seat.Occupant.Parent == targetCharacter

    if not seat.Occupant or seat.Occupant.Parent ~= targetCharacter then
        teleportLock[targetCharacter] = nil
        return
    end

    -- Xóa tool khỏi tay
    if tool and tool.Parent == player.Character then
        scriptRemovingTool = true
        tool.Parent = player.Backpack
        task.defer(function() scriptRemovingTool = false end)
    end

    -- Giữ chặt
    local elapsed = 0
    local checkInterval = 0.1
    while elapsed < CHECK_DURATION and not state.cancelled do
        local occ = seat.Occupant
        if not occ or occ.Parent ~= targetCharacter then
            break
        end

        local hrpNow = targetCharacter:FindFirstChild("HumanoidRootPart")
        if hrpNow then
            local dist = (hrpNow.Position - targetPos).Magnitude
            if dist > ARRIVE_RADIUS then
                forceTeleport(targetCharacter)
            end
        end

        task.wait(checkInterval)
        elapsed = elapsed + checkInterval
    end

    teleportLock[targetCharacter] = nil
    activeTricks[targetCharacter] = nil
end

-- Lắng nghe ghế
local function watchSeat(seat, tool)
    if seatConnection then
        seatConnection:Disconnect()
    end
    seatConnection = seat:GetPropertyChangedSignal("Occupant"):Connect(function()
        if not trollEnabled then return end
        local occupant = seat.Occupant
        if occupant then
            local occupantChar = occupant.Parent
            local occupantPlayer = Players:GetPlayerFromCharacter(occupantChar)
            if occupantPlayer and selectedTarget and occupantPlayer.Name == selectedTarget then
                stopFollow()
                task.spawn(performTroll, occupantChar, seat, tool)
            end
        end
    end)
end

-- Trang bị tool
local function onToolEquipped(tool)
    currentTool = tool
    if not trollEnabled then
        trollEnabled = true
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "PropSeat", Content = "Đã tự động bật vì có tool", Duration = 2 })
        end
    end
    if not selectedTarget then return end
    local seat = findSeatInTool(tool)
    if seat then
        watchSeat(seat, tool)
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "PropSeat Troll", Content = "Đang theo dõi ghế cho " .. selectedTarget, Duration = 3 })
        end
    end
end

-- Bỏ tool
local function onToolUnequipped()
    if seatConnection then
        seatConnection:Disconnect()
        seatConnection = nil
    end
    currentTool = nil
    if trollEnabled then
        trollEnabled = false
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "PropSeat", Content = "Đã tắt vì không cầm tool", Duration = 2 })
        end
    end
    if not scriptRemovingTool then
        for _, state in pairs(activeTricks) do
            state.cancelled = true
        end
        teleportLock = {}
    end
end

-- Hook nhân vật
local function hookCharacter(character)
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child:FindFirstChild("Visual") and child.Visual:FindFirstChild("PropSeat") then
            onToolEquipped(child)
            if followToggleValue and selectedTarget then
                startFollow(selectedTarget)
            end
        end
    end)
    character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") and child:FindFirstChild("Visual") and child.Visual:FindFirstChild("PropSeat") then
            onToolUnequipped()
        end
    end)
end

if player.Character then
    hookCharacter(player.Character)
end
player.CharacterAdded:Connect(hookCharacter)

-- Dropdown chọn người chơi
local PropSeatDropdown = MainTab:AddDropdown("PropSeatPlayerDropdown", {
    Title = "Người chơi",
    Values = getPlayerNames(),
    Multi = false,
    Default = 1,
    Callback = function(value)
        selectedTarget = value
        if player.Character then
            for _, tool in ipairs(player.Character:GetChildren()) do
                if tool:IsA("Tool") and tool:FindFirstChild("Visual") and tool.Visual:FindFirstChild("PropSeat") then
                    onToolEquipped(tool)
                    break
                end
            end
        end
        if followToggleValue and value then
            startFollow(value)
        end
    end
})

-- Follow toggle
local followToggle = MainTab:AddToggle("FollowToggle", {
    Title = "Bật/Tắt Bám Theo",
    Default = false,
    Callback = function(value)
        followToggleValue = value
        if value then
            if selectedTarget then
                startFollow(selectedTarget)
                if Fluent and Fluent.Notify then
                    Fluent:Notify({ Title = "Bám theo", Content = "Đang bám theo " .. selectedTarget, Duration = 3 })
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

-- Nút làm mới danh sách
MainTab:AddButton({
    Title = "Làm mới danh sách",
    Callback = function()
        local names = getPlayerNames()
        Dropdown:SetValues(names)
        PropSeatDropdown:SetValues(names)
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "Làm mới", Content = "Đã cập nhật danh sách người chơi", Duration = 2 })
        end
    end
})

Players.PlayerAdded:Connect(function()
    task.wait(0.5)
    local names = getPlayerNames()
    Dropdown:SetValues(names)
    PropSeatDropdown:SetValues(names)
end)
Players.PlayerRemoving:Connect(function()
    task.wait(0.5)
    local names = getPlayerNames()
    Dropdown:SetValues(names)
    PropSeatDropdown:SetValues(names)
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
local SIGN_TEXT_URL = "https://raw.githubusercontent.com/teddyz7384/teddyzhandsomee-/refs/heads/main/ngon2.txt"
local signLines = {}
local signCycling = false
local signCurrentIndex = 0
local function loadSignLines()
    local ok, content = pcall(function()
        return game:HttpGet(SIGN_TEXT_URL)
    end)
    if not ok or not content or content == "" then
        signLines = { "Ae snow no1 vina rp" }
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
 
-- ====== TEXTBOX OWNER / TARGET (dùng để thay {owner} / {target} trong ngon.txt) ======
local signOwnerName = ""
local signTargetName = ""
 
-- FIX: trên mobile, callback của textbox đôi khi trả về nil/không phải string
-- (ví dụ lúc bàn phím ảo chưa gõ xong hoặc bị xoá trắng) -> luôn ép về string
-- để signOwnerName/signTargetName không bao giờ bị nil.
local function sanitizeInputValue(value)
    if type(value) == "string" then
        return value
    end
    return ""
end
 
local ownerInput = SignTab:AddInput("SignOwnerInput", {
    Title = "Tên Owner",
    Default = "",
    Placeholder = "Nhập tên owner...",
    Finished = false, -- callback/Value cập nhật liên tục lúc gõ, không cần bấm Enter
    Callback = function(value)
        signOwnerName = sanitizeInputValue(value)
        _G.SignOwnerName = signOwnerName
    end
})
 
local targetInput = SignTab:AddInput("SignTargetInput", {
    Title = "Tên Mục Tiêu",
    Default = "",
    Placeholder = "Nhập tên Mục Tiêu...",
    Finished = false,
    Callback = function(value)
        signTargetName = sanitizeInputValue(value)
        _G.SignTargetName = signTargetName
    end
})
 
-- FIX GỐC (mobile): Callback đôi khi KHÔNG bắn khi gõ xong rồi bấm ra ngoài trên bàn phím ảo
-- (bug mất focus phổ biến ở nhiều thư viện UI, không riêng Fluent).
-- Lần trước mình đoán nhầm cấu trúc "Fluent.Options[idx]" nên không có tác dụng.
-- Đúng ra theo tài liệu Fluent, chính object trả về từ AddInput (ownerInput/targetInput ở trên)
-- có sẵn thuộc tính .Value luôn phản ánh đúng nội dung đang hiển thị trên ô nhập -> đọc thẳng
-- từ đó, không cần đoán mò gì thêm.
local function readLiveInputValue(inputObject, fallback)
    if inputObject and type(inputObject.Value) == "string" then
        return inputObject.Value
    end
    return fallback -- không đọc được thì dùng giá trị Callback lưu gần nhất
end
 
-- Lớp dự phòng thứ 2: OnChanged (Fluent hỗ trợ song song với Callback) để đồng bộ
-- biến local mỗi khi giá trị đổi, phòng trường hợp Callback không bắn.
if ownerInput and ownerInput.OnChanged then
    pcall(function()
        ownerInput:OnChanged(function()
            signOwnerName = sanitizeInputValue(ownerInput.Value)
            _G.SignOwnerName = signOwnerName
        end)
    end)
end
 
if targetInput and targetInput.OnChanged then
    pcall(function()
        targetInput:OnChanged(function()
            signTargetName = sanitizeInputValue(targetInput.Value)
            _G.SignTargetName = signTargetName
        end)
    end)
end
 
-- Escape ký tự % để dùng an toàn trong gsub (tránh lỗi nếu tên có ký tự đặc biệt)
local function escapeGsubReplacement(str)
    if type(str) ~= "string" then return "" end
    return (str:gsub("%%", "%%%%"))
end
 
-- Thay {owner} / {target} trong text bằng nội dung đang có trong textbox (đọc trực tiếp,
-- không chỉ dựa vào Callback). Nếu textbox đang trống thì giữ nguyên {owner}/{target}
-- để dễ nhận biết chưa điền.
local function applySignTemplate(text)
    if not text then return text end
    local ownerRaw = readLiveInputValue(ownerInput, signOwnerName)
    local targetRaw = readLiveInputValue(targetInput, signTargetName)
    local ownerVal = (type(ownerRaw) == "string" and ownerRaw ~= "") and ownerRaw or "{owner}"
    local targetVal = (type(targetRaw) == "string" and targetRaw ~= "") and targetRaw or "{target}"
    text = text:gsub("{owner}", escapeGsubReplacement(ownerVal))
    text = text:gsub("{target}", escapeGsubReplacement(targetVal))
    return text
end

local signPlacerEnabled = false
local signPlacerTask = nil
local signCycleTask = nil
local signLines = {}
local signCycling = false
local signIndex = 0
local signPlaceCount = 0
local signBlinkEnabled = false
local signBlinkTask = nil

-- Lưu chỉ số dòng (trong ngon.txt) riêng cho TỪNG bảng, để mỗi bảng hiện chữ khác nhau
-- (weak table: nếu sign bị xoá khỏi workspace thì tự động dọn khỏi bộ nhớ)
local signIndexBySign = setmetatable({}, { __mode = "k" })

local SIGN_BLINK_INTERVAL = 0.5     -- giây giữa mỗi lần đổi chữ
local SIGN_LIST_REFRESH_INTERVAL = 5 -- giây giữa mỗi lần quét lại workspace tìm sign (đỡ lag)
local SIGN_UPDATE_STAGGER = 0.05    -- giây chờ giữa mỗi lệnh gọi remote, tránh bắn hết cùng lúc gây lag

-- ====== TẢI FILE NGON.TXT ======
local function loadSignLines()
    local ok, content = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/teddyz7384/teddyzhandsomee-/refs/heads/main/ngon.txt")
    end)
    if not ok or not content or content == "" then
        signLines = { "Ae snow no1 vina rp" }
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
loadSignLines()

-- ====== TÌM REMOTE ======
local function findToolPropService()
    local rs = game:GetService("ReplicatedStorage")
    for _, child in ipairs(rs:GetChildren()) do
        if child.Name == "ToolPropService" then
            return child
        end
    end
    for _, obj in ipairs(game:GetDescendants()) do
        if obj.Name == "ToolPropService" then
            return obj
        end
    end
    return nil
end

local function getRemote(remoteName)
    local toolPropService = findToolPropService()
    if not toolPropService then return nil end
    local rfFolder = toolPropService:FindFirstChild("RF")
    if rfFolder then
        for _, child in ipairs(rfFolder:GetChildren()) do
            if child.Name == remoteName and child:IsA("RemoteFunction") then
                return child
            end
        end
    end
    return nil
end

local function getUpdateSignFunction()
    return getRemote("UpdateSign")
end

-- ====== TÌM TOOL ======
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

-- ====== ĐẾM SIGN ======
local function countPlayerSigns()
    local count = 0
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name == "Big Red Sign" or obj.Name == "PloppableSign") then
            for _, child in ipairs(obj:GetChildren()) do
                if child.Name == "SignPart" then
                    count = count + 1
                    break
                end
            end
        end
    end
    return count
end

-- ====== TÌM TẤT CẢ SIGN CỦA PLAYER ======
local function getAllPlayerSigns()
    local signs = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name == "Big Red Sign" or obj.Name == "PloppableSign") then
            local owner = obj:GetAttribute("Owner")
            if owner == player.UserId then
                table.insert(signs, obj)
            end
        end
    end
    return signs
end

-- ====== UPDATE TEXT ======
local function updateSignText(signModel, text)
    if not signModel then return false end
    local updateRemote = getUpdateSignFunction()
    if updateRemote then
        local success = pcall(function()
            updateRemote:InvokeServer(text, signModel)
        end)
        if success then return true end
    end
    return false
end

-- ====== UPDATE TẤT CẢ SIGN BẰNG NỘI DUNG TỪ TEXTBOX INPUT ======
-- (khác với nút "từ ngon.txt": cái này lấy đúng 1 câu ở ô nhập "Nội dung Sign",
--  áp dụng {owner}/{target} rồi gửi cho MỌI sign của bạn)
local function updateAllSignsWithInput()
    local signs = getAllPlayerSigns()
    if #signs == 0 then
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "Lỗi", Content = "Bạn không có sign nào!", Duration = 2 })
        end
        return
    end

    local text = applySignTemplate(_G.SignText or "Ae snow no1 vina rp")

    local count = 0
    for _, sign in ipairs(signs) do
        if updateSignText(sign, text) then
            count = count + 1
        end
        task.wait(0.2)
    end

    if Fluent and Fluent.Notify then
        Fluent:Notify({ Title = "Update Text", Content = "Đã update " .. count .. "/" .. #signs .. " sign", Duration = 3 })
    end
end

-- ====== ĐẶT SIGN ======
local function placeBigRedSign()
    local tool = findBigRedSignTool()
    if not tool then return false end
    
    if not tool:GetAttribute("Class") then
        tool:SetAttribute("Class", "PloppableSign")
    end
    
    local char = player.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local pos = hrp.Position
    local angle = math.random() * 2 * math.pi
    local distance = math.random() * 10
    local newPos = pos + Vector3.new(math.cos(angle) * distance, 0, math.sin(angle) * distance)
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {char}
    raycastParams.CollisionGroup = "ToolPropRaycast"
    
    local rayOrigin = newPos + Vector3.new(0, 10, 0)
    local rayDirection = Vector3.new(0, -20, 0)
    local rayResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    local hitPos, hitNormal, hitInstance
    if rayResult then
        hitPos = rayResult.Position + Vector3.new(0, 0.5, 0)
        hitNormal = rayResult.Normal
        hitInstance = rayResult.Instance
    else
        hitPos = newPos
        hitNormal = Vector3.new(0, 1, 0)
        hitInstance = nil
    end
    
    local placeRemote = getRemote("PlaceToolVisual")
    if not placeRemote then return false end
    
    local camera = workspace.CurrentCamera
    local lookVector = camera and camera.CFrame.LookVector or Vector3.new(0, 0, -1)
    local upVector = camera and camera.CFrame.UpVector or Vector3.new(0, 1, 0)
    local _, yaw, _ = CFrame.lookAt(Vector3.new(), lookVector, upVector):ToOrientation()
    local orientation = CFrame.Angles(0, yaw, 0)
    
    local zRot = tool:GetAttribute("Z_Rotation") or 0
    if zRot ~= 0 then
        orientation = orientation * CFrame.Angles(0, 0, math.rad(zRot))
    end
    
    local placeData = {
        hit = hitInstance,
        position = hitPos,
        normal = hitNormal,
        orientation = orientation
    }
    
    local oldSigns = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name == "Big Red Sign" or obj.Name == "PloppableSign") then
            for _, child in ipairs(obj:GetChildren()) do
                if child.Name == "SignPart" then
                    table.insert(oldSigns, obj)
                    break
                end
            end
        end
    end
    
    local success, result = pcall(function()
        return placeRemote:InvokeServer(tool.Name, "Place", placeData)
    end)
    
    if success then
        task.wait(1.5)
        local newSign = nil
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and (obj.Name == "Big Red Sign" or obj.Name == "PloppableSign") then
                local hasSignPart = false
                for _, child in ipairs(obj:GetChildren()) do
                    if child.Name == "SignPart" then
                        hasSignPart = true
                        break
                    end
                end
                if hasSignPart then
                    local isOld = false
                    for _, old in ipairs(oldSigns) do
                        if old == obj then
                            isOld = true
                            break
                        end
                    end
                    if not isOld then
                        newSign = obj
                        break
                    end
                end
            end
        end
        
        if newSign then
            -- Lấy text tiếp theo từ danh sách (mỗi sign mới đặt cũng có chỉ số riêng)
            local text
            if signCycling and #signLines > 0 then
                signIndex = (signIndex % #signLines) + 1
                signIndexBySign[newSign] = signIndex
                text = signLines[signIndex]
            else
                text = _G.SignText or "Ae snow no1 vina rp"
            end
            text = applySignTemplate(text)
            updateSignText(newSign, text)
            signPlaceCount = signPlaceCount + 1
            return true
        end
    end
    return false
end

-- ====== NHÁY BẢNG (FIX: đỡ lag + mỗi bảng hiện chữ khác nhau) ======
local function startSignBlink()
    if signBlinkEnabled then return end
    if #signLines == 0 then
        if not loadSignLines() then return end
    end
    signBlinkEnabled = true
    if signBlinkTask then
        task.cancel(signBlinkTask)
        signBlinkTask = nil
    end

    local cachedSigns = {}
    local lastRefresh = 0

    signBlinkTask = task.spawn(function()
        while signBlinkEnabled do
            -- FIX LAG: không quét lại toàn bộ workspace mỗi 0.5s, chỉ quét lại mỗi
            -- SIGN_LIST_REFRESH_INTERVAL giây (hoặc lần đầu tiên)
            local now = os.clock()
            if now - lastRefresh >= SIGN_LIST_REFRESH_INTERVAL or #cachedSigns == 0 then
                cachedSigns = getAllPlayerSigns()
                lastRefresh = now
            end

            if #signLines > 0 and #cachedSigns > 0 then
                for i, sign in ipairs(cachedSigns) do
                    if not signBlinkEnabled then break end
                    if sign and sign.Parent then
                        -- FIX: mỗi bảng có chỉ số dòng RIÊNG, lệch nhau theo vị trí trong danh sách
                        -- => bảng 1 hiện dòng khác bảng 2, không còn hiện trùng 1 câu nữa
                        local idx = signIndexBySign[sign]
                        if not idx then
                            idx = (i - 1) % #signLines -- lệch vị trí ban đầu giữa các bảng
                        end
                        idx = (idx % #signLines) + 1
                        signIndexBySign[sign] = idx

                        local text = applySignTemplate(signLines[idx])

                        -- FIX LAG: gọi remote KHÔNG chặn vòng lặp chính (chạy song song),
                        -- và giãn cách nhẹ giữa các lệnh để tránh bắn quá nhiều request cùng 1 frame
                        task.spawn(function()
                            updateSignText(sign, text)
                        end)
                        task.wait(SIGN_UPDATE_STAGGER)
                    end
                end
            end

            task.wait(SIGN_BLINK_INTERVAL)
        end
    end)
end

local function stopSignBlink()
    signBlinkEnabled = false
    if signBlinkTask then
        task.cancel(signBlinkTask)
        signBlinkTask = nil
    end
end

-- ====== BẬT/TẮT ĐẶT SIGN LIÊN TỤC ======
local function startSignPlacer()
    if signPlacerEnabled then return end
    local tool = findBigRedSignTool()
    if not tool then
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "Lỗi", Content = "Không tìm thấy Big Red Sign. Vui lòng lấy tool trước khi bật.", Duration = 3 })
        end
        return
    end
    signPlacerEnabled = true
    if tool.Parent == player:FindFirstChild("Backpack") then
        local character = player.Character
        if character then
            tool.Parent = character
        end
    end
    if Fluent and Fluent.Notify then
        Fluent:Notify({ Title = "Big Red Sign", Content = "Đang đặt sign liên tục...", Duration = 2 })
    end
    local function waitForTool()
        local timeout = 60
        local elapsed = 0
        while signPlacerEnabled do
            local tool = findBigRedSignTool()
            if tool then
                if tool.Parent == player:FindFirstChild("Backpack") then
                    local char = player.Character
                    if char then
                        tool.Parent = char
                    end
                end
                return true
            end
            task.wait(1)
            elapsed = elapsed + 1
            if elapsed > timeout then
                return false
            end
        end
        return false
    end
    signPlacerTask = task.spawn(function()
        local placeCount = 0
        while signPlacerEnabled do
            local tool = findBigRedSignTool()
            if not tool then
                local found = waitForTool()
                if not found then
                    stopSignPlacer()
                    break
                end
            end
            local success = placeBigRedSign()
            if success then
                placeCount = placeCount + 1
                if placeCount % 5 == 0 then
                    if Fluent and Fluent.Notify then
                        Fluent:Notify({ Title = "Big Red Sign", Content = "Đã đặt " .. placeCount .. " sign", Duration = 1 })
                    end
                end
            end
            task.wait(0.5)
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

SignTab:AddToggle("SignBlinkToggle", {
    Title = "💀 Bật/Tắt Nhây Đặt Sign",
    Default = false,
    Callback = function(value)
        if value then
            startSignBlink()
        else
            stopSignBlink()
        end
    end
})

SignTab:AddButton({
    Title = "Đặt 1 Sign",
    Callback = function()
        placeBigRedSign()
    end
})

SignTab:AddButton({
    Title = "📊 Tìm sign của tôi",
    Callback = function()
        local signs = getAllPlayerSigns()
        local count = #signs
        if count > 0 then
            if Fluent and Fluent.Notify then
                Fluent:Notify({ Title = "Sign", Content = "Bạn có " .. count .. " sign", Duration = 3 })
            end
        else
            if Fluent and Fluent.Notify then
                Fluent:Notify({ Title = "Sign", Content = "Bạn không có sign nào!", Duration = 3 })
            end
        end
    end
})

-- Nút update tất cả sign với nội dung từ input
SignTab:AddButton({
    Title = "🔄 Update Text cho tất cả Sign",
    Callback = function()
        updateAllSignsWithInput()
    end
})

SignTab:AddButton({
    Title = "🔄 Làm Lại Ngôn Chửi",
    Callback = function()
        loadSignLines()
        if Fluent and Fluent.Notify then
            Fluent:Notify({ Title = "Reload", Content = "Đã tải lại ngon.txt (" .. #signLines .. " dòng)", Duration = 2 })
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
        Duration = 3
    })
end
