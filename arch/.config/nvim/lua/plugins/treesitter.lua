return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"lua",
					"typescript",
					"tsx",
					"json",
					"html",
					"css",
					"markdown",
				},
				highlight = { enable = true },
				indent = { enable = true },
				playground = {
					enable = true,
					updatetime = 25,
					persist_queries = false,
				},
			})
		end,
	},
	{
		"nvim-treesitter/playground",
		cmd = "TSPlaygroundToggle",
		keys = {
			{ "<leader>tp", "<cmd>TSPlaygroundToggle<cr>", desc = "Toggle Treesitter Playground" },
		},
	},
}
