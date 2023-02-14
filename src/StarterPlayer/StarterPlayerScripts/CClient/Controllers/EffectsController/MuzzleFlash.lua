local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FlashEffectHolder = ReplicatedStorage.Assets.Effects.MuzzleFlash

local MuzzleFlashEffect = {}

function MuzzleFlashEffect.Display(instance)
    local barrelTipAttachment = instance.barrel.BarrelTip

    local fireEffect = barrelTipAttachment:FindFirstChild("Fire")
    local smokeEffect = barrelTipAttachment:FindFirstChild("Smoke")

    if not fireEffect or not smokeEffect then
        fireEffect = FlashEffectHolder.Fire:Clone()
        smokeEffect = FlashEffectHolder.Smoke:Clone()

        fireEffect.Parent = barrelTipAttachment
        smokeEffect.Parent = barrelTipAttachment
    end
    

    
    fireEffect.Enabled = true
    smokeEffect.Enabled = true

    fireEffect:Emit(2)
    smokeEffect:Emit(5)
end

function MuzzleFlashEffect.Kill(instance)
    local barrelTipAttachment = instance.barrel.BarrelTip

    local fireEffect = barrelTipAttachment:FindFirstChild("Fire")
    local smokeEffect = barrelTipAttachment:FindFirstChild("Smoke")

    if not fireEffect or not smokeEffect then
        warn("TO KILL MUZZLE FLASH EFFECT, IT MUST ALREADY EXIST!")
    end

    fireEffect.Enabled = false
    smokeEffect.Enabled = false
end


return MuzzleFlashEffect