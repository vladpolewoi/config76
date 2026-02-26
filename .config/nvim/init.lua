require("config.lazy")
require("core.colorscheme_loader")

-- Machine-specific overrides
-- Create ~/.config/nvim/lua/local.lua for machine-specific settings (not tracked in repo)
pcall(require, "local")
