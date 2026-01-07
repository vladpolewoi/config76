return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				vue = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				css = { "prettier" },
				html = { "prettier" },
				markdown = { "prettier" },
				yaml = { "prettier" },
				rust = { "rustfmt" },
				sh = { "shfmt" },
			},
			formatters = {
				prettier = {
					prepend_args = {
						"--single-quote=true",
						"--semi=true",
						"--print-width=100",
						"--tab-width=2",
					},
				},
			},
		})

		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				local bufnr = args.buf
				if vim.g.format_on_save then
					require("conform").format({ bufnr = bufnr, lsp_fallback = true })
				end
			end,
		})
	end,
}
