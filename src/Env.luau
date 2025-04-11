--!strict
-- Services
-- Packages
local Option = require("@pkg/@nightcycle/option")
local Error = require("@pkg/@nightcycle/error")
-- Modules
local CONFIG = require("./CONFIG")
-- Types
type Option<V> = Option.Option<V>
-- Constants
-- Variables
-- References
-- Private Functions
-- Class

return (
	setmetatable({}, {
		__index = function(_, key)
			assert(type(key) == "string", `Key "{key}" must be a string`)
			if CONFIG.IS_RBX_ENV then
				local v = _G[key]
				assert(typeof(v) == "string" or typeof(v) == "nil", `Value "{v}" must be a string or nil`)
				return Option.from(v)
			else
				local Process = require("@lune/process")
				local v = Process.env[key]
				assert(typeof(v) == "string" or typeof(v) == "nil", `Value "{v}" must be a string or nil`)
				return Option.from(v)
			end
		end,
		__newindex = function(_, key, opt: Option<string>)
			assert(type(key) == "string", `Key "{key}" must be a string`)
			assert(Option.isOption(opt), `Value "{opt}" must be an Option`)

			if CONFIG.IS_RBX_ENV then
				local v = opt:asNullable()
				assert(typeof(v) == "string" or typeof(v) == "nil", `Value "{v}" must be a string or nil`)
				_G[key] = v
			else
				local Process = require("@lune/process")
				local v = opt:asNullable()
				assert(typeof(v) == "string" or typeof(v) == "nil", `Value "{v}" must be a string or nil`)
				Process.env[key] = v
			end
		end,
		__tostring = function()
			if CONFIG.IS_RBX_ENV then
				local stringEntries = {}
				for key, v in pairs(_G) do
					if typeof(v) == "string" then
						stringEntries[key] = v
					end
				end
				return Error.displayAsJson(stringEntries)
			else
				local Process = require("@lune/process")
				return Error.displayAsJson(Process.env)
			end
		end,
	}) :: any
) :: { [string]: Option<string> }
