return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				-- Core languages
				"lua",
				"vim",
				"vimdoc",
				-- Web development
				"typescript",
				"tsx",
				"javascript",
				"vue",
				"html",
				"css",
				-- Data formats
				"json",
				"yaml",
				"toml",
				-- Documentation
				"markdown",
				"markdown_inline",
				-- Systems
				"rust",
				"bash",
				-- Utilities
				"regex",
				"gitignore",
			},
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
			-- Incremental selection
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<CR>",
					node_incremental = "<CR>",
					scope_incremental = "<S-CR>",
					node_decremental = "<BS>",
				},
			},
		})
	end,
}
