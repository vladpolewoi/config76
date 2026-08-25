-- Wraps long cell content *inside* table columns so rows fit the window.
-- Neovim has no per-line 'wrap', so soft-wrapped prose otherwise shreds
-- every table on screen. This owns pipe tables; render-markdown owns the rest.
return {
	"ice345/markdown-table-wrap.nvim",
	ft = { "markdown", "quarto", "rmd" },
	opts = {},
}
