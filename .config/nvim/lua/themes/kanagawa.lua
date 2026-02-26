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
			overrides = function(colors)
				return {
					-- Make line numbers transparent
					LineNr = { bg = "NONE" },
					CursorLineNr = { bg = "NONE" },
					SignColumn = { bg = "NONE" },
					-- Make Telescope transparent
					TelescopeNormal = { bg = "NONE" },
					TelescopeBorder = { bg = "NONE" },
					TelescopePromptNormal = { bg = "NONE" },
					TelescopePromptBorder = { bg = "NONE" },
					TelescopeResultsNormal = { bg = "NONE" },
					TelescopeResultsBorder = { bg = "NONE" },
					TelescopePreviewNormal = { bg = "NONE" },
					TelescopePreviewBorder = { bg = "NONE" },
				}
			end,
		})
	end,
}
