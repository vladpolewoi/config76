return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("nvim-tree").setup({
			hijack_cursor = true,
			sync_root_with_cwd = true,
			view = {
				side = "right",
			},
			git = {
				enable = true,
				ignore = false,
				timeout = 500,
			},
			actions = {
				open_file = {
					quit_on_open = true,
				},
			},
			renderer = {
				highlight_opened_files = "none",
				full_name = true,
				group_empty = true,
				special_files = {},
				symlink_destination = false,
				indent_markers = {
					enable = true,
				},
				icons = {
					git_placement = "signcolumn",
					show = {
						file = true,
						folder = false,
						folder_arrow = false,
						git = true,
					},
				},
			},
		})
	end,
}
