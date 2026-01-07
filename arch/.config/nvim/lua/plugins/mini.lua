return {
	"echasnovski/mini.nvim",
	config = function()
		-- Auto-pairs: automatically close brackets, quotes, etc.
		require("mini.pairs").setup({})

		-- Better text objects (around/inside)
		-- Examples:
		-- - viq: select inside quotes
		-- - daf: delete around function
		-- - cib: change inside brackets
		require("mini.ai").setup({
			n_lines = 500,
		})
	end,
}
