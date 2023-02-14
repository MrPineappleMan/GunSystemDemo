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

local InputStartedSettings = require(script.InputStartedSettings)
local InputEndedSettings = require(script.InputEndedSettings)

local Client = Players.LocalPlayer

local GUN_TAG = "Gun"

local GunController = Knit.CreateController({
	["Name"] = "GunController",

	["CurrentGunObject"] = nil,
	["GunState"] = GunStateEnums.Unavailible,

	["OnGunStateChange"] = SignalClass.new(),
	["OnGunAdded"] = SignalClass.new()
})

local GunsOnHand = {}

local function HandleGunTasks(gun)
	local gunInstance = gun.GunInstance
	local gunCleaner = gun.Maid
	local gunInputCleaner = MaidClass.new()

	local function isInstanceInTable(instance, table)
		for _, value in pairs(table) do
			if instance == value then
				return true
			end
		end

		return false
	end
	
	local function processInput(inputTime, inputObject, gameProcessedEvent)
		local settingsTable = inputTime == "Started" and InputStartedSettings or InputEndedSettings
		
		local currentState = GunController.GunState

		local function shouldReject(settings)
			if inputTime == "Started" then
				return isInstanceInTable(currentState, settings.InvalidInputStates)
			end

			return not isInstanceInTable(currentState, settings.ValidInputStates)
		end

		for inputType, settings in pairs(settingsTable) do
			if inputObject.UserInputType == inputType or inputObject.KeyCode == inputType then
				if shouldReject(settings) then
					return
				end
				
				local targetState = settings.TargetState

				if typeof(settings.TargetState) == "function" then
					targetState = settings.TargetState(gun, currentState)
				end 

				GunController:SetGunState(targetState)
			end
		end
	end

	gunCleaner:GiveTask(gunInstance.Equipped:Connect(function()
		GunController.CurrentGunObject = gun
		ViewModelController:EnterFirstPersonView()
		ViewModelController:EquipGun(gunInstance)

		GunController:SetGunState(GunStateEnums.HipReady)

		gunInputCleaner:GiveTask(UserInputService.InputBegan:Connect(function(inputObject, gameProcessedEvent)
			processInput("Started", inputObject, gameProcessedEvent)
		end))
		gunInputCleaner:GiveTask(UserInputService.InputEnded:Connect(function(inputObject, gameProcessedEvent)
			processInput("Ended", inputObject, gameProcessedEvent)
		end))
	end))

	gunCleaner:GiveTask(gunInstance.Unequipped:Connect(function()
		ViewModelController:ExitFirstPersonView()
		GunController:SetGunState(GunStateEnums.Unavailible)
		gunInputCleaner:DoCleaning()
		
		GunController.CurrentGunObject = nil
	end))
end

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

function GunController:SetGunState(newState)
	local lastState = self.GunState

	if newState < 0 or newState == lastState then
		return
	end

	self.GunState = newState
	print(string.format(
		"New Gun State: %s || Previously: %s", 
		GunStateEnums:GetEnumName(newState),
		GunStateEnums:GetEnumName(lastState)
	))

	self.OnGunStateChange:Fire(newState, lastState)
end

function GunController:KnitStart()
	self.OnGunAdded:Connect(HandleGunTasks)

	for _, instance in pairs(CollectionService:GetTagged(GUN_TAG)) do
		AddGunToSystem(instance)
	end

	CollectionService:GetInstanceAddedSignal(GUN_TAG):Connect(AddGunToSystem)
	CollectionService:GetInstanceRemovedSignal(GUN_TAG):Connect(RemoveGunFromSystem)

	self.OnGunStateChange:Connect(function(newState, lastState)
		local currentGun = self.CurrentGunObject

		if currentGun.FireType == "Semi" and (newState == GunStateEnums.HipFiring or newState == GunStateEnums.AimFiring) then
			task.delay(0.1, function()
				local targetState = newState == GunStateEnums.HipFiring and GunStateEnums.HipReady or GunStateEnums.AimReady
				self:SetGunState(targetState)
			end)
		end
	end)
end

function GunController:KnitInit()
	ViewModelController = require(Knit.Client.Controllers.ViewModelController)
end

return GunController
