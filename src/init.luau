--!strict
-- Services
-- Packages
-- Modules
local DateTime = require("./DateTime")
local Net = require("./Net")
local Task = require("./Task")
local Secrets = require("./Secrets")
local CONFIG = require("./CONFIG")
-- Types
export type CompatDateTime = DateTime.CompatDateTime
export type FetchParams = Net.FetchParams
export type FetchResponse = Net.FetchResponse
export type CompatSecret = Secrets.CompatSecret
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
return table.freeze({
	IS_LUNE_ENV = CONFIG.IS_LUNE_ENV,
	IS_RBX_ENV = CONFIG.IS_RBX_ENV,
	Task = Task,
	Net = Net,
	DateTime = DateTime,
	Secrets = Secrets,
	Env = require("./Env"),
})
