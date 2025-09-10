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
					require_cwd = true,
					cwd = require("conform.util").root_file({
						".prettierrc",
						".prettierrc.json",
						".prettierrc.yml",
						".prettierrc.yaml",
						".prettierrc.json5",
						".prettierrc.js",
						".prettierrc.cjs",
						".prettierrc.mjs",
						".prettierrc.toml",
						"prettier.config.js",
						"prettier.config.cjs",
						"prettier.config.mjs",
					}),
					prepend_args = {
						"--single-quote",
						"true",
						"--semi",
						"true",
						"--print-width",
						"100",
						"--tab-width",
						"2",
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
				-- -- Ensure final newline at EOF after formatting
				-- local lines = vim.api.nvim_buf_get_lines(bufnr, -2, -1, false)
				-- if #lines > 0 and lines[1] ~= "" then
				-- 	vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { "" })
				-- end
			end,
		})
	end,
}
