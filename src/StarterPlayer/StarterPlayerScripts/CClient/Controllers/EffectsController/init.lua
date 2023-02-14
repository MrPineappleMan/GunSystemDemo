local Knit = require(game:GetService("ReplicatedStorage").Knit)

local EffectController = Knit.CreateController({
    ["Name"] = "EffectController",
})

function EffectController:DisplayEffect(effectName, ...)
    local effectModule = require(script[effectName])
    effectModule.Display(...)
end

function EffectController:KillEffect(effectName, ...)
    local effectModule = require(script[effectName])
    effectModule.Kill(...)
end

function EffectController:KnitStart()
	
end

function EffectController:KnitInit()
	
end

return EffectController
