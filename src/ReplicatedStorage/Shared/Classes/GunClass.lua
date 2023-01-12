local Knit = require(game:GetService("ReplicatedStorage").Knit)

local Maid = require(Knit.Shared.Lib.Maid)

local GunClass = {}
GunClass.__index = GunClass

function GunClass.new(gunInstance)
	local self = setmetatable({
		["GunInstance"] = gunInstance,

		["AmmoStore"] = gunInstance:GetAttribute("AmmoStore"),
		["AmmoMag"] = gunInstance:GetAttribute("AmmoMag"),

		["Type"] = gunInstance:GetAttribute("GunType"),
		["State"] = nil,

		["Maid"] = Maid.new()
	}, GunClass)

    return self
end

function GunClass:Destroy()
	self.Maid:DoCleaning()
end

return GunClass

