local TWEEN_OFFSET_IN_PIXELS = 20

local Knit = require(game:GetService("ReplicatedStorage").Knit)

local UIController = script:FindFirstAncestor("UIController")
local Libraries = UIController.Libraries
local tween = require(Libraries.Tween)

local Promise = require(Knit.Shared.Lib.Promise)

local FadeAnimation = {}
FadeAnimation.__index = FadeAnimation

function FadeAnimation.new(element, length)
	local self = setmetatable({
		["PivotElement"] = element,
		["Origs"] = nil,
		["Length"] = length,
		
	}, FadeAnimation)
	
	self:SetOrigs()
    return self
end

function FadeAnimation:UnLoadNow()
	local target = 1

	local search = self.PivotElement:GetDescendants()
	table.insert(search, self.PivotElement)

	for _,object in pairs(search) do
		local function setProperties(properties: table) 
			for index, value in pairs(properties) do
				object[index] = value
			end
		end

		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			setProperties({
				["TextTransparency"] = target,
				["TextStrokeTransparency"] = target,
				["BackgroundTransparency"] = target,
			})
		elseif object:IsA("Frame") or object:IsA("ScrollingFrame") then
			setProperties({
				["BackgroundTransparency"] = target,
			})
			
		elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
			setProperties({
				["ImageTransparency"] = target,
				["BackgroundTransparency"] = target,
			})
		end
	end
	self.PivotElement.Position += UDim2.fromOffset(0, TWEEN_OFFSET_IN_PIXELS)
end

function FadeAnimation:FadeOut()
	local promises = {}
	
	local target = 1
	local tweenInfo = TweenInfo.new(self.Length)
	
	local search = self.PivotElement:GetDescendants()
	table.insert(search, self.PivotElement)
	for _,object in pairs(search) do
		if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
			table.insert(promises, tween(object,tweenInfo,{
				["TextTransparency"] = target,
				["TextStrokeTransparency"] = target,
				["BackgroundTransparency"] = target,
			}))
		elseif object:IsA("Frame") or object:IsA("ScrollingFrame") then
			table.insert(promises, tween(object,tweenInfo,{
				["BackgroundTransparency"] = target,
			}))
			
		elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
			table.insert(promises, tween(object,tweenInfo,{
				["ImageTransparency"] = target,
				["BackgroundTransparency"] = target,
			}))
		end
	end
	
	table.insert(promises, tween(self.PivotElement, tweenInfo, {
		["Position"] = self.PivotElement.Position + UDim2.fromOffset(0, TWEEN_OFFSET_IN_PIXELS),
	}))
	
	if #promises < 1 then
		warn("Less than 1 Promises in FadeOut!")
		warn(search)
	end
	
	return Promise.all(promises)
end

function FadeAnimation:FadeIn()
	local promises = {}

	local tweenInfo = TweenInfo.new(self.Length)
	
	
	for instance, target in pairs(self.Origs) do
		table.insert(promises, tween(instance,tweenInfo,target))	
	end
	
	table.insert(promises, tween(self.PivotElement, tweenInfo, {
		["Position"] = self.PivotElement.Position - UDim2.fromOffset(0, TWEEN_OFFSET_IN_PIXELS),
	}))
	
	return Promise.all(promises)
end

function FadeAnimation:SetOrigs()
	local origs = {}
	
	local function addTo(instance)
		if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
			origs[instance] = {
				["TextTransparency"] = instance.TextTransparency,
				["BackgroundTransparency"] = instance.BackgroundTransparency,
			}
		elseif instance:IsA("Frame") or instance:IsA("ScrollingFrame") then
			origs[instance] = {
				["BackgroundTransparency"] = instance.BackgroundTransparency,
			}
		elseif instance:IsA("ImageLabel") or instance:IsA("ImageButton") then
			origs[instance] = {
				["ImageTransparency"] = instance.ImageTransparency,
				["BackgroundTransparency"] = instance.BackgroundTransparency,
			}
		end
	end
	
	local search = self.PivotElement:GetDescendants()
	table.insert(search, self.PivotElement)
	for _, instance in pairs(search) do
		addTo(instance)
	end 
	
	self.Origs = origs
end

function FadeAnimation:Destroy()
	-- This doesn't do anything because there isn't anything to clean up
end

return FadeAnimation