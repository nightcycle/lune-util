--!strict
-- Services
-- Packages
-- Modules
local CONFIG = require("./CONFIG")
-- Types
type FetchParams = {
	url: string,
	method: ("GET" | "POST" | "PATCH" | "PUT" | "DELETE")?,
	body: any?,
	query: { [string]: any }?,
	headers: { [string]: any }?,
	options: {
		decompress: boolean?,
	}?,
}
type FetchResponse = {
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
