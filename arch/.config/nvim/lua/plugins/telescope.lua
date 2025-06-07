return {
	"nvim-telescope/telescope.nvim",
	version = "*",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
	},
	config = function()
		require("telescope").setup({
			pickers = {
				find_files = {
					hidden = true,
				},
				live_grep = {
					additional_args = function()
						return { "--hidden" }
					end,
				},
			},
			defaults = {
				layout_config = {
					horizontal = { preview_width = 0.55 },
					prompt_position = "bottom",
				},
				sorting_strategy = "ascending",
				winblend = 10, -- transparency
				borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
				file_ignore_patterns = {},
				mappings = {
					i = {
						["<C-j>"] = require("telescope.actions").move_selection_next,
						["<C-k>"] = require("telescope.actions").move_selection_previous,
						["<C-n>"] = false, -- unbind old
						["<C-p>"] = false,
					},
					n = {
						["<C-j>"] = require("telescope.actions").move_selection_next,
						["<C-k>"] = require("telescope.actions").move_selection_previous,
						["<C-n>"] = false,
						["<C-p>"] = false,
					},
				},
			},
		})

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep Text" })
		vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Resume" })
		vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Open Buffers" })
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
		vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Recent Files" })
		vim.keymap.set("n", "<leader>fw", require("telescope.builtin").grep_string, { desc = "Find word under cursor" })
		vim.keymap.set("n", "<leader>gs", require("telescope.builtin").git_status, { desc = "Git Status" })
	end,
}
