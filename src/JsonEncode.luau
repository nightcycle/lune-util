--!strict
-- used to fix issue where .0 is added to the end of integers by lune
-- https://github.com/rxi/json.lua/blob/master/json.lua
-- Services
-- Packages
-- Modules
-- Types
export type JSONValue = string | number | boolean | nil | { [string]: JSONValue } | { JSONValue }
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
local encode: (val: JSONValue, stack: { [any]: true }?) -> string

local escape_char_map = {
	["\\"] = "\\",
	['"'] = '"',
	["\b"] = "b",
	["\f"] = "f",
	["\n"] = "n",
	["\r"] = "r",
	["\t"] = "t",
}

local escape_char_map_inv = { ["/"] = "/" }
for k, v in pairs(escape_char_map) do
	escape_char_map_inv[v] = k
end

local function escape_char(c: string): string
	return "\\" .. (escape_char_map[c] or string.format("u%04x", c:byte()))
end

local function encode_nil(val: nil): string
	return "null"
end

local function encode_table(val: { [string]: JSONValue } | { JSONValue }, stack: { [any]: true }?)
	local res = {}
	stack = stack or {}
	assert(stack, "bad stack")
	-- Circular reference?
	if stack[val] then
		error("circular reference")
	end

	stack[val] = true

	if rawget(val, 1) ~= nil or next(val) == nil then
		local array: { JSONValue } = val :: any
		-- Treat as array -- check keys are valid and it is not sparse
		local n = 0
		for k in pairs(array) do
			if type(k) ~= "number" then
				error("invalid table: mixed or invalid key types")
			end
			n = n + 1
		end
		if n ~= #array then
			error("invalid table: sparse array")
		end
		-- Encode
		for i, v in ipairs(array) do
			table.insert(res, encode(v, stack))
		end
		stack[array] = nil
		return "[" .. table.concat(res, ",") .. "]"
	else
		-- Treat as an object
		for k, v in pairs(val) do
			if type(k) ~= "string" then
				error("invalid table: mixed or invalid key types")
			end
			table.insert(res, encode(k, stack) .. ":" .. encode(v, stack))
		end
		stack[val] = nil
		return "{" .. table.concat(res, ",") .. "}"
	end
end

local function encode_string(val: string): string
	return `"{val:gsub('[%z\1-\31\\"]', escape_char)}"`
end

local function encode_number(val: number): string
	-- Check for NaN, -inf and inf
	if val ~= val or val <= -math.huge or val >= math.huge then
		error("unexpected number value '" .. tostring(val) .. "'")
	end
	return string.format("%.14g", val)
end

local type_func_map = {
	["nil"] = encode_nil,
	["table"] = encode_table,
	["string"] = encode_string,
	["number"] = encode_number,
	["boolean"] = tostring,
}

encode = function(val: JSONValue, stack: { [any]: true }?): string
	local t = type(val)
	local f = type_func_map[t]
	if f then
		return f(val, stack)
	end
	error("unexpected type '" .. t .. "'")
end

return encode
