local M = {}

local debug_func_names = { "debug", "info", "warn", "error", "fatal" }

local function make_debug_funcs(debug_function_factory)
	debug_function_factory = debug_function_factory or function()
		return function() end
	end
	for _, funcName in ipairs(debug_func_names) do
		M[funcName] = debug_function_factory(funcName)
	end
end
make_debug_funcs()

local initialized = false
local logger
local function init()
	if initialized then
		return
	end
	if vim.g.DEBUG then
		local logfile = vim.fn.stdpath("cache") .. "/config.log"
		local Logging = require("logging")
		require("logging.rolling_file")
		logger = Logging.rolling_file({ filename = logfile, maxFileSize = 1024 })

		logger:setLevel(vim.g.DEBUG)
		make_debug_funcs(function(funcName)
			return function(x)
				logger[funcName](logger, vim.inspect(x))
			end
		end)
		initialized = true
	end
end
init()

-- handy for testins
if false then
	for _, func_name in ipairs(debug_func_names) do
		M[func_name](func_name)
	end
end

-- Handy for logging
_G.l = function(...)
	vim.g.DEBUG = "INFO"
	init()
	logger:setLevel(vim.g.DEBUG)
	M.info(...)
end

return M
