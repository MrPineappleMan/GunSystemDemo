local Knit = require(game:GetService("ReplicatedStorage").Knit)

local GunConfigs = require(Knit.Shared.GunConfigs)
local Maid = require(Knit.Shared.Lib.Maid)

local GunClass = {}
GunClass.__index = GunClass

function GunClass.new(gunInstance)
	local gunType = gunInstance:GetAttribute("GunType")
	local defaultGunConfigs = GunConfigs[gunType]

	local self = setmetatable({
		["GunTool"] = gunInstance,

		["AmmoReserve"] = defaultGunConfigs.AmmoReserve,
		["AmmoMag"] = defaultGunConfigs.Ammo,

		["FireType"] = defaultGunConfigs.FireType,
		["FireRate"] = defaultGunConfigs.FireRate,
		["Type"] = gunType,
		["State"] = nil,

		["Maid"] = Maid.new()
	}, GunClass)

    return self
end

function GunClass:Destroy()
	self.Maid:DoCleaning()
end

return GunClass

