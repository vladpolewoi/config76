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
						"--single-quote",
						"true",
						"--semi",
						"true",
						"--print-width",
						"100",
						"--tab-width",
						"2",
						"--end-of-line",
						"cr",
					},
				},
			},
		})

		vim.api.nvim_create_autocmd("BufWritePre", {
			pattern = "*",
			callback = function(args)
				local bufnr = args.buf
				require("conform").format({ bufnr = bufnr, lsp_fallback = true })

				-- -- Ensure final newline at EOF after formatting
				-- local lines = vim.api.nvim_buf_get_lines(bufnr, -2, -1, false)
				-- if #lines > 0 and lines[1] ~= "" then
				-- 	vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "" })
				-- end
			end,
		})
	end,
}
