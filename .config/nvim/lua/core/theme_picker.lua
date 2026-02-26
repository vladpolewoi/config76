local M = {}

local function save_theme(name)
	print("Saving theme:", name)
	local path = vim.fn.stdpath("config") .. "/last_colorscheme.txt"
	local file = io.open(path, "w")
	if file then
		file:write(name)
		file:close()
	else
		vim.notify("Failed to save theme: " .. name, vim.log.levels.WARN)
	end
end

function M.pick_theme()
	local themes = {}

	-- Find all lua files in lua/themes folder
	local theme_files = vim.fn.globpath(vim.fn.stdpath("config") .. "/lua/themes", "*.lua", false, true)

	for _, file in ipairs(theme_files) do
		local filename = vim.fn.fnamemodify(file, ":t:r") -- get name without extension
		table.insert(themes, filename)
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values

	local function apply_selection(save)
		local selection = action_state.get_selected_entry()
		if selection then
			local theme_name = selection.value or selection[1]
			vim.print("Applying theme:", theme_name)

			vim.cmd.colorscheme(theme_name)

			if save then
				save_theme(theme_name)
			end
		else
			vim.notify("No selection", vim.log.levels.WARN)
		end
	end

	pickers
		.new({}, {
			prompt_title = "Pick Theme",
			finder = finders.new_table({
				results = themes,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, map)
				-- Move and preview
				map("i", "<C-j>", function()
					actions.move_selection_next(prompt_bufnr)
					apply_selection(false)
				end)
				map("i", "<C-k>", function()
					actions.move_selection_previous(prompt_bufnr)
					apply_selection(false)
				end)
				map("n", "<C-j>", function()
					actions.move_selection_next(prompt_bufnr)
					apply_selection(false)
				end)
				map("n", "<C-k>", function()
					actions.move_selection_previous(prompt_bufnr)
					apply_selection(false)
				end)

				-- Confirm and save
				actions.select_default:replace(function()
					apply_selection(true)
					actions.close(prompt_bufnr)
				end)

				return true
			end,
		})
		:find()
end

return M
