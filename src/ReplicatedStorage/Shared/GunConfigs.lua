local Guns = {}

local function createGunConfig(name, ammoMag, ammoReserve, fireType)
    local config = {
        ["Name"] = name,
        ["AmmoMag"] = ammoMag,
        ["AmmoReserve"] = ammoReserve,
        ["FireType"] = fireType,
        ["Model"] =  game:GetService("ReplicatedStorage").Assets.Guns[name],
    }

    Guns[name] = config

    return config
end

createGunConfig(
    "Glock-19",
    15,
    45,
    "Semi"
)

return Guns