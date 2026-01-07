local opt = vim.opt
local g = vim.g

g.mapleader = " "
g.maplocalleader = " "

-- General
opt.clipboard = "unnamedplus"
opt.swapfile = false
opt.completeopt = "menuone,noinsert,noselect"
opt.autoread = true

-- UI
opt.number = true
opt.relativenumber = true
opt.showmatch = true -- Highlight matching parenthesis
opt.splitright = true -- Vertical split to the right
opt.splitbelow = true -- Horizontal split to the bottom
opt.linebreak = true -- Wrap on word boundary
opt.termguicolors = true -- Enable 24-bit RGB colors
opt.laststatus = 3 -- Set global statusline
opt.cursorline = true -- Highlight line at cursor
opt.wrap = false -- No line wraps
g.have_nerd_font = true

-- Tabs & Indentations
opt.expandtab = true -- Use spaces instead of tabs
opt.shiftwidth = 2 -- Shift 4 spaces when tab
opt.tabstop = 2 -- 1 tab == 4 spaces
opt.smartindent = true -- Autoindent new lines
opt.endofline = true
opt.fixendofline = true

-- Other
opt.scrolloff = 20
