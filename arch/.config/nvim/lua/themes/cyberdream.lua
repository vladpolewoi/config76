return {
	"scottmckendry/cyberdream.nvim",
	version = false,
	lazy = false,
	priority = 1000,
	config = function()
		require("cyberdream").setup({
			transparent = true,
			transparent_background_level = 1,
			italic_comments = true,
			hide_fillcharts = true,
			borderless_pickers = true,
		})
	end,
}
