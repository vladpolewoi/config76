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
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to Declaration" })
vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", { desc = "LSP References" })
vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, { desc = "Go to Type Definition" })

-- Theme Picker
vim.keymap.set("n", "<C-t>", function()
	require("core.theme_picker").pick_theme()
end, { noremap = true, silent = true, desc = "Pick Colorscheme" })

-- Global toggle for format on save
vim.g.format_on_save = true

-- Function to toggle it
function ToggleFormatOnSave()
	vim.g.format_on_save = not vim.g.format_on_save
	print("Format on save: " .. (vim.g.format_on_save and "ON" or "OFF"))
end

-- Map a hotkey (e.g., <leader>tf)
vim.keymap.set("n", "<leader>tf", ToggleFormatOnSave, { desc = "Toggle format on save" })
