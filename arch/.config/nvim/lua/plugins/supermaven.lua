return {
	"supermaven-inc/supermaven-nvim",
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<Tab>",
				clear_suggestion = "<C-x>",
				accept_word = "<C-l>",
			},
			ignore_filetypes = { "bigfile", "snacks_input", "snacks_notif" },
			color = {
				suggestion_color = "#808080",
				cterm = 244,
			},
		})
	end,
}
