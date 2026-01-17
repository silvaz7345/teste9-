-- MAGNET BLOCKS - Símbolo 卐 (blocos do mapa vem até você)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "MagnetSymbolGUI"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 160)
frame.Position = UDim2.new(0.05,0,0.3,0)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,35)
title.Text = "MAGNET SYMBOL 卐"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(45,45,45)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0.85,0,0,40)
btn.Position = UDim2.new(0.075,0,0.45,0)
btn.Text = "ATIVAR"
btn.Font = Enum.Font.Gotham
btn.TextSize = 14
btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
btn.TextColor3 = Color3.new(1,1,1)

-- CONFIG
local magnet = false

-- Função para pegar TODOS os blocos do mapa
local function getAllBlocks()
    local list = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(character) and v.Size.Magnitude < 50 then
            table.insert(list, v)
        end
    end
    return list
end

-- Offsets para formar o símbolo 卐
local offsets = {
    Vector3.new(0,5,0), Vector3.new(0,4,0), Vector3.new(0,3,0), Vector3.new(0,2,0), Vector3.new(0,1,0), -- coluna vertical
    Vector3.new(1,5,0), Vector3.new(2,5,0), Vector3.new(3,5,0), -- braço superior
    Vector3.new(1,3,0), Vector3.new(2,3,0), -- braço horizontal
    Vector3.new(3,2,0), Vector3.new(3,1,0), -- braço inferior
}

-- Posicionar bloco com física estável
local function controlBlock(block, targetPos)
    if not block or not block.Parent then return end
    pcall(function() block:SetNetworkOwner(player) end)

    block.CanCollide = false
    block.Massless = true
    block.AssemblyLinearVelocity = Vector3.zero
    block.AssemblyAngularVelocity = Vector3.zero

    local bp = block:FindFirstChild("BP")
    local bg = block:FindFirstChild("BG")

    if not bp then
        bp = Instance.new("BodyPosition")
        bp.Name = "BP"
        bp.MaxForce = Vector3.new(1e9,1e9,1e9)
        bp.P = 50000
        bp.D = 500
        bp.Position = targetPos
        bp.Parent = block
    else
        bp.Position = targetPos
    end

    if not bg then
        bg = Instance.new("BodyGyro")
        bg.Name = "BG"
        bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
        bg.P = 5000
        bg.CFrame = CFrame.new(block.Position)
        bg.Parent = block
    end
end

-- Loop principal
RunService.Heartbeat:Connect(function()
    if magnet then
        local list = getAllBlocks() -- pega TODOS os blocos do mapa
        for i, offset in ipairs(offsets) do
            local block = list[i] -- pega bloco da lista
            if block then
                local targetPos = hrp.Position + offset
                controlBlock(block, targetPos)
            end
        end
    end
end)

-- Botão ativar/desativar
btn.MouseButton1Click:Connect(function()
    magnet = not magnet
    btn.Text = magnet and "DESATIVAR" or "ATIVAR"

    if not magnet then
        local list = getAllBlocks()
        for _, part in ipairs(list) do
            if part and part.Parent then
                part.CanCollide = true
                if part:FindFirstChild("BP") then part.BP:Destroy() end
                if part:FindFirstChild("BG") then part.BG:Destroy() end
            end
        end
    end
end)
