return {
	"MeanderingProgrammer/render-markdown.nvim",
	opts = {
		-- markdown-table-wrap.nvim renders pipe tables instead -- it can wrap
		-- inside cells, which this renderer cannot.
		pipe_table = { enabled = false },
	},
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	ft = { "markdown" },
}
