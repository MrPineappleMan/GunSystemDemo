--[[
    Conversion Table from GunStateEnum to its respective  animation

]]

return {
    ["HipReady"] = "HipIdle",
    ["AimReady"] = "AimIdle",

    ["AimFiring"] = "AimFire",
    ["HipFiring"] = "HipFire",

    ["Reloading"] = "ReloadUnChambered",
    ["Running"] = "RunningIdle",
    
    ["Disabled"] = "None",
    ["Unavailible"] = "Holster"
}