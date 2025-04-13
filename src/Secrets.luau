--!strict
-- Services
-- Packages
local Option = require("@pkg/@nightcycle/option")
-- Modules
local CONFIG = require("./CONFIG")
-- Types
type Option<V> = Option.Option<V>
export type CompatSecret = {
	AddPrefix: (self: CompatSecret, prefix: string) -> CompatSecret,
	AddSuffix: (self: CompatSecret, suffix: string) -> CompatSecret,
	Build: (self: CompatSecret) -> string | Secret,
}
-- Constants
-- Variables
-- References
-- Private Functions
function newCompatSecret(key: string, value: string | Secret): CompatSecret
	if CONFIG.IS_RBX_ENV then
		local secret: Secret = value :: any
		local compat: CompatSecret = {
			AddPrefix = function(self: CompatSecret, prefix: string)
				assert(type(prefix) == "string", `Prefix "{prefix}" must be a string`)
				return newCompatSecret(key, secret:AddPrefix(prefix))
			end,
			AddSuffix = function(self: CompatSecret, suffix: string)
				assert(type(suffix) == "string", `Suffix "{suffix}" must be a string`)
				return newCompatSecret(key, secret:AddSuffix(suffix))
			end,
			Build = function(self: CompatSecret): string | Secret
				return secret
			end,
		}
		table.freeze(compat)
		return compat
	else
		local secret: string = value :: any
		local compat: CompatSecret = {
			AddPrefix = function(self: CompatSecret, prefix: string)
				assert(type(prefix) == "string", `Prefix "{prefix}" must be a string`)
				return newCompatSecret(key, prefix .. secret)
			end,
			AddSuffix = function(self: CompatSecret, suffix: string)
				assert(type(suffix) == "string", `Suffix "{suffix}" must be a string`)
				return newCompatSecret(key, secret .. suffix)
			end,
			Build = function(self: CompatSecret): string | Secret
				return secret
			end,
		}
		table.freeze(compat)
		return compat
	end
end
-- Class
return (
	setmetatable({}, {
		__index = function(_, key): Option<CompatSecret>
			assert(type(key) == "string", `Key "{key}" must be a string`)
			if CONFIG.IS_RBX_ENV then
				local HttpService = game:GetService("HttpService")
				local secret = HttpService:GetSecret(key)
				return Option.some(newCompatSecret(key, secret))
			else
				local Process = require("@lune/process")
				local secret = Process.env[key]
				if secret == nil then
					return Option.none()
				end
				assert(
					typeof(secret) == "string",
					`Value for "{key}" must be a string, got "{typeof(secret)}"`
				)
				return Option.some(newCompatSecret(key, secret))
			end
		end,
	}) :: any
) :: { [string]: Option<CompatSecret> }
