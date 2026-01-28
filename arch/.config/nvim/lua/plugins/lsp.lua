return {
	"neovim/nvim-lspconfig",
	config = function()
		local capabilities = require("blink.cmp").get_lsp_capabilities()

		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })

		vim.lsp.handlers["textDocument/signatureHelp"] =
			vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

		-- Get vue language server path
		local vue_language_server_path = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server"

		-- Setup LSP servers using new vim.lsp API (Neovim 0.11+)

		-- Tailwind CSS
		vim.lsp.enable("tailwindcss")

		-- TypeScript server with Vue plugin (REQUIRED for Vue support)
		vim.lsp.config.ts_ls = vim.tbl_deep_extend("force", vim.lsp.config.ts_ls, {
			capabilities = capabilities,
			init_options = {
				plugins = {
					{
						name = "@vue/typescript-plugin",
						location = vue_language_server_path .. "/node_modules/@vue/language-server",
						languages = { "vue" },
					},
				},
			},
			filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
			settings = {
				typescript = {
					suggest = {
						autoImports = true,
					},
					preferences = {
						importModuleSpecifier = "relative",
					},
				},
				javascript = {
					suggest = {
						autoImports = true,
					},
				},
			},
		})
		vim.lsp.enable("ts_ls")

		-- Vue Language Server (vue_ls, formerly volar)
		vim.lsp.config.vue_ls = vim.tbl_deep_extend("force", vim.lsp.config.vue_ls, {
			capabilities = capabilities,
			filetypes = { "vue" },
			init_options = {
				vue = {
					hybridMode = false,
				},
				typescript = {
					tsdk = vim.fn.stdpath("data") .. "/mason/packages/typescript-language-server/node_modules/typescript/lib",
				},
			},
		})
		vim.lsp.enable("vue_ls")

		-- ESLint with auto-fix on save
		vim.lsp.config.eslint = vim.tbl_deep_extend("force", vim.lsp.config.eslint, {
			capabilities = capabilities,
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
				"vue",
			},
			settings = {
				workingDirectory = { mode = "auto" },
				format = false,
				validate = "on",
			},
			on_attach = function(client, bufnr)
				-- Auto-fix on save
				vim.api.nvim_create_autocmd("BufWritePre", {
					buffer = bufnr,
					callback = function()
						if vim.g.format_on_save then
							vim.lsp.buf.code_action({
								context = { only = { "source.fixAll.eslint" }, diagnostics = {} },
								apply = true,
							})
						end
					end,
				})
			end,
		})
		vim.lsp.enable("eslint")

		-- Rust Analyzer
		vim.lsp.enable("rust_analyzer")

		-- Lua Language Server
		vim.lsp.config.lua_ls = vim.tbl_deep_extend("force", vim.lsp.config.lua_ls, {
			capabilities = capabilities,
			settings = {
				Lua = {
					diagnostics = { globals = { "vim" } },
					telemetry = { enable = false },
				},
			},
		})
		vim.lsp.enable("lua_ls")
	end,
}
