-- Constants
-- UnknownParabellum
-- January 17, 2021

local Knit = require(game:GetService("ReplicatedStorage").Knit)

local CustomEnum = require(Knit.Shared.Lib.CustomEnum)

local Constants = {
	["GunStateEnum"] = CustomEnum.new(
		"Ready",
		"Firing",
		"Reloading",
		"Disabled"
	)
}

local function setReadOnlyTable(table: Dictionary)
    local readOnly = setmetatable({}, {
        __index = table,
        __newindex = function(table, key, value)
            error("Attempt to modify read-only table")
        end,
        __metatable = false
    })
    for index,val in pairs(table) do
        if typeof(val) == "table" then
            rawset(readOnly, index,setReadOnlyTable(val))
        end
    end
    return readOnly
end

function Constants:Init()
    Constants = setReadOnlyTable(Constants)
end


return Constants