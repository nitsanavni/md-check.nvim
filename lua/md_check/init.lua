-- Define the plugin module
local M = {}

-- Default configuration
local default_config = {
	keymap = "<leader>c", -- Default key mapping
	command = "ToggleCheckbox", -- Default command name
}

-- Function to toggle Markdown checkbox
local function toggle_checkbox()
	-- Get the current line
	local line = vim.api.nvim_get_current_line()

	-- Pattern to match a checkbox at the start of the line
	local checkbox_pattern = "^%s*[%-%+%*]%s%[[xX ]%]"

	-- Find the position of the checkbox in the line
	local s, e = line:find(checkbox_pattern)

	if s then
		-- Extract the checkbox part
		local checkbox = line:sub(s, e)
		-- Toggle the checkbox
		if checkbox:match("%[[ ]%]") then
			checkbox = checkbox:gsub("%[[ ]%]", "[x]")
		elseif checkbox:match("%[[xX]%]") then
			checkbox = checkbox:gsub("%[[xX]%]", "[ ]")
		else
			-- Not a checkbox, do nothing
			return
		end
		-- Replace the old checkbox with the new one
		local new_line = line:sub(1, s - 1) .. checkbox .. line:sub(e + 1)
		vim.api.nvim_set_current_line(new_line)
	else
		print("No checkbox found at the start of this line.")
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
				':lua require("markdown_checkbox_toggle").toggle()<CR>',
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
