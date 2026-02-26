-- ~/.config/nvim/lua/persist_colorscheme.lua (load with VeryLazy)
local state_dir = vim.fn.stdpath("state") .. "/colors"
vim.fn.mkdir(state_dir, "p")
local save_file = state_dir .. "/last_colorscheme.txt"

local function save_scheme(name)
	local f = io.open(save_file, "w")
	if f then
		f:write(name)
		f:close()
	end
end

local function load_scheme()
	local f = io.open(save_file, "r")
	if not f then
		return
	end
	local name = f:read("*l")
	f:close()
	if name and #name > 0 then
		local ok = pcall(vim.cmd.colorscheme, name)
		if not ok then
			pcall(vim.cmd.colorscheme, "habamax")
		end
	end
end

-- Save whenever colorscheme changes
vim.api.nvim_create_augroup("PersistColorscheme", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
	group = "PersistColorscheme",
	callback = function(args)
		save_scheme(args.match)
	end,
})

-- Load after plugins/themes are ready
vim.api.nvim_create_autocmd("VimEnter", {
	group = "PersistColorscheme",
	callback = load_scheme,
})
