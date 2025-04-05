--!strict
-- Services
-- Packages
-- Modules
local CONFIG = require("./CONFIG")
-- Types
-- Constants
-- Variables
-- References
-- Private Functions
-- Class
local interface: {
	spawn: (fnOrThread: thread | () -> ()) -> thread,
	defer: (fnOrThread: thread | () -> ()) -> thread,
	delay: (delay: number, fnOrThread: thread | () -> ()) -> thread,
	wait: (duration: number) -> number,
	cancel: (thread: thread) -> (),
}

if CONFIG.IS_LUNE_ENV then
	local lunetask = require("@lune/task")

	interface = {
		spawn = lunetask.spawn :: any,
		defer = lunetask.defer :: any,
		delay = lunetask.delay :: any,
		wait = lunetask.wait :: any,
		cancel = lunetask.cancel :: any,
	}
elseif CONFIG.IS_RBX_ENV then
	interface = {
		spawn = task.spawn :: any,
		defer = task.defer :: any,
		delay = task.delay :: any,
		wait = task.wait :: any,
		cancel = task.cancel :: any,
	}
else
	error("Unsupported environment")
end

return interface
