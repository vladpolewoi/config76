-- Tree
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Save
vim.keymap.set("n", "<leader>w", "<cmd>silent! write<CR>", { desc = "Silent Save" })

-- LSP Docs
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover Docs" })
vim.keymap.set("n", "<leader>d", function()
	vim.diagnostic.open_float(nil, { focus = true })
end, { desc = "Show diagnostic under cursor" })

-- Jump
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", { desc = "LSP References" })

-- Theme Picker
vim.keymap.set("n", "<C-t>", function()
	require("core.theme_picker").pick_theme()
end, { noremap = true, silent = true, desc = "Pick Colorscheme" })
