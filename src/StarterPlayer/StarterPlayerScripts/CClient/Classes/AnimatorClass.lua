--[[
    AnimatorClass
    12/24/22

    Handles animations

]]

local Knit = require(game:GetService("ReplicatedStorage").Knit)

local Promise = require(Knit.Shared.Lib.Promise)

local AnimatorClass = {}
AnimatorClass.__index = AnimatorClass


function AnimatorClass:Play(animationName)
    if self.CurrentTrack then
        self.CurrentTrack:Stop()
    end
    
    local track = self:GetTrack(animationName)

    if track == nil then
        warn(animationName .. " WAS NOT FOUND!")
        return
    end

    track:Play()

    self.CurrentTrack = track

    return Promise.fromEvent(track.Ended)
end

function AnimatorClass:StopAll()
    for _, track in pairs(self.Tracks) do
        track:Stop()
    end
end

function AnimatorClass:GetTrack(trackName)
    return self.Tracks[trackName]
end

function AnimatorClass:GetAnimation(animationName)
    return self.Animations[animationName]
end

function AnimatorClass:ImportAnimations(animationsFolder)
    local function loadAnimations()
        local animations = {}

        for _, animationObj in pairs(animationsFolder:GetChildren()) do
            animations[animationObj.Name] = {
                ["Name"] = animationObj.Name,
                ["AnimationObject"] = animationObj,
                
                ["Properties"] = {
                    ["Looped"] = animationObj:GetAttribute("Looped"),
                    ["Priority"] = animationObj:GetAttribute("Priority")
                },
            }
        end

        return animations
    end

    local function preloadTracks(animations)
        local tracks = {}

        for _, animation in pairs(animations) do
            local animationObject = animation.AnimationObject
            local animationProperties = animation.Properties
            local track = self.AnimatorObject:LoadAnimation(animationObject)
            

            track.Looped = animationProperties.Looped
            track.Priority = animationProperties.Priority

            tracks[animation.Name] = track
        end

        return tracks
    end


    local animations = loadAnimations()
    local tracks = preloadTracks(animations)

    self.Animations = animations
    self.Tracks = tracks
end

function AnimatorClass.new(animatorObject)
    local self = setmetatable({
        ["AnimatorObject"] = animatorObject,
        ["CurrentTrack"] = nil,
        ["Animations"] = {},
        ["Tracks"] = {},
    }, AnimatorClass)

    return self
end


function AnimatorClass:Destroy()
    
end


return AnimatorClass
