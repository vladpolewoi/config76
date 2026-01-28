return {
	"williamboman/mason.nvim",
	dependencies = {
		"williamboman/mason-lspconfig.nvim",
	},
	config = function()
		require("mason").setup({
			ui = {
				border = "rounded",
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		require("mason-lspconfig").setup({
			-- Auto-install these LSP servers
			ensure_installed = {
				"lua_ls", -- Lua
				"ts_ls", -- TypeScript/JavaScript
				"vue_ls", -- Vue Language Server (formerly volar)
				"eslint", -- ESLint
				"rust_analyzer", -- Rust
				"tailwindcss", -- Tailwind CSS
			},
			-- Auto-install LSPs when you open a file
			automatic_installation = true,
		})
	end,
}
