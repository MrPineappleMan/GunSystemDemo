local Knit = require(game:GetService("ReplicatedStorage").Knit)

local Players = game:GetService("Players")

--
local Client = Players.LocalPlayer
local ClientGui = Client.PlayerGui

local crosshair_holder = ClientGui.GunUI
local firing_icon = crosshair_holder.FiringImage
local running_icon = crosshair_holder.RunningImage

local UIController = script:FindFirstAncestor("UIController")

local Components = UIController.Components
local FadeAnimation = require(Components.FadeAnimation)

local leaderstats = Client:WaitForChild("leaderstats")
local total_count = leaderstats:WaitForChild("TotalCash")

local Crosshair = {}

local fadeAnimations = {}

function Crosshair:Load(amount)

end

function Crosshair:UnLoad()
    for _, fadeAnim in pairs(fadeAnimations) do
        fadeAnim:FadeOut()
    end
end

function Crosshair:Init()
    local function addToFade(image: ImageButton, time: number)
        fadeAnimations[image] = FadeAnimation.new(image, time)
    end

    addToFade(cheque_holder, 0.5)

    for _, fadeAnim in pairs(fadeAnimations) do
        fadeAnim:UnLoadNow()
    end

    ClientGui.Cheque.Enabled = true
end

return Crosshair