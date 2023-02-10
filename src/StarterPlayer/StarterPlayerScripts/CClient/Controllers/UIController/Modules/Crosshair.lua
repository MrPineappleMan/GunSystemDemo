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

    addToFade(firing_icon, 0.2)
    addToFade(running_icon, 0.2)

    for _, fadeAnim in pairs(fadeAnimations) do
        fadeAnim:UnLoadNow()
    end
end

return Crosshair