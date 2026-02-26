-- Charm colorscheme loader
-- Loads the standalone theme from colors/charm.lua
return {
  dir = vim.fn.stdpath("config"),  -- dummy local plugin
  name = "charm",
  priority = 1000,
  config = function()
    -- Theme is already available via colors/charm.lua
    -- This file just makes it appear in the theme picker
  end,
}
