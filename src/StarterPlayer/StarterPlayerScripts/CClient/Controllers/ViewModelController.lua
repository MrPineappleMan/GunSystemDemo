--[[
	
	ViewModelController



]]


local Knit = require(game:GetService("ReplicatedStorage").Knit)

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Client = Players.LocalPlayer

local ViewModel = ReplicatedStorage.Assets.Viewmodel

local ViewModelController = Knit.CreateController({
	["Name"] = "ViewModelController",
})

local onUpdateConnection

function ViewModelController:EquipGun(gunInstance)
	if onUpdateConnection == nil then
		self:EnterFirstPersonView()
	end
	
	local componentsFolder = gunInstance:WaitForChild("Components")
	local gunHandlePart = componentsFolder.Handle
	
	local rootPartMotor6D = ViewModel:WaitForChild("HumanoidRootPart").Handle
	
	rootPartMotor6D.Part1 = gunHandlePart
	-- Play idle animation
end

function ViewModelController:EnterFirstPersonView()
	local function update(deltaTime)
		ViewModel.HumanoidRootPart.CFrame = workspace.Camera.CFrame
	end
	
	ViewModel.Parent = workspace.Camera
	
	onUpdateConnection = RunService.RenderStepped:Connect(update)
end

function ViewModelController:ExitFirstPersonView()
	onUpdateConnection:Disconnect()
	onUpdateConnection = nil
	
	ViewModel.Parent = ReplicatedStorage
end

function ViewModelController:KnitStart()
	
end

function ViewModelController:KnitInit()
	
end

return ViewModelController
