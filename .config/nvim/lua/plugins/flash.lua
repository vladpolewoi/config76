return {
	"folke/flash.nvim",
	event = "VeryLazy",
	-- @type Flash.Config
	opts = {},
	keys = {
		-- Jump forward
		{
			"s",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash jump",
		},
		-- Treesitter search
		{
			"S",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
		},
		-- Remote (cross-window jump)
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote Flash",
		},
		-- Toggle Flash Search
		{
			"R",
			mode = { "n", "o", "x" },
			function()
				require("flash").treesitter_search()
			end,
			desc = "Flash Treesitter Search",
		},
	},
}
