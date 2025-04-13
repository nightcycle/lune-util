--!strict
-- Services
-- Packages
local Option = require("@pkg/@nightcycle/option")
-- Modules
local CONFIG = require("./CONFIG")
-- Types
type Option<V> = Option.Option<V>
export type CompatSecret = {
	AddPrefix: (self: CompatSecret, prefix: string) -> (),
	AddSuffix: (self: CompatSecret, suffix: string) -> (),
	Build: (self: CompatSecret) -> string | Secret,
}
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
return (
	setmetatable({}, {
		__index = function(_, key): Option<CompatSecret>
			assert(type(key) == "string", `Key "{key}" must be a string`)
			if CONFIG.IS_RBX_ENV then
				local HttpService = game:GetService("HttpService")
				local secret = HttpService:GetSecret(key)
				local compat: CompatSecret = {
					AddPrefix = function(self: CompatSecret, prefix: string)
						assert(type(prefix) == "string", `Prefix "{prefix}" must be a string`)
						secret = secret:AddPrefix(prefix)
					end,
					AddSuffix = function(self: CompatSecret, suffix: string)
						assert(type(suffix) == "string", `Suffix "{suffix}" must be a string`)
						secret = secret:AddSuffix(suffix)
					end,
					Build = function(self: CompatSecret): string | Secret
						return secret
					end,
				}
				table.freeze(compat)
				return Option.some(compat)
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
				local compat: CompatSecret = {
					AddPrefix = function(self: CompatSecret, prefix: string)
						assert(type(prefix) == "string", `Prefix "{prefix}" must be a string`)
						secret = prefix .. secret
					end,
					AddSuffix = function(self: CompatSecret, suffix: string)
						assert(type(suffix) == "string", `Suffix "{suffix}" must be a string`)
						secret = secret .. suffix
					end,
					Build = function(self: CompatSecret): string | Secret
						return secret
					end,
				}
				table.freeze(compat)
				return Option.some(compat)
			end
		end,
	}) :: any
) :: { [string]: Option<CompatSecret> }
