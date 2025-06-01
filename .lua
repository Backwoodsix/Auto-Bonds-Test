local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local workspaceService = cloneref(workspace)
local VAMPIRE_CASTLE_POS = Vector3.new(60, 5, -9000)
local MAX_RADIUS = 1000

if not workspaceService:FindFirstChild("Gayze") then
    local starterGui = cloneref(game:GetService("StarterGui"))
    starterGui:SetCore("SendNotification", { Title = "Auto bonds", Text = "By BIGBACK!", Duration = 5 })
    local newPart = Instance.new("Part")
    newPart.Name = "Gayze"
    newPart.Size = Vector3.new(0, 5, 0)
    newPart.Position = Vector3.new(5, 5, 5)
    newPart.Transparency = 1
    newPart.CanCollide = false
    newPart.Anchored = true
    newPart.Parent = workspaceService
end

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")
local hum = character:WaitForChild("Humanoid")
local lockedY = hrp.Position.Y

local function isUnanchored(model)
    for _, p in pairs(model:GetDescendants()) do
        if p:IsA("BasePart") and not p.Anchored then return true end
    end
    return false
end

local function isNearCastle(model)
    local primary = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not primary then return false end
    return (primary.Position - VAMPIRE_CASTLE_POS).Magnitude < MAX_RADIUS
end

local function findVCMaximGun()
    local searchParents = {}
    if workspace:FindFirstChild("VampireCastle") then
        table.insert(searchParents, workspace.VampireCastle)
        if workspace.VampireCastle:FindFirstChild("CastleLoot") then
            table.insert(searchParents, workspace.VampireCastle.CastleLoot)
        end
    end
    if workspace:FindFirstChild("RuntimeItems") then
        table.insert(searchParents, workspace.RuntimeItems)
    end
    for _, parent in ipairs(searchParents) do
        for _, obj in ipairs(parent:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():find("maximgun") and isUnanchored(obj) and isNearCastle(obj) then
                local seat = obj:FindFirstChildWhichIsA("Seat", true) or obj:FindFirstChildWhichIsA("VehicleSeat", true)
                if seat and not seat.Occupant then
                    return obj, seat
                end
            end
        end
    end
    return nil, nil
end

local function slowScanToCastle()
    local steps = 40
    for i = 1, steps do
        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(VAMPIRE_CASTLE_POS), 0.025)
        task.wait(0.3)
    end
    hrp.CFrame = CFrame.new(VAMPIRE_CASTLE_POS)
end

slowScanToCastle()

local foundMaximGun, seat = nil, nil
local lockedPos = hrp.CFrame
task.spawn(function()
    while not (foundMaximGun and seat) do
        hrp.CFrame = lockedPos
        foundMaximGun, seat = findVCMaximGun()
        task.wait(0.2)
    end
end)
repeat task.wait(0.1) until foundMaximGun and seat

local function forceSeatAndWeld()
    while true do
        if hum.SeatPart ~= seat or not hum.Sit then
            hrp.CFrame = seat.CFrame + Vector3.new(0, 4, 0)
            task.wait(0.1)
            seat:Sit(hum)
        end
        if not hrp:FindFirstChild("MaximGunWeld") then
            local weld = Instance.new("WeldConstraint")
            weld.Name = "MaximGunWeld"
            weld.Part0 = hrp
            weld.Part1 = seat
            weld.Parent = hrp
        end
        if hum.SeatPart then
            hrp.CFrame = hum.SeatPart.CFrame
            lockedY = hum.SeatPart.Position.Y
        else
            local pos = hrp.Position
            hrp.CFrame = CFrame.new(pos.X, lockedY, pos.Z)
        end
        task.wait(0.1)
    end
end

task.spawn(forceSeatAndWeld)

local bondGui = Instance.new("ScreenGui")
bondGui.Name = "BondUI"
bondGui.ResetOnSpawn = false
bondGui.Parent = cloneref(game:GetService("CoreGui"))
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.3, 0, 0.09, 0)
statusLabel.Position = UDim2.new(0.36, 0, 0.33, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextScaled = false
statusLabel.TextSize = 32
statusLabel.Font = Enum.Font.Fantasy
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextStrokeTransparency = 0.5
statusLabel.Text = "This script was cracked by BIGBACK. Please never make scripts again."
statusLabel.Parent = bondGui

local activateRemote = ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("RemotePromise"):WaitForChild("Remotes"):WaitForChild("C_ActivateObject")

local function findNearestBond()
    local closest, shortestDist = nil, math.huge
    local itemsFolder = workspace.RuntimeItems
    if not itemsFolder then return nil end
    for _, item in ipairs(itemsFolder:GetChildren()) do
        if item:IsA("Model") and item.Name:lower() == "bond" then
            local primary = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if primary then
                local dist = (primary.Position - hrp.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = item
                end
            end
        end
    end
    return closest
end

local bondCount = 0
local targetCount = 123

local function teleportTo(bond)
    local primary = bond.PrimaryPart or bond:FindFirstChildWhichIsA("BasePart")
    if not primary then return end
    hrp.CFrame = primary.CFrame + Vector3.new(0, 5, 0)
    local startTime = os.clock()
    while bond.Parent and os.clock() - startTime < 1 do
        activateRemote:FireServer(bond)
        task.wait(0.03)
    end
    if not bond.Parent then
        bondCount += 1
    end
end

while bondCount < targetCount do
    local bond = findNearestBond()
    if bond then
        teleportTo(bond)
    else
        break
    end
    task.wait(0.01)
end

local layerSize = 2048
local halfSize = layerSize / 2
local xStart = -halfSize
local xEnd = halfSize
local y = -50
local zStart = 30000
local zEnd = -49872
local zStep = -layerSize
local z = zStart
local direction = 1

while bondCount < targetCount and ((zStep < 0 and z >= zEnd) or (zStep > 0 and z <= zEnd)) do
    local x1 = (direction == 1) and xStart or xEnd
    local x2 = (direction == 1) and xEnd or xStart
    hrp.CFrame = CFrame.new(x1, y, z)
    task.wait(0.1)
    local bond = findNearestBond()
    while bond and bondCount < targetCount do
        teleportTo(bond)
        bond = findNearestBond()
    end
    hrp.CFrame = CFrame.new(x2, y, z)
    task.wait(0.1)
    bond = findNearestBond()
    while bond and bondCount < targetCount do
        teleportTo(bond)
        bond = findNearestBond()
    end
    z += zStep
    direction *= -1
end

statusLabel.Text = "Total Bonds Collected: " .. tostring(bondCount) .. " | Cracked by BIGBACK"
statusLabel.TextSize = 24.5

task.wait(5.5)
TeleportService:Teleport(116495829188952, LocalPlayer)

local creditGui = Instance.new("ScreenGui")
creditGui.DisplayOrder = 9999
creditGui.Name = "NotificationGui"
creditGui.ResetOnSpawn = false
creditGui.IgnoreGuiInset = true
creditGui.Parent = PlayerGui
local background = Instance.new("Frame")
background.Size = UDim2.new(1, 0, 1, 0)
background.Position = UDim2.new(0, 0, 0, 0)
background.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
background.BackgroundTransparency = 0
background.ZIndex = 0
background.Parent = creditGui
local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.6, 0, 0.09, 0)
label.Position = UDim2.new(0.21, 0, 0.25, 0)
label.BackgroundTransparency = 1
label.TextColor3 = Color3.fromRGB(255, 255, 255)
label.Font = Enum.Font.GothamBold
label.TextScaled = true
label.Text = "Script Made by BIGBACK"
label.ZIndex = 1
label.Parent = creditGui

task.delay(800, function()
    creditGui:Destroy()
end)
