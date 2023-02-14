--[[
	ViewModelController:
	12/22/22

	Handles the first person view model, primarily for Guns
]]

local Knit = require(game:GetService("ReplicatedStorage").Knit)

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

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

function ViewModelController:EquipGun(gun)
	if Cleaner.onUpdateTask == nil then
		self:EnterFirstPersonView()
	end

	local gunTool = gun.GunTool
	local gunModel = GunsFolder[gunTool.Name]:Clone()
	local viewModelCamera = ViewModel:WaitForChild("Camera")

	ViewModelAnimator:ImportAnimations(gunModel.Animations)

	gun.GunModel = gunModel
	gunModel.Parent = ViewModel
	viewModelCamera.Handle.Part1 = gunModel.Handle

	local currentTransitionConnection

	local transitionInfo
	local targetAnimationName 
	local lastAnimationName

	-- Notify animator of updates
	Cleaner.watchStateUpdate = GunController.OnGunStateChange:Connect(function(newState, lastState)
		transitionInfo = ViewModelTransitions:GetTransitionInfo(lastState, newState)
		targetAnimationName = StateToNameConversionTable[GunStateEnums:GetEnumName(newState)]
	end)

	local lastUpdated = tick()
	local ANIMATION_COOLDOWN = 0.15

	-- Watch for updates and only update after the cooldown is complete
	Cleaner.onHeartbeatWatch = RunService.Heartbeat:Connect(function(deltaTime)
		local timeDifference = tick() - lastUpdated

		if timeDifference >= ANIMATION_COOLDOWN and targetAnimationName ~= lastAnimationName then
			lastUpdated = tick()
			lastAnimationName = targetAnimationName

			ViewModelAnimator:StopAll()

			if transitionInfo then
				currentTransitionConnection = ViewModelAnimator:Play(transitionInfo.AnimationName)
				currentTransitionConnection = nil
			end
	
			if targetAnimationName ~= "None" or targetAnimationName ~= nil then
				if currentTransitionConnection then
					currentTransitionConnection.Completed:Wait()
				end
	
				ViewModelAnimator:Play(targetAnimationName)
	
				currentTransitionConnection = nil
			end
		end
	end)

	Cleaner.equipGunTrash = function()
		gunModel:Destroy()
	end
end

function ViewModelController:EnterFirstPersonView()
	local function update(deltaTime)
		ViewModel.Camera.CFrame = workspace.Camera.CFrame
	end

	-- Client.CameraMode = Enum.CameraMode.LockFirstPerson
	ViewModel.Parent = workspace.Camera
	UserInputService.MouseIconEnabled = false

	Cleaner.onUpdateTask = RunService.RenderStepped:Connect(update)
end

function ViewModelController:ExitFirstPersonView()
	Cleaner:DoCleaning()

	Client.CameraMode = Enum.CameraMode.Classic
	UserInputService.MouseIconEnabled = true
	ViewModel.Parent = ReplicatedStorage
end

function ViewModelController:KnitStart()

end

function ViewModelController:KnitInit()
	GunController = require(Knit.Client.Controllers.GunController)
end

return ViewModelController
