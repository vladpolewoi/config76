return {
	"neovim/nvim-lspconfig",
	config = function()
		local lspconfig = require("lspconfig")
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

		vim.lsp.handlers["textDocument/signatureHelp"] =
			vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

		-- Setup your LSPs
		lspconfig.tailwindcss.setup({ capabilities = capabilities })

		-- Vue + TypeScript setup
		lspconfig.ts_ls.setup({
			capabilities = capabilities,
			init_options = {
				plugins = {
					{
						name = "@vue/typescript-plugin",
						location = vim.fn.stdpath("data")
							.. "/mason/packages/vue-language-server/node_modules/@vue/language-server",
						languages = { "vue" },
					},
				},
			},
			filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
		})

		lspconfig.volar.setup({
			capabilities = capabilities,
		})

		lspconfig.eslint.setup({
			capabilities = capabilities,
		})

		lspconfig.rust_analyzer.setup({ capabilities = capabilities })
		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
					telemetry = { enable = false },
				},
			},
		})
	end,
}
