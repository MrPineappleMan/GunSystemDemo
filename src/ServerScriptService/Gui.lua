-- This places all Guis from StarterGui to ReplicatedStorage/StarterGui

for _, gui in pairs(game.StarterGui:GetChildren()) do
    gui.Parent = game.ReplicatedStorage.StarterGui
end