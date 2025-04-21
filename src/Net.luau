--!strict
-- Services
-- Packages
-- Modules
local CONFIG = require("./CONFIG")
-- Types
export type FetchParams = {
	url: string,
	method: ("GET" | "POST" | "PATCH" | "PUT" | "DELETE")?,
	body: any?,
	query: { [string]: any }?,
	headers: { [string]: any }?,
	options: {
		decompress: boolean?,
	}?,
}
export type FetchResponse = {
	ok: boolean,
	statusCode: number,
	statusMessage: string,
	headers: { [string]: string },
	body: string,
}

-- Constants
-- Variables
-- References
-- Private Functions
-- Class
local interface: {
	request: (string | FetchParams) -> FetchResponse,
	jsonEncode: (value: any) -> string,
	jsonDecode: (value: string) -> any,
	IS_ENABLED: boolean,
	generateGUID: (wrapInCurlyBraces: boolean?) -> string,
}

if CONFIG.IS_LUNE_ENV then
	local net = require("@lune/net")

	interface = {
		request = function(urlOrParams: string | FetchParams): FetchResponse
			local response: net.FetchResponse
			if type(urlOrParams) == "string" then
				response = net.request({ url = urlOrParams })
			else
				response = net.request(urlOrParams)
			end
			return {
				ok = response.ok,
				statusCode = response.statusCode,
				statusMessage = response.statusMessage,
				headers = response.headers :: { [string]: string },
				body = response.body,
			}
		end,
		generateGUID = function(wrapInCurlyBraces: boolean?): string
			local function generateGUID(): string
				local function randomHexDigit(): string
					math.randomseed(math.round((os.clock() % 1) * 100000000000))
					local digit = math.random(0, 15)
					return string.format("%x", digit)
				end
				local parts = {
					string.rep(randomHexDigit(), 8),
					string.rep(randomHexDigit(), 4),
					"4" .. string.rep(randomHexDigit(), 3),
					string.format("%x", math.random(8, 11)) .. string.rep(randomHexDigit(), 3),
					string.rep(randomHexDigit(), 12),
				}
				return table.concat(parts, "-")
			end
			if wrapInCurlyBraces or wrapInCurlyBraces == nil then
				return "{" .. generateGUID() .. "}"
			else
				return generateGUID()
			end
		end,
		jsonEncode = net.jsonEncode,
		jsonDecode = net.jsonDecode,
		IS_ENABLED = true,
	}
elseif CONFIG.IS_RBX_ENV then
	local HttpService = game:GetService("HttpService")
	interface = {
		request = function(urlOrParams: string | FetchParams): FetchResponse
			local response
			local params: FetchParams = type(urlOrParams) == "string" and { Url = urlOrParams }
				or urlOrParams :: any

			response = HttpService:RequestAsync({
				Url = params.url,
				Method = params.method,
				Body = params.body,
				Headers = params.headers,
				Compress = if params.options and params.options.decompress == false
					then Enum.HttpCompression.None
					else Enum.HttpCompression.Gzip,
			})
			return {
				ok = response.Success,
				statusCode = response.StatusCode,
				statusMessage = response.StatusMessage,
				headers = response.Headers :: { [string]: string },
				body = response.Body or "",
			}
		end,
		generateGUID = function(wrapInCurlyBraces: boolean?): string
			local guid = HttpService:GenerateGUID(wrapInCurlyBraces)
			return string.sub(guid, 2, -2) -- Remove the curly braces
		end,
		jsonEncode = function(value: any): string
			return HttpService:JSONEncode(value)
		end,
		jsonDecode = function(value: string): any
			return HttpService:JSONDecode(value)
		end,
		IS_ENABLED = HttpService.HttpEnabled,
	}
else
	error("Unsupported environment")
end

return interface
