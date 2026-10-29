-- [[ Script: Live Items (Búsqueda Avanzada de Armas) - BlockSpin ]]
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("LiveItemsGui") then
    PlayerGui.LiveItemsGui:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LiveItemsGui"
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 460)
MainFrame.Position = UDim2.new(0.65, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Text = "⚡ LIVE ITEMS - BlockSpin ⚡"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextScaled = true
Title.Parent = MainFrame

-- Filtros de rareza
local FilterFrame = Instance.new("Frame")
FilterFrame.Size = UDim2.new(1, -10, 0, 35)
FilterFrame.Position = UDim2.new(0, 5, 0, 45)
FilterFrame.BackgroundTransparency = 1
FilterFrame.Parent = MainFrame

local UICols = Instance.new("UIListLayout")
UICols.FillDirection = Enum.FillDirection.Horizontal
UICols.HorizontalAlignment = Enum.HorizontalAlignment.Center
UICols.Padding = UDim.new(0, 4)
UICols.Parent = FilterFrame

local currentFilter = "ALL"

local function createFilterButton(text, filterType, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 72, 1, 0)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.TextScaled = true
    btn.Parent = FilterFrame
    
    btn.MouseButton1Click:Connect(function()
        currentFilter = filterType
    end)
    return btn
end

createFilterButton("Todas", "ALL", Color3.fromRGB(60, 60, 60))
createFilterButton("Omega", "OMEGA", Color3.fromRGB(150, 0, 200))
createFilterButton("Legs", "LEGENDARY", Color3.fromRGB(218, 165, 32))
createFilterButton("Epic", "EPIC", Color3.fromRGB(0, 120, 255))

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, -10, 1, -130)
ScrollingFrame.Position = UDim2.new(0, 5, 0, 85)
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = ScrollingFrame

local function RefreshPlayerList()
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end

    local totalHeight = 0

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local playerName = player.Name
            local equippedWeapon = "Sin arma"
            local rarity = "NORMAL"
            local isMatch = false

            -- BÚSQUEDA PROFUNDA DE ARMAS (Revisa Personaje y Mochila/Backpack)
            local function checkItem(item)
                local nameLower = string.lower(item.Name)
                -- Ignorar partes del cuerpo comunes de Roblox
                if nameLower ~= "humanoidrootpart" and nameLower ~= "head" and nameLower ~= "torso" and nameLower ~= "uppertorso" and nameLower ~= "lowertorso" then
                    equippedWeapon = item.Name
                    if string.find(nameLower, "omega") then
                        rarity = "OMEGA"
                    elseif string.find(nameLower, "legendary") or string.find(nameLower, "mythic") then
                        rarity = "LEGENDARY"
                    elseif string.find(nameLower, "epic") then
                        rarity = "EPIC"
                    else
                        rarity = "OTHER"
                    end
                end
            end

            -- 1. Buscar en el personaje actual
            if player.Character then
                for _, item in ipairs(player.Character:GetChildren()) do
                    if item:IsA("Tool") or item:IsA("Model") then
                        checkItem(item)
                    end
                end
            end

            -- 2. Si no encontró nada, buscar en la mochila (Backpack) del jugador
            if equippedWeapon == "Sin arma" and player:FindFirstChild("Backpack") then
                for _, item in ipairs(player.Backpack:GetChildren()) do
                    if item:IsA("Tool") then
                        checkItem(item)
                        break
                    end
                end
            end

            -- Filtrar según los botones seleccionados
            if currentFilter == "ALL" or currentFilter == rarity or (currentFilter == "LEGENDARY" and rarity == "LEGENDARY") then
                isMatch = true
            elseif currentFilter == "OTHER" and rarity == "OTHER" then
                isMatch = true
            end

            if isMatch then
                local cardColor = Color3.fromRGB(45, 45, 45)
                local textColor = Color3.fromRGB(255, 255, 255)
                local btnColor = Color3.fromRGB(70, 130, 180)

                if rarity == "OMEGA" then
                    cardColor = Color3.fromRGB(60, 20, 80)
                    textColor = Color3.fromRGB(220, 100, 255)
                    btnColor = Color3.fromRGB(150, 0, 200)
                elseif rarity == "LEGENDARY" then
                    cardColor = Color3.fromRGB(80, 60, 20)
                    textColor = Color3.fromRGB(255, 215, 0)
                    btnColor = Color3.fromRGB(255, 170, 0)
                elseif rarity == "EPIC" then
                    cardColor = Color3.fromRGB(20, 50, 80)
                    textColor = Color3.fromRGB(100, 180, 255)
                    btnColor = Color3.fromRGB(0, 120, 255)
                end

                local PlayerCard = Instance.new("Frame")
                PlayerCard.Size = UDim2.new(1, -10, 0, 55)
                PlayerCard.BackgroundColor3 = cardColor
                PlayerCard.BorderSizePixel = 0
                PlayerCard.Parent = ScrollingFrame

                if rarity ~= "NORMAL" and rarity ~= "OTHER" then
                    local UIStroke = Instance.new("UIStroke")
                    UIStroke.Color = textColor
                    UIStroke.Thickness = 2
                    UIStroke.Parent = PlayerCard
                end

                local InfoLabel = Instance.new("TextLabel")
                InfoLabel.Size = UDim2.new(0.62, 0, 1, 0)
                InfoLabel.Position = UDim2.new(0, 5, 0, 0)
                InfoLabel.BackgroundTransparency = 1
                InfoLabel.Text = "👤 " .. playerName .. "\n⚔️ " .. equippedWeapon
                InfoLabel.TextColor3 = textColor
                InfoLabel.TextSize = 12
                InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
                InfoLabel.Parent = PlayerCard

                local JoinButton = Instance.new("TextButton")
                JoinButton.Size = UDim2.new(0.34, 0, 0.7, 0)
                JoinButton.Position = UDim2.new(0.64, 0, 0.15, 0)
                JoinButton.BackgroundColor3 = btnColor
                JoinButton.Text = "¡UNIRME!"
                JoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
                JoinButton.TextScaled = true
                JoinButton.Parent = PlayerCard

                JoinButton.MouseButton1Click:Connect(function()
                    JoinButton.Text = "Conectando..."
                    pcall(function()
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) 
                    end)
                end)

                totalHeight = totalHeight + 60
            end
        end
    end

    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

for _, child in ipairs(FilterFrame:GetChildren()) do
    if child:IsA("TextButton") then
        child.MouseButton1Click:Connect(RefreshPlayerList)
    end
end

local RefreshButton = Instance.new("TextButton")
RefreshButton.Size = UDim2.new(1, -10, 0, 35)
RefreshButton.Position = UDim2.new(0, 5, 1, -40)
RefreshButton.BackgroundColor3 = Color3.fromRGB(46, 139, 87)
RefreshButton.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshButton.Text = "🔄 Actualizar Lista"
RefreshButton.TextScaled = true
RefreshButton.Parent = MainFrame

RefreshButton.MouseButton1Click:Connect(RefreshPlayerList)

RefreshPlayerList()
print("⚡ Live Items Actualizado con Detección Profunda ⚡")
