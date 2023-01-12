local Knit = require(game:GetService("ReplicatedStorage").Knit)

local UIController = Knit.CreateController({ Name = "UIController" })
UIController.Modules = {}
UIController.IsLoaded = false

function UIController:KnitStart()
	if not _G.GuiLoaded then
		warn("Waiting for UI to load...")
		_G.Loaded:Wait()
		warn("UI Objects Fully Loaded!")
	end


	for _, mod in pairs(script.Modules:GetDescendants()) do
		if mod:IsA("ModuleScript") then
			local name = mod.Name
			task.defer(function()
				self.Modules[name] = require(mod)
				if self.Modules[name].Init then
					self.Modules[name]:Init(self)
				end
			end)
		end
	end

	self.IsLoaded = true
end

function UIController:KnitInit()

end


return UIController