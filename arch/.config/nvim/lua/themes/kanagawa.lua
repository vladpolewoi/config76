return {
	"rebelot/kanagawa.nvim",
	version = false,
	lazy = false,
	priority = 1000,
	config = function()
		require("kanagawa").setup({
			transparent = true,
			undercurl = true,
			commentStyle = { italic = true },
			background = {
				dark = "wave",
			},
		})
	end,
}
