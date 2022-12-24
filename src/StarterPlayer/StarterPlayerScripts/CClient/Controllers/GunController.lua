local Knit = require(game:GetService("ReplicatedStorage").Knit)

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local ViewModelController = require(Knit.Client.Controllers.ViewModelController)

local GunClass = require(Knit.Shared.Classes.GunClass)

local Client = Players.LocalPlayer

local GUN_TAG = "Gun"

local GunController = Knit.CreateController({
	["Name"] = "GunController",
})

local GunsOnHand = {}


local function AddGunToSystem(gunInstance)
	if not gunInstance:IsDescendantOf(Client.Character) or not gunInstance:IsDescendantOf(Client) then
		return
	end

	local newGun = GunClass.new(gunInstance)
	GunsOnHand[gunInstance] = newGun

	local gunCleaner = newGun.Maid

	gunCleaner:GiveTask(gunInstance.Equipped:Connect(function()
		ViewModelController:EnterFirstPersonView()
		ViewModelController:EquipGun(gunInstance)
	end))

	gunCleaner:GiveTask(gunInstance.Unequipped:Connect(function()
		ViewModelController:ExitFirstPersonView()
	end))
end

local function RemoveGunFromSystem(instance)
	local gun = GunsOnHand[instance]
	print("DESTROY")
	gun:Destroy()
	GunsOnHand[instance] = nil
end

function GunController:KnitStart()
	for _, instance in pairs(CollectionService:GetTagged(GUN_TAG)) do
		AddGunToSystem(instance)
	end

	CollectionService:GetInstanceAddedSignal(GUN_TAG):Connect(AddGunToSystem)
	CollectionService:GetInstanceRemovedSignal(GUN_TAG):Connect(RemoveGunFromSystem)

end

function GunController:KnitInit()

end

return GunController
