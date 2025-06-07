return {
	"mattn/emmet-vim",
	event = "InsertEnter",
	config = function()
		vim.g.user_emmet_leader_key = "<C-y>"
		vim.cmd([[
      autocmd FileType html,css,javascript,javascriptreact,typescriptreact EmmetInstall
    ]])
	end,
}
