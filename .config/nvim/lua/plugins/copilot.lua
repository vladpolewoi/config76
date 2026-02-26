return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = false, -- Using blink.cmp instead
				},
				panel = {
					enabled = false,
				},
				filetypes = {
					markdown = true,
					help = true,
				},
			})
		end,
	},
	{
		"giuxtaposition/blink-cmp-copilot",
		dependencies = {
			"zbirenbaum/copilot.lua",
		},
	},
}
