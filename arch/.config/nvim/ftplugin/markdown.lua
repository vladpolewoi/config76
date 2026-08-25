-- Prose files: soft-wrap instead of running off screen.
-- Display only -- the file on disk keeps its long lines.
-- Tables are handled by markdown-table-wrap.nvim, which wraps inside cells.
local opt = vim.opt_local

opt.wrap = true
opt.linebreak = true -- break at word boundaries, not mid-word
opt.breakindent = true -- continuation lines keep the list/quote indent
opt.showbreak = "↳ " -- mark continuation lines
opt.list = false -- listchars break linebreak

-- Move by visual line, so j/k/0/$ behave as they look
local map = function(lhs, rhs)
	vim.keymap.set({ "n", "x" }, lhs, rhs, { buffer = true, expr = true, silent = true })
end
map("j", function() return vim.v.count == 0 and "gj" or "j" end)
map("k", function() return vim.v.count == 0 and "gk" or "k" end)
map("0", "g0")
map("$", "g$")

vim.keymap.set("n", "<leader>tw", function()
	vim.wo.wrap = not vim.wo.wrap
	vim.notify("wrap " .. (vim.wo.wrap and "on" or "off"))
end, { buffer = true, desc = "Markdown: toggle wrap" })
