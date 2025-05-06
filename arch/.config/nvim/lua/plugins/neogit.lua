return {
	"NeogitOrg/neogit",
	dependencies = {
		"nvim-lua/plenary.nvim", -- required
		"sindrets/diffview.nvim", -- optional - Diff integration

		"nvim-telescope/telescope.nvim", -- optional
	},
	keys = {
		{
			"<leader>gg",
			function()
				vim.cmd("DiffviewClose") -- closes Diffview if it's open
				vim.cmd("enew") -- creates a brand-new buffer
				vim.schedule(function()
					require("neogit").open()
				end)
			end,
			desc = "Safe Neogit after Diffview",
		},
	},
	config = function()
		require("neogit").setup({ kind = "tab" })

		-- Section headers
		vim.api.nvim_set_hl(0, "NeogitSectionHeader", { fg = "#F2F0E5", bold = true })
		vim.api.nvim_set_hl(0, "NeogitSectionHeaderHighlight", { fg = "#F2F0E5", bg = "#262421", bold = true })

		-- Hunk headers
		vim.api.nvim_set_hl(0, "NeogitHunkHeader", { fg = "#AD8301", bg = "#1D1C19", bold = true })
		vim.api.nvim_set_hl(0, "NeogitHunkHeaderHighlight", { fg = "#AD8301", bg = "#262421", bold = true })

		-- Diff lines
		vim.api.nvim_set_hl(0, "NeogitDiffAdd", { fg = "#66800B", bg = "NONE" })
		vim.api.nvim_set_hl(0, "NeogitDiffDelete", { fg = "#B33A3A", bg = "NONE" })
		vim.api.nvim_set_hl(0, "NeogitDiffContext", { fg = "#8C867C", bg = "NONE" })

		-- Cursor line and visual selection
		vim.api.nvim_set_hl(0, "CursorLine", { bg = "#262421" })
		vim.api.nvim_set_hl(0, "Visual", { bg = "#3E3A31" })
	end,
}
