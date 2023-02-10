local TweenService = game:GetService("TweenService")
local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Promise = require(Knit.Shared.Lib.Promise)

return function(obj, tweenInfo, props)
	return Promise.defer(function(resolve, reject, onCancel)
		local tween = TweenService:Create(obj, tweenInfo, props)

		if onCancel(function()
				tween:Cancel()
			end) then return end

		tween.Completed:Connect(resolve)
		tween:Play()
	end)
end
