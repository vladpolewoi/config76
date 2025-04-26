local function load_last_colorscheme()
	local path = vim.fn.stdpath("config") .. "/last_colorscheme.txt"
	local file = io.open(path, "r")
	if not file then
		vim.notify("No saved colorscheme found", vim.log.levels.INFO)
		return
	end

	local theme_name = file:read("*l")
	file:close()

	if theme_name and #theme_name > 0 then
		vim.notify("Loading theme: " .. theme_name)
		local ok, err = pcall(vim.cmd.colorscheme, theme_name)
		if not ok then
			vim.notify("Failed to load theme: " .. theme_name, vim.log.levels.ERROR)
			vim.cmd.colorscheme("habmax")
		end
	else
		vim.notify("Empty theme name in save file", vim.log.levels.WARN)
	end
end

load_last_colorscheme()
