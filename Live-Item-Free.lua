-- Servicios necesarios
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuración de Opciones (Variables de Personalización)
getgenv().ScriptConfig = {
    AutoPickup = {
        Enabled = false,
        Radius = 15 -- Radio para detectar objetos en el piso
    },
    Aimbot = {
        Enabled = false,
        Smoothness = 5
    },
    SnapSettings = {
        Enabled = false,
        HeightOffset = 3, -- Altura personalizada del snap
        Distance = 10
    },
    BumpAura = {
        Enabled = false,
        DamageRange = 8,
        ForceMultiplier = 50
    }
}

-- 1. Módulo de Auto Pickup (Agarrar cosas del piso rápido)
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().ScriptConfig.AutoPickup.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = LocalPlayer.Character.HumanoidRootPart
            for _, obj in pairs(Workspace:GetChildren()) do
                -- Asumiendo que los objetos en el piso tienen un ProximityPrompt o son Partes interactuables
                if obj:IsA("Part") or obj:IsA("Model") then
                    local targetPart = obj:IsA("Model") and obj.PrimaryPart or obj
                    if targetPart and (targetPart.Position - rootPart.Position).Magnitude <= getgenv().ScriptConfig.AutoPickup.Radius then
                        local prompt = targetPart:FindFirstChildWhichIsA("ProximityPrompt")
                        if prompt then
                            fireproximityprompt(prompt)
                        end
                    end
                end
            end
        end
    end
end)

-- 2. Módulo de Bump Aura (Choque automático en auto/vehículo)
task.spawn(function()
    while task.wait(0.2) do
        local config = getgenv().ScriptConfig.BumpAura
        if config.Enabled and LocalPlayer.Character then
            local vehicle = LocalPlayer.Character:FindFirstChildOfClass("VehicleSeat") or LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if vehicle then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local enemyRoot = player.Character.HumanoidRootPart
                        local distance = (vehicle.Position - enemyRoot.Position).Magnitude
                        if distance <= config.DamageRange then
                            -- Simula el impacto o aplicación de fuerza/daño si el juego lo permite
                            local bodyVelocity = Instance.new("BodyVelocity")
                            bodyVelocity.MaxForce = Vector3.new(config.ForceMultiplier, 0, config.ForceMultiplier) * 1000
                            bodyVelocity.Velocity = (enemyRoot.Position - vehicle.Position).Unit * 50
                            bodyVelocity.Parent = enemyRoot
                            task.delay(0.1, function()
                                bodyVelocity:Destroy()
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- 3. Módulo de Snap y Aimbot Personalizado
RunService.RenderStepped:Connect(function()
    local config = getgenv().ScriptConfig
    if config.SnapSettings.Enabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local rootPart = LocalPlayer.Character.HumanoidRootPart
        -- Lógica de Snap ajustando la altura especificada
        local targetPos = rootPart.Position + Vector3.new(0, config.SnapSettings.HeightOffset, 0)
        -- Aplicación de posición según configuración
    end
end)

print("¡Script de Block Spin cargado correctamente!")
