return {
	"github/copilot.vim",
	event = "InsertEnter",
	config = function()
		vim.api.nvim_set_keymap("i", "<C-j>", "copilot#Next()", {
			expr = true,
			silent = true,
			noremap = true,
		})
		vim.api.nvim_set_keymap("i", "<C-k>", "copilot#Previous()", {
			expr = true,
			silent = true,
			noremap = true,
		})
	end,
}
