vim.opt.runtimepath:append(vim.fn.getcwd())

local navigator = require("herdr-navigator")

local function assert_equal(expected, actual, message)
	if expected ~= actual then
		error(string.format("%s\nexpected: %s\nactual: %s", message, vim.inspect(expected), vim.inspect(actual)), 2)
	end
end

local function assert_table(expected, actual, message)
	assert_equal(vim.inspect(expected), vim.inspect(actual), message)
end

local function reset_env()
	vim.env.HERDR_SESSION = nil
	vim.env.HERDR_PANE_ID = nil
	vim.env.HERDR_ENV = nil
end

local function with_stubbed_system(callback)
	local calls = {}
	local original_system = vim.fn.system
	local original_executable = vim.fn.executable

	vim.fn.system = function(argv)
		table.insert(calls, argv)
		return ""
	end
	vim.fn.executable = function()
		return 1
	end

	local ok, err = pcall(callback, calls)

	vim.fn.system = original_system
	vim.fn.executable = original_executable

	if not ok then
		error(err, 0)
	end
end

local function test_detects_any_herdr_marker()
	reset_env()
	assert_equal(false, navigator.is_herdr(), "does not detect Herdr outside a Herdr environment")

	vim.env.HERDR_SESSION = "session"
	assert_equal(true, navigator.is_herdr(), "detects HERDR_SESSION")

	reset_env()
	vim.env.HERDR_PANE_ID = "pane-1"
	assert_equal(true, navigator.is_herdr(), "detects HERDR_PANE_ID")

	reset_env()
	vim.env.HERDR_ENV = "1"
	assert_equal(true, navigator.is_herdr(), "detects HERDR_ENV")
end

local function test_focus_uses_explicit_pane_id()
	reset_env()
	vim.env.HERDR_PANE_ID = "pane-123"
	navigator.setup({ mappings = {} })

	with_stubbed_system(function(calls)
		navigator.focus_herdr_pane("left")
		assert_table(
			{ "herdr", "pane", "focus", "--direction", "left", "--pane", "pane-123" },
			calls[1],
			"focuses from explicit Herdr pane"
		)
	end)
end

local function test_focus_falls_back_to_current_pane()
	reset_env()
	vim.env.HERDR_SESSION = "session"
	navigator.setup({ mappings = {} })

	with_stubbed_system(function(calls)
		navigator.focus_herdr_pane("right")
		assert_table(
			{ "herdr", "pane", "focus", "--direction", "right", "--current" },
			calls[1],
			"focuses from current Herdr pane"
		)
	end)
end

local function test_neovim_window_move_wins_before_herdr_focus()
	reset_env()
	vim.env.HERDR_PANE_ID = "pane-123"
	navigator.setup({ mappings = {} })
	vim.cmd("silent! only")
	vim.cmd("vsplit")
	vim.cmd("wincmd l")

	with_stubbed_system(function(calls)
		navigator.navigate("h", "left")
		assert_equal(0, #calls, "does not call Herdr when Neovim moved to another window")
	end)

	vim.cmd("silent! only")
end

test_detects_any_herdr_marker()
test_focus_uses_explicit_pane_id()
test_focus_falls_back_to_current_pane()
test_neovim_window_move_wins_before_herdr_focus()

print("ok - herdr-navigator.nvim")
