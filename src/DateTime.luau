--!strict
-- Services
-- Packages
-- Modules
local CONFIG = require("./CONFIG")
-- Types
type TimeMap = {
	year: number,
	month: number,
	day: number,
	hour: number,
	minute: number,
	second: number,
	millisecond: number,
}
type Locale = "en" | "de" | "es" | "fr" | "it" | "ja" | "pl" | "pt-br" | "pt" | "tr"

type CompatDateTimeImpl = {
	__index: CompatDateTimeImpl,
	formatUniversalTime: (self: CompatDateTime, format: string, locale: Locale) -> string,
	formatLocalTime: (self: CompatDateTime, format: string, locale: Locale) -> string,
	formatIsoDate: (self: CompatDateTime) -> string,
	toUniveralTime: (self: CompatDateTime) -> TimeMap,
	toLocalTime: (self: CompatDateTime) -> TimeMap,
}
type CompatDateStruct = {
	unixTimestamp: number,
	unixTimestampMillis: number,
}
export type CompatDateTime = typeof(setmetatable({} :: CompatDateStruct, {} :: CompatDateTimeImpl))
-- Constants
local RBX_LOCALE_TO_RBX_LOCAL_ID: { [Locale]: string } = {
	en = "en-us",
	de = "de-de",
	es = "es-es",
	fr = "fr-fr",
	it = "it-it",
	ja = "ja-jp",
	pl = "pl-pl",
	["pt-br"] = "pt-br",
	pt = "pt-pt",
	tr = "tr-tr",
}
-- Variables
-- References
-- Private Functions
-- Class
local interface: {
	now: () -> CompatDateTime,
	fromIsoDate: (isoDate: string) -> CompatDateTime,
	fromUnixTimestamp: (unixTimestamp: number) -> CompatDateTime,
	fromUnixTimestampMillis: (unixTimestampMs: number) -> CompatDateTime,
	fromUniversalTime: (
		year: number,
		month: number,
		day: number,
		hour: number,
		minute: number,
		second: number,
		millisecond: number
	) -> CompatDateTime,
	fromLocalTime: (
		year: number,
		month: number,
		day: number,
		hour: number,
		minute: number,
		second: number,
		millisecond: number
	) -> CompatDateTime,
}

if CONFIG.IS_LUNE_ENV then
	local datetime = require("@lune/datetime")

	local CompatDateTimeImpl = {}
	CompatDateTimeImpl.__index = CompatDateTimeImpl

	function CompatDateTimeImpl:__tostring(): string
		return `CompatDateTime<{self:formatIsoDate()}>`
	end

	function CompatDateTimeImpl:formatUniversalTime(format: string, locale: Locale): string
		return datetime.fromUnixTimestamp(self.unixTimestampMillis / 1000):formatUniversalTime(format, locale)
	end

	function CompatDateTimeImpl:formatLocalTime(format: string, locale: Locale): string
		return datetime.fromUnixTimestamp(self.unixTimestampMillis / 1000):formatLocalTime(format, locale)
	end

	function CompatDateTimeImpl:formatIsoDate(): string
		return datetime.fromUnixTimestamp(self.unixTimestampMillis / 1000):toIsoDate()
	end

	function CompatDateTimeImpl:toUniveralTime(): TimeMap
		return datetime.fromUnixTimestamp(self.unixTimestampMillis / 1000):toUniversalTime()
	end

	function CompatDateTimeImpl:toLocalTime(): TimeMap
		return datetime.fromUnixTimestamp(self.unixTimestampMillis / 1000):toUniversalTime()
	end

	local constructor = function(dateTime: datetime.DateTime): CompatDateTime
		return setmetatable({
			unixTimestamp = dateTime.unixTimestamp,
			unixTimestampMillis = dateTime.unixTimestampMillis,
		}, CompatDateTimeImpl)
	end

	interface = {
		now = function(): CompatDateTime
			return constructor(datetime.now())
		end,
		fromIsoDate = function(isoDate: string): CompatDateTime
			return constructor(datetime.fromIsoDate(isoDate))
		end,
		fromUnixTimestamp = function(unixTimestamp: number): CompatDateTime
			return constructor(datetime.fromUnixTimestamp(math.round(unixTimestamp)))
		end,
		fromUnixTimestampMillis = function(unixTimestampMs: number): CompatDateTime
			return constructor(datetime.fromUnixTimestamp(math.round(unixTimestampMs) / 1000))
		end,
		fromUniversalTime = function(
			year: number,
			month: number,
			day: number,
			hour: number,
			minute: number,
			second: number,
			millisecond: number
		): CompatDateTime
			return constructor(datetime.fromUniversalTime({
				year = year,
				month = month,
				day = day,
				hour = hour,
				minute = minute,
				second = second,
				millisecond = millisecond,
			}))
		end,
		fromLocalTime = function(
			year: number,
			month: number,
			day: number,
			hour: number,
			minute: number,
			second: number,
			millisecond: number
		): CompatDateTime
			return constructor(datetime.fromLocalTime({
				year = year,
				month = month,
				day = day,
				hour = hour,
				minute = minute,
				second = second,
				millisecond = millisecond,
			}))
		end,
	}
elseif CONFIG.IS_RBX_ENV then
	local CompatDateTimeImpl = {}
	CompatDateTimeImpl.__index = CompatDateTimeImpl

	function CompatDateTimeImpl:__tostring(): string
		return `CompatDateTime<{self:formatIsoDate()}>`
	end

	function CompatDateTimeImpl:formatUniversalTime(format: string, locale: Locale): string
		return DateTime.fromUnixTimestampMillis(self.unixTimestampMillis)
			:FormatUniversalTime(format, RBX_LOCALE_TO_RBX_LOCAL_ID[locale])
	end

	function CompatDateTimeImpl:formatLocalTime(format: string, locale: Locale): string
		return DateTime.fromUnixTimestampMillis(self.unixTimestampMillis)
			:FormatLocalTime(format, RBX_LOCALE_TO_RBX_LOCAL_ID[locale])
	end

	function CompatDateTimeImpl:formatIsoDate(): string
		return DateTime.fromUnixTimestampMillis(self.unixTimestampMillis):ToIsoDate()
	end

	function toTimeMap(rbxMap: {
		Year: number,
		Month: number,
		Day: number,
		Hour: number,
		Minute: number,
		Second: number,
		Millisecond: number,
	}): TimeMap
		return {
			year = rbxMap.Year,
			month = rbxMap.Month,
			day = rbxMap.Day,
			hour = rbxMap.Hour,
			minute = rbxMap.Minute,
			second = rbxMap.Second,
			millisecond = rbxMap.Millisecond,
		}
	end

	function CompatDateTimeImpl:toUniveralTime(): TimeMap
		return toTimeMap(DateTime.fromUnixTimestampMillis(self.unixTimestampMillis):ToUniversalTime() :: any)
	end

	function CompatDateTimeImpl:toLocalTime(): TimeMap
		return toTimeMap(DateTime.fromUnixTimestampMillis(self.unixTimestampMillis):ToLocalTime() :: any)
	end

	local constructor = function(dateTime: DateTime): CompatDateTime
		return setmetatable(
			{ unixTimestampMillis = dateTime.UnixTimestampMillis, unixTimestamp = dateTime.UnixTimestamp },
			CompatDateTimeImpl
		)
	end

	interface = {
		now = function(): CompatDateTime
			return constructor(DateTime.now())
		end,
		fromIsoDate = function(isoDate: string): CompatDateTime
			return constructor(DateTime.fromIsoDate(isoDate))
		end,
		fromUnixTimestamp = function(unixTimestamp: number): CompatDateTime
			return constructor(DateTime.fromUnixTimestamp(math.round(unixTimestamp)))
		end,
		fromUnixTimestampMillis = function(unixTimestampMs: number): CompatDateTime
			return constructor(DateTime.fromUnixTimestampMillis(math.round(unixTimestampMs)))
		end,
		fromUniversalTime = function(
			year: number,
			month: number,
			day: number,
			hour: number,
			minute: number,
			second: number,
			millisecond: number
		): CompatDateTime
			return constructor(
				DateTime.fromUniversalTime(year, month, day, hour, minute, second, millisecond)
			)
		end,
		fromLocalTime = function(
			year: number,
			month: number,
			day: number,
			hour: number,
			minute: number,
			second: number,
			millisecond: number
		): CompatDateTime
			return constructor(DateTime.fromLocalTime(year, month, day, hour, minute, second, millisecond))
		end,
	}
else
	error("Unsupported environment")
end

return interface
