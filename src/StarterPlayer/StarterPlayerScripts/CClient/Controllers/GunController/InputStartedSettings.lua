local Knit = require(game:GetService("ReplicatedStorage").Knit)

local Constants = require(Knit.Shared.Constants)
local GunStateEnums = Constants.GunStateEnums
local GunConfigs = require(Knit.Shared.GunConfigs)

return {
    [Enum.UserInputType.MouseButton1] = {
        ["InvalidInputStates"] = {
            GunStateEnums.Running, 
            GunStateEnums.Reloading
        },

        ["TargetState"] = function(gunObject, currentState)
            if currentState == GunStateEnums.HipReady then
                return GunStateEnums.HipFiring
            else
                return GunStateEnums.AimFiring
            end
        end
    },

    [Enum.UserInputType.MouseButton2] = {
        ["InvalidInputStates"] = {
            GunStateEnums.Running, 
            GunStateEnums.Reloading
        },

        ["TargetState"] = GunStateEnums.AimReady
    },
    [Enum.KeyCode.LeftShift] = {
        ["InvalidInputStates"] = {
            GunStateEnums.AimFiring, 
            GunStateEnums.HipFiring, 
            GunStateEnums.Reloading
        },

        ["TargetState"] = GunStateEnums.Running
    },
    [Enum.KeyCode.R] = {
        ["InvalidInputStates"] = {
            GunStateEnums.Running, 
            GunStateEnums.HipFiring, 
            GunStateEnums.Reloading
        },

        ["TargetState"] = GunStateEnums.Reloading
    },
}