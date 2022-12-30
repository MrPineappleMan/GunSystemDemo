local Knit = require(game:GetService("ReplicatedStorage").Knit)

local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local ViewModelController 

local MaidClass = require(Knit.Shared.Lib.Maid)
local GunClass = require(Knit.Shared.Classes.GunClass)
local SignalClass = require(Knit.Shared.Lib.Signal)

local Constants = require(Knit.Shared.Constants)
local GunStateEnums = Constants.GunStateEnums

local Client = Players.LocalPlayer

local GUN_TAG = "Gun"

local GunController = Knit.CreateController({
	["Name"] = "GunController",

	["GunState"] = GunStateEnums.Unavailible,

	["OnGunStateChange"] = SignalClass.new(),
	["OnGunAdded"] = SignalClass.new()
})

local GunsOnHand = {}

local function AddGunToSystem(gunInstance)
	if not gunInstance:IsDescendantOf(Client.Character) or not gunInstance:IsDescendantOf(Client) then
		return
	end

	local newGun = GunClass.new(gunInstance)
	GunsOnHand[gunInstance] = newGun

	GunController.OnGunAdded:Fire(newGun)
end

local function RemoveGunFromSystem(instance)
	local gun = GunsOnHand[instance]
	gun:Destroy()
	GunsOnHand[instance] = nil
end

local function HandleGunTasks(gun)
	local gunInstance = gun.GunInstance
	local gunCleaner = gun.Maid
	local gunInputCleaner = MaidClass.new()

	local currentState = GunController.GunState

	local function isInputInvalidated(...)
		local invalidStates = {...}
		local isInvalid = false

		for _, value in pairs(invalidStates) do
			if currentState == value then
				isInvalid = true
			end
		end

		return isInvalid
	end

	local function isValidState(...)
		local validStates = {...}
		local canReverse = false

		for _, value in pairs(validStates) do
			if currentState == value then
				canReverse = true
			end
		end

		return canReverse
	end

	local function handleInput(inputObject, gameProcessedEvent)
		local keyCode = inputObject.KeyCode
		local targetState = -1
		currentState = GunController.GunState

		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then -- Fire Weapon Input
			if isInputInvalidated(GunStateEnums.Running, GunStateEnums.Reloading) then
				return
			end

			targetState = (currentState == GunStateEnums.HipReady) and GunStateEnums.HipFiring or GunStateEnums.AimFiring
		elseif inputObject.UserInputType == Enum.UserInputType.MouseButton2 then	-- Aim Down Sights Input
			if isInputInvalidated(GunStateEnums.Running, GunStateEnums.Reloading) then
				return
			end

			targetState = GunStateEnums.AimReady
		elseif keyCode == Enum.KeyCode.LeftShift then 	-- Run Input
			if isInputInvalidated(GunStateEnums.AimFiring, GunStateEnums.HipFiring, GunStateEnums.Reloading) then
				return
			end

			targetState = GunStateEnums.Running
		elseif keyCode == Enum.KeyCode.R then 	-- Reload Input
			if isInputInvalidated(GunStateEnums.Running, GunStateEnums.HipFiring, GunStateEnums.Reloading) then
				return
			end

			targetState = GunStateEnums.Reloading
		end

		-- Note. If a value is invalid then it will not set the state anyways
		GunController:SetGunState(targetState)
	end

	local function handleRelease(inputObject, gameProcessedEvent)
		local keyCode = inputObject.KeyCode
		local targetState = -1
		currentState = GunController.GunState

		-- Fire Weapon Input
		if inputObject.UserInputType == Enum.UserInputType.MouseButton1 and isValidState(GunStateEnums.AimFiring, GunStateEnums.HipFiring) then
			targetState = (currentState == GunStateEnums.HipFiring) and GunStateEnums.HipReady or GunStateEnums.AimReady

		-- Aim Down Sights Input
		elseif inputObject.UserInputType == Enum.UserInputType.MouseButton2 and isValidState(GunStateEnums.AimReady, GunStateEnums.AimFiring) then
			targetState = GunStateEnums.HipReady

		-- Run Input
		elseif keyCode == Enum.KeyCode.LeftShift and isValidState(GunStateEnums.Running) then
			if isValidState(GunStateEnums.AimFiring, GunStateEnums.HipFiring, GunStateEnums.Reloading) then
				return
			end

			targetState = GunStateEnums.HipReady
		end

		GunController:SetGunState(targetState)
	end

	gunCleaner:GiveTask(gunInstance.Equipped:Connect(function()
		ViewModelController:EnterFirstPersonView()
		ViewModelController:EquipGun(gunInstance)

		GunController:SetGunState(GunStateEnums.HipReady)

		gunInputCleaner:GiveTask(UserInputService.InputBegan:Connect(handleInput))
		gunInputCleaner:GiveTask(UserInputService.InputEnded:Connect(handleRelease))
	end))

	gunCleaner:GiveTask(gunInstance.Unequipped:Connect(function()
		ViewModelController:ExitFirstPersonView()
		GunController:SetGunState(GunStateEnums.Unavailible)
		gunInputCleaner:DoCleaning()
	end))
end

function GunController:SetGunState(newState)
	local lastState = self.GunState

	if newState < 0 or newState == lastState then
		return
	end

	self.GunState = newState

	print("New Gun State: ")
	warn(GunStateEnums:GetEnumName(newState))
	self.OnGunStateChange:Fire(newState, lastState)
end

function GunController:KnitStart()
	self.OnGunAdded:Connect(HandleGunTasks)

	for _, instance in pairs(CollectionService:GetTagged(GUN_TAG)) do
		AddGunToSystem(instance)
	end

	CollectionService:GetInstanceAddedSignal(GUN_TAG):Connect(AddGunToSystem)
	CollectionService:GetInstanceRemovedSignal(GUN_TAG):Connect(RemoveGunFromSystem)

end

function GunController:KnitInit()
	ViewModelController = require(Knit.Client.Controllers.ViewModelController)
end

return GunController
