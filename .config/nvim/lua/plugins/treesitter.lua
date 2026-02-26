return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false, -- Plugin does not support lazy-loading
	build = ":TSUpdate",
	config = function()
		-- Install parsers
		require("nvim-treesitter").install({
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
		})

		-- Enable treesitter highlighting for all filetypes
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				pcall(vim.treesitter.start)
			end,
		})

		-- Enable treesitter-based indentation
		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
