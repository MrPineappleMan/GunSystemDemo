local Knit = require(game:GetService("ReplicatedStorage").Knit)

local Constants = require(Knit.Shared.Constants)
local GunStateEnums = Constants.GunStateEnums

return {
    [Enum.UserInputType.MouseButton1] = {
        ["ValidInputStates"] = {
            GunStateEnums.AimFiring, 
            GunStateEnums.HipFiring
        },

        ["TargetState"] = function(gunObject, currentState)
            if currentState == GunStateEnums.HipFiring then
                return GunStateEnums.HipReady
            else
                return GunStateEnums.AimReady
            end
        end
    },

    [Enum.UserInputType.MouseButton2] = {
        ["ValidInputStates"] = {
            GunStateEnums.AimReady, 
            GunStateEnums.AimFiring
        },

        ["TargetState"] = GunStateEnums.HipReady
    },
    [Enum.KeyCode.LeftShift] = {
        ["ValidInputStates"] = {
            GunStateEnums.Running
        },

        ["TargetState"] = GunStateEnums.HipReady
    },
}