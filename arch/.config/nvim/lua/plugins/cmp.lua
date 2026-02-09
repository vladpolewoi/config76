return {
	"saghen/blink.cmp",
	lazy = false,
	dependencies = {
		"rafamadriz/friendly-snippets",
		"giuxtaposition/blink-cmp-copilot",
	},
	version = "v0.*",
	opts = {
		keymap = {
			preset = "default",
			["<CR>"] = { "accept", "fallback" },
			["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide" },
			["<C-j>"] = { "select_next", "fallback" },
			["<C-k>"] = { "select_prev", "fallback" },
			["<C-u>"] = { "scroll_documentation_up", "fallback" },
			["<C-d>"] = { "scroll_documentation_down", "fallback" },
		},
		appearance = {
			use_nvim_cmp_as_default = true,
			nerd_font_variant = "mono",
		},
		sources = {
			default = { "copilot", "lsp", "path", "snippets", "buffer" },
			providers = {
				copilot = {
					name = "copilot",
					module = "blink-cmp-copilot",
					score_offset = 100,
					async = true,
				},
			},
		},
		completion = {
			accept = {
				auto_brackets = {
					enabled = true,
				},
			},
			menu = {
				border = "rounded",
				winhighlight = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 200,
				window = {
					border = "rounded",
				},
			},
			ghost_text = {
				enabled = true, -- Works great with Supermaven
			},
		},
		signature = {
			enabled = true,
			window = {
				border = "rounded",
			},
		},
	},
	opts_extend = { "sources.default" },
}
