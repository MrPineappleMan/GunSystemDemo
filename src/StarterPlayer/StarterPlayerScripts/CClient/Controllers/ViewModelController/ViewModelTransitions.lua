local Knit = require(game:GetService("ReplicatedStorage").Knit)
local GunStateEnums = require(Knit.Shared.Constants).GunStateEnums

local Transitions = {}

local function addTransition(startStateName, endStateName, animationName)
    local startState = GunStateEnums[startStateName]
    local endState = GunStateEnums[endStateName]

    table.insert(Transitions, {
        ["StartState"] = startState,
        ["EndState"] = endState,
        ["AnimationName"] = animationName
    })
end

function Transitions:GetTransitionInfo(startState, endState)
    for _, transitionInfo in ipairs(Transitions) do
        if transitionInfo.StartState == startState and transitionInfo.EndState == endState then
            return transitionInfo
        end
    end

    return nil
end

-- Aiming

addTransition(
    "HipReady",
    "AimReady",
    "Aim"
)

addTransition(
    "AimReady",
    "HipReady",
    "UnAim" -- edit 
)

-- Running

addTransition(
    "HipReady",
    "Running",
    "StandToRun"
)

addTransition(
    "Running",
    "HipReady",
    "RunningToStand"
)

-- From Nothing

addTransition(
    "Unavailible",
    "HipReady",
    "Equip"
)

return Transitions