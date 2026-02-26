-- lua/plugins/colorscheme.lua
local theme_list = {}

-- Scan all files in lua/themes/
local theme_files = vim.fn.globpath(vim.fn.stdpath("config") .. "/lua/themes", "*.lua", false, true)

for _, file in ipairs(theme_files) do
	local filename = vim.fn.fnamemodify(file, ":t:r") -- name without extension
	local ok, spec = pcall(require, "themes." .. filename)
	if ok and spec then
		table.insert(theme_list, spec)
	else
		vim.notify("Failed loading theme: " .. filename, vim.log.levels.WARN)
	end
end

return theme_list
