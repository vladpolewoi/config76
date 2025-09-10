return {
	"folke/noice.nvim",
	dependencies = { "rcarriga/nvim-notify", "MunifTanjim/nui.nvim" },
	config = function()
		-- make notify quick and subtle
		require("notify").setup({
			timeout = 1200, -- ms
			stages = "fade",
			render = "compact",
			top_down = false,
			background_colour = "#000000",
		})
		vim.notify = require("notify")

		require("noice").setup({
			-- cut most LSP chatter
			lsp = {
				progress = { enabled = false }, -- <- big win
				hover = { enabled = true },
				signature = { enabled = true },
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true,
				},
			},

			-- quieter default views + quicker disappearance
			views = {
				notify = { timeout = 1200, replace = true },
				mini = { timeout = 800, win_options = { winblend = 10 } },
				cmdline_popup = {
					position = { row = "30%", col = "50%" },
					size = { width = 60, height = "auto" },
					border = { style = "rounded" },
					win_options = { winblend = 10 },
				},
				popupmenu = { backend = "cmp" }, -- if you use nvim-cmp
			},

			-- route noisy stuff to mini or drop it entirely
			routes = {
				-- file written, yank counts, undo/redo position, etc. -> mini
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
							{ find = "written" },
							{ find = "yanked" },
						},
					},
					view = "mini",
				},
				-- hide showmode and showcmd echoes
				{ filter = { event = "msg_showmode" }, opts = { skip = true } },
				{ filter = { event = "msg_showcmd" }, opts = { skip = true } },
				-- silence LSP progress completely
				{ filter = { event = "lsp", kind = "progress" }, opts = { skip = true } },
				-- long messages go to split, not as blocking popup
				{ filter = { event = "msg_show", min_height = 8 }, view = "split" },
			},

			presets = {
				bottom_search = false, -- keep search inline
				command_palette = true,
				long_message_to_split = true,
				lsp_doc_border = true,
			},

			-- default message routing
			messages = {
				view = "mini",
				view_error = "notify",
				view_warn = "notify",
				view_history = "messages",
				view_search = false,
			},
		})
	end,
}
