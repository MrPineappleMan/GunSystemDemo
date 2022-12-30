--[[
	ViewModelController:
	12/22/22

	Handles the first person view model, primarily for Guns
]]

local Knit = require(game:GetService("ReplicatedStorage").Knit)

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GunController

local MaidClass = require(Knit.Shared.Lib.Maid)
local AnimatorClass = require(Knit.Client.Classes.AnimatorClass)

local StateToNameConversionTable = require(script.StateToNameConversionTable)
local ViewModelTransitions = require(script.ViewModelTransitions)
local GunStateEnums = require(Knit.Shared.Constants).GunStateEnums

local Client = Players.LocalPlayer
local Assets = ReplicatedStorage.Assets
local ViewModel = Assets.ViewModel
local GunsFolder = Assets.Guns

local ViewModelAnimator = AnimatorClass.new(ViewModel.AnimationController.Animator)
local Cleaner = MaidClass.new()

local ViewModelController = Knit.CreateController({
	["Name"] = "ViewModelController",
	["Animator"] = ViewModelAnimator,
})

function ViewModelController:EquipGun(gunInstance)
	if Cleaner.onUpdateTask == nil then
		self:EnterFirstPersonView()
	end

	local gunModel = GunsFolder[gunInstance.Name]:Clone()
	
	local gunChildren = gunModel:GetChildren()
	local viewModelCamera = ViewModel:WaitForChild("Camera")
	local GunBone = gunModel:WaitForChild("GunBone").HandGun

	local function moveGunParts()
		for _, instance in pairs(gunChildren) do
			if instance.Name == "GunBone" then
				continue
			end

			instance.Parent = ViewModel
		end
	end

	local function setGunMotor6Ds()
		for _, instance in pairs(gunModel:GetDescendants()) do
			if instance:IsA("Motor6D") then
				instance.Part0 = viewModelCamera
			end
		end
	end

	ViewModelAnimator:ImportAnimations(gunModel.Animations)

	GunBone.Parent = ViewModel.Camera.cameraBone["upArm.R"]["elbow.R"]["LowArm.R"]
	setGunMotor6Ds()
	moveGunParts()

	Cleaner.watchStateUpdate = GunController.OnGunStateChange:Connect(function(newState, lastState)
		local transitionInfo = ViewModelTransitions:GetTransitionInfo(lastState, newState)
		local targetAnimationName = StateToNameConversionTable[GunStateEnums:GetEnumName(newState)]

		ViewModelAnimator:StopAll()

		if transitionInfo then
			ViewModelAnimator:Play(transitionInfo.AnimationName)
		end

		if targetAnimationName ~= "None" or targetAnimationName ~= nil then
			ViewModelAnimator:Play(targetAnimationName)
		end
	end)

	Cleaner.equipGunTrash = function()
		for _, instance in pairs(gunChildren) do
			instance:Destroy()
		end
	end
	-- Play idle animation
end

function ViewModelController:EnterFirstPersonView()
	local function update(deltaTime)
		ViewModel.Camera.CFrame = workspace.Camera.CFrame
	end

	-- Client.CameraMode = Enum.CameraMode.LockFirstPerson
	ViewModel.Parent = workspace.Camera

	Cleaner.onUpdateTask = RunService.RenderStepped:Connect(update)
end

function ViewModelController:ExitFirstPersonView()
	Cleaner.onUpdateTask = nil
	Cleaner.equipGunTrash = nil

	Client.CameraMode = Enum.CameraMode.Classic
	ViewModel.Parent = ReplicatedStorage
end

function ViewModelController:KnitStart()

end

function ViewModelController:KnitInit()
	GunController = require(Knit.Client.Controllers.GunController)
end

return ViewModelController
