local M = {}

local defaults = {
	herdr_executable = "herdr",
	mappings = {
		left = "<M-h>",
		down = "<M-j>",
		up = "<M-k>",
		right = "<M-l>",
	},
}

local directions = {
	left = { vim = "h", herdr = "left" },
	down = { vim = "j", herdr = "down" },
	up = { vim = "k", herdr = "up" },
	right = { vim = "l", herdr = "right" },
}

local config = vim.deepcopy(defaults)

local function merge_config(opts)
	opts = opts or {}
	config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts)
	return config
end

function M.is_herdr()
	return vim.env.HERDR_SESSION ~= nil or vim.env.HERDR_PANE_ID ~= nil or vim.env.HERDR_ENV ~= nil
end

function M.focus_herdr_pane(herdr_direction)
	if vim.fn.executable(config.herdr_executable) ~= 1 then
		return
	end

	local pane_id = vim.env.HERDR_PANE_ID
	if pane_id and pane_id ~= "" then
		vim.fn.system({ config.herdr_executable, "pane", "focus", "--direction", herdr_direction, "--pane", pane_id })
	else
		vim.fn.system({ config.herdr_executable, "pane", "focus", "--direction", herdr_direction, "--current" })
	end
end

function M.navigate(vim_direction, herdr_direction)
	local current_window = vim.fn.winnr()
	local moved_in_vim = pcall(vim.cmd, "wincmd " .. vim_direction)
	if moved_in_vim and vim.fn.winnr() ~= current_window then
		return
	end

	M.focus_herdr_pane(herdr_direction)
end

function M.navigate_terminal(vim_direction, herdr_direction)
	vim.cmd.stopinsert()
	M.navigate(vim_direction, herdr_direction)
end

function M.left()
	M.navigate(directions.left.vim, directions.left.herdr)
end

function M.down()
	M.navigate(directions.down.vim, directions.down.herdr)
end

function M.up()
	M.navigate(directions.up.vim, directions.up.herdr)
end

function M.right()
	M.navigate(directions.right.vim, directions.right.herdr)
end

function M.setup(opts)
	merge_config(opts)

	if not M.is_herdr() then
		return
	end

	for name, mapping in pairs(config.mappings) do
		local direction = directions[name]
		if direction and mapping and mapping ~= "" then
			vim.keymap.set("n", mapping, function()
				M.navigate(direction.vim, direction.herdr)
			end, { desc = "Navigate " .. name })
			vim.keymap.set("t", mapping, function()
				M.navigate_terminal(direction.vim, direction.herdr)
			end, { desc = "Navigate " .. name })
		end
	end
end

return M
