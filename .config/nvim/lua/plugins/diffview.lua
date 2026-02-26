return {
	"sindrets/diffview.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles" },
	keys = {
		{ "<leader>df", "<cmd>DiffviewOpen<cr>", desc = "Open Git Diff View" },
		{ "<leader>dc", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
		-- Git file changes
		{ "<leader>gs", "<cmd>Telescope git_status<cr>", desc = "Git Status" },
		{ "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git Commits" },
		{ "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Git Branches" },
		{ "<leader>gB", "<cmd>Telescope git_bcommits<cr>", desc = "Git Buffer Commits" },
	},
	config = true, -- uses default config
}
