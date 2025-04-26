local opt = vim.opt
local g = vim.g

g.mapleader = " "
g.maplocalleader = " "

-- General
opt.clipboard = "unnamedplus"
opt.swapfile = false
opt.completeopt = "menuone,noinsert,noselect"

-- UI
opt.number = true -- Show line number
opt.showmatch = true -- Highlight matching parenthesis
-- opt.foldmethod = 'marker'   -- Enable folding (default 'foldmarker')
-- opt.colorcolumn = '80'      -- Line lenght marker at 80 columns
opt.splitright = true -- Vertical split to the right
opt.splitbelow = true -- Horizontal split to the bottom
-- opt.ignorecase = true       -- Ignore case letters when search
-- opt.smartcase = true        -- Ignore lowercase for the whole pattern
opt.linebreak = true -- Wrap on word boundary
opt.termguicolors = true -- Enable 24-bit RGB colors
opt.laststatus = 3 -- Set global statusline
opt.cursorline = true -- Highlight line at cursor
opt.wrap = false -- No line wraps
g.have_nerd_font = true

-- Line Number
opt.number = true
opt.relativenumber = true

-- Tabs & Indentations
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Shift 4 spaces when tab
opt.tabstop = 2 -- 1 tab == 4 spaces
opt.smartindent = true -- Autoindent new lines

-- Other
opt.scrolloff = 20

vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NormalNC guibg=NONE ctermbg=NONE
  highlight SignColumn guibg=NONE ctermbg=NONE
  highlight VertSplit guibg=NONE ctermbg=NONE
  highlight EndOfBuffer guibg=NONE ctermbg=NONE
]])

-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none", fg = "#24837B" }) -- Flexoki yellow border
vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })
vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#1E1E1E", fg = "#FFFCF0" }) -- selected
vim.api.nvim_set_hl(0, "CmpBorder", { bg = "none", fg = "#205EA6" }) -- if you use a separate border group
vim.api.nvim_set_hl(0, "LspInfoBorder", { bg = "#1E1E1E", fg = "#AD8301" })

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
