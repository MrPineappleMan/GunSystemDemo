local GunConfigs = {}

local function createGunConfig(name, ammoMag, ammoReserve, fireRate, fireType)
    local config = {
        ["Name"] = name,
        ["AmmoMag"] = ammoMag,
        ["AmmoReserve"] = ammoReserve,
        ["FireRate"] = fireRate,
        ["FireType"] = fireType,
        ["Model"] =  game:GetService("ReplicatedStorage").Assets.Guns[name],
    }

    GunConfigs[name] = config

    return config
end

createGunConfig(
    "Glock-19",
    15,
    45,
    240,
    "Semi"
)

return GunConfigs