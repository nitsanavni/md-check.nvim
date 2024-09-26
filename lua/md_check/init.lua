-- Define the plugin module
local M = {}

-- Default configuration
local default_config = {
	keymap = "<leader>mx", -- Default key mapping
	command = "ToggleCheckbox", -- Default command name
}

-- Function to toggle Markdown checkbox
local function toggle_checkbox()
	-- Get the current line
	local line = vim.api.nvim_get_current_line()

	-- Pattern to match a checkbox at the start of the line
	local checkbox_pattern = "^(%s*)([%-%+%*])%s%[([xX ])%](.*)$"

	-- Try matching a checkbox
	local indent, bullet, state, rest = line:match(checkbox_pattern)

	if indent then
		-- Toggle the checkbox
		local new_state
		if state == " " then
			new_state = "x"
		else
			new_state = " "
		end
		local new_line = indent .. bullet .. " [" .. new_state .. "]" .. rest
		vim.api.nvim_set_current_line(new_line)
	else
		-- Not a checkbox
		-- Try matching a bullet point
		local bullet_pattern = "^(%s*)([%-%+%*])%s+(.*)$"
		local indent, bullet, rest = line:match(bullet_pattern)
		if indent then
			-- It's a bullet point, convert to checkbox
			local new_line = indent .. bullet .. " [ ] " .. rest
			vim.api.nvim_set_current_line(new_line)
		else
			-- Not a bullet point, make it a checkbox with default bullet '- [ ]'
			local indent = line:match("^(%s*)")
			local rest = line:sub(#indent + 1)
			local new_line = indent .. "- [ ] " .. rest
			vim.api.nvim_set_current_line(new_line)
		end
	end
end

-- Setup function to configure the plugin
function M.setup(user_config)
	-- Merge user configuration with default configuration
	local config = vim.tbl_extend("force", default_config, user_config or {})

	-- Create an augroup for the autocmds
	local augroup = vim.api.nvim_create_augroup("MarkdownCheckboxToggle", { clear = true })

	-- Set up autocmd for Markdown files
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "markdown",
		group = augroup,
		callback = function()
			-- Create buffer-local keymap for the configured key
			vim.api.nvim_buf_set_keymap(
				0,
				"n",
				config.keymap,
				':lua require("md_check").toggle()<CR>',
				{ noremap = true, silent = true }
			)
			-- Create buffer-local command with the configured name
			vim.api.nvim_buf_create_user_command(0, config.command, function()
				toggle_checkbox()
			end, { desc = "Toggle Markdown checkbox under cursor" })
		end,
	})
end

-- Expose the toggle function
M.toggle = toggle_checkbox

-- Return the module
return M
