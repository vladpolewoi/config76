-- Tree
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- Save
vim.keymap.set("n", "<leader>w", ":w<CR>")

-- LSP Docs
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP Hover Docs" })

-- Jump
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })

-- Theme Picker
vim.keymap.set("n", "<C-t>", function()
	require("core.theme_picker").pick_theme()
end, { noremap = true, silent = true, desc = "Pick Colorscheme" })
