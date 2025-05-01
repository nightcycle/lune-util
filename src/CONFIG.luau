--!strict
-- Services
-- Packages
-- Modules
-- Types
-- Constants
local IS_RBX_ENV = (function()
	local success, _msg = pcall(function()
		local _ = game:GetService("RunService")
	end)
	return success
end)()
local IS_LUNE_ENV = (function()
	local success, _msg = pcall(function()
		local req: any = require
		local _ = req("@lune/datetime")
	end)
	return success
end)()

-- Variables
-- References
-- Private Functions
-- Class
return table.freeze({
	IS_RBX_ENV = IS_RBX_ENV,
	IS_LUNE_ENV = IS_LUNE_ENV,
})
