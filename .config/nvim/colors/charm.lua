-- Charm colorscheme - Charmbracelet palette with strategic bold/italic
-- Pink-centric warm tones inspired by Charmbracelet tools
-- Usage: :colorscheme charm

vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
  vim.cmd("syntax reset")
end
vim.g.colors_name = "charm"
vim.o.termguicolors = true

-------------------------------------------------------------------------------
-- PALETTE - Expanded Charmbracelet colors
-------------------------------------------------------------------------------
local p = {
  -- Backgrounds
  bg = "#1a1a24",
  bg_dim = "#151519",
  bg_dark = "#121216",
  bg_light = "#252530",
  bg_lighter = "#353545",
  bg_search = "#3d4059",

  -- Foregrounds
  fg = "#D0D0D0",              -- main text
  fg_dim = "#A0A0A0",          -- secondary
  fg_dark = "#6A9589",         -- comments - muted teal
  fg_reverse = "#1a1a24",

  -- Core Charmbracelet colors
  pink = "#FF87D7",            -- CHARM ACCENT - JSX tags, operators
  pink_dim = "#D787AF",        -- softer pink
  red = "#FD5B5B",             -- errors, builtins
  orange = "#FF875F",          -- numbers, constants
  peach = "#FFAF87",           -- parameters
  yellow = "#FFD75F",          -- attributes, labels
  gold = "#D7AF5F",            -- dimmed yellow
  green = "#00D787",           -- strings
  lime = "#87D787",            -- string escapes
  teal = "#5FAFAF",            -- properties, fields
  cyan = "#87D7D7",            -- functions
  sky = "#87AFD7",             -- variables
  blue = "#5F87D7",            -- modules
  purple = "#AF87FF",          -- keywords
  lavender = "#D7AFFF",        -- types
  magenta = "#D787D7",         -- constructors

  -- Diagnostics
  diag_error = "#FD5B5B",
  diag_warn = "#FFAF5F",
  diag_info = "#5FAFAF",
  diag_hint = "#5F87AF",

  -- Diff
  diff_add = "#00D787",
  diff_delete = "#FD5B5B",
  diff_change = "#FFAF5F",

  none = "NONE",
}

vim.g.charm_palette = p

local hi = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-------------------------------------------------------------------------------
-- EDITOR UI
-------------------------------------------------------------------------------
hi("Normal", { fg = p.fg, bg = p.none })
hi("NormalNC", { fg = p.fg, bg = p.none })
hi("NormalFloat", { fg = p.fg, bg = p.bg_dark })
hi("FloatBorder", { fg = p.pink, bg = p.bg_dark })
hi("FloatTitle", { fg = p.pink, bg = p.bg_dark, bold = true })

hi("Cursor", { fg = p.fg_reverse, bg = p.fg })
hi("CursorLine", { bg = p.bg_light })
hi("CursorLineNr", { fg = p.pink, bold = true })
hi("CursorColumn", { bg = p.bg_light })

hi("LineNr", { fg = p.bg_lighter })
hi("SignColumn", { bg = p.none })
hi("FoldColumn", { fg = p.fg_dark })
hi("Folded", { fg = p.fg_dim, bg = p.bg_light })

hi("ColorColumn", { bg = p.bg_light })
hi("VertSplit", { fg = p.bg_lighter })
hi("WinSeparator", { fg = p.bg_lighter })

hi("StatusLine", { fg = p.fg, bg = p.bg_dark })
hi("StatusLineNC", { fg = p.fg_dark, bg = p.bg_dark })
hi("TabLine", { fg = p.fg_dark, bg = p.bg_dark })
hi("TabLineFill", { bg = p.bg_dark })
hi("TabLineSel", { fg = p.fg, bg = p.bg, bold = true })

hi("NonText", { fg = p.bg_lighter })
hi("SpecialKey", { fg = p.bg_lighter })
hi("EndOfBuffer", { fg = p.bg })
hi("Whitespace", { fg = p.bg_lighter })

hi("Pmenu", { fg = p.fg, bg = p.bg_dark })
hi("PmenuSel", { fg = p.fg_reverse, bg = p.pink })
hi("PmenuSbar", { bg = p.bg_light })
hi("PmenuThumb", { bg = p.pink })
hi("WildMenu", { fg = p.fg_reverse, bg = p.pink })

-------------------------------------------------------------------------------
-- SEARCH & SELECTION
-------------------------------------------------------------------------------
hi("Search", { fg = p.fg, bg = p.bg_search })
hi("IncSearch", { fg = p.fg_reverse, bg = p.pink })
hi("CurSearch", { fg = p.fg_reverse, bg = p.pink, bold = true })
hi("Substitute", { fg = p.fg_reverse, bg = p.red })
hi("Visual", { bg = p.bg_search })
hi("VisualNOS", { bg = p.bg_search })
hi("MatchParen", { fg = p.orange, bold = true })

-------------------------------------------------------------------------------
-- DIAGNOSTICS
-------------------------------------------------------------------------------
hi("DiagnosticError", { fg = p.diag_error })
hi("DiagnosticWarn", { fg = p.diag_warn })
hi("DiagnosticInfo", { fg = p.diag_info })
hi("DiagnosticHint", { fg = p.diag_hint })
hi("DiagnosticUnderlineError", { undercurl = true, sp = p.diag_error })
hi("DiagnosticUnderlineWarn", { undercurl = true, sp = p.diag_warn })
hi("DiagnosticUnderlineInfo", { undercurl = true, sp = p.diag_info })
hi("DiagnosticUnderlineHint", { undercurl = true, sp = p.diag_hint })

hi("ErrorMsg", { fg = p.diag_error, bold = true })
hi("WarningMsg", { fg = p.diag_warn })
hi("MoreMsg", { fg = p.green })
hi("Question", { fg = p.cyan })
hi("Title", { fg = p.pink, bold = true })
hi("Directory", { fg = p.cyan })

-------------------------------------------------------------------------------
-- DIFF
-------------------------------------------------------------------------------
hi("DiffAdd", { fg = p.diff_add, bg = p.bg_light })
hi("DiffChange", { fg = p.diff_change, bg = p.bg_light })
hi("DiffDelete", { fg = p.diff_delete, bg = p.bg_light })
hi("DiffText", { fg = p.fg, bg = p.bg_search, bold = true })
hi("diffAdded", { fg = p.diff_add })
hi("diffChanged", { fg = p.diff_change })
hi("diffRemoved", { fg = p.diff_delete })

-------------------------------------------------------------------------------
-- SYNTAX - Kanagawa-inspired with bold/italic
-------------------------------------------------------------------------------

-- COMMENTS - italic, distinct
hi("Comment", { fg = p.fg_dark, italic = true })

-- STRINGS - green (content/data)
hi("String", { fg = p.green })
hi("Character", { fg = p.green })

-- NUMBERS/CONSTANTS - orange
hi("Number", { fg = p.orange })
hi("Float", { fg = p.orange })
hi("Constant", { fg = p.orange })
hi("Boolean", { fg = p.orange, bold = true })       -- bold

-- KEYWORDS - purple, italic
hi("Statement", { fg = p.purple, italic = true })
hi("Conditional", { fg = p.purple, italic = true })
hi("Repeat", { fg = p.purple, italic = true })
hi("Label", { fg = p.purple })
hi("Keyword", { fg = p.purple, italic = true })
hi("Exception", { fg = p.red, italic = true })
hi("PreProc", { fg = p.pink })
hi("Include", { fg = p.purple, italic = true })
hi("Define", { fg = p.pink })
hi("Macro", { fg = p.pink })
hi("PreCondit", { fg = p.pink })

-- TYPES - lavender
hi("Type", { fg = p.lavender })
hi("StorageClass", { fg = p.purple, italic = true })
hi("Structure", { fg = p.lavender })
hi("Typedef", { fg = p.lavender })

-- IDENTIFIERS
hi("Identifier", { fg = p.sky })
hi("Function", { fg = p.cyan, bold = true })        -- functions bold

-- OPERATORS/PUNCTUATION
hi("Operator", { fg = p.pink })                     -- charm pink for operators
hi("Delimiter", { fg = p.gold })
hi("Special", { fg = p.lime })
hi("SpecialChar", { fg = p.lime, bold = true })     -- escape chars bold
hi("Tag", { fg = p.pink })

-- MISC
hi("Underlined", { fg = p.cyan, underline = true })
hi("Bold", { bold = true })
hi("Italic", { italic = true })
hi("Error", { fg = p.diag_error, bold = true })
hi("Todo", { fg = p.fg_reverse, bg = p.diag_info, bold = true })

-------------------------------------------------------------------------------
-- TREESITTER - Kanagawa-style with bold/italic
-------------------------------------------------------------------------------

-- IDENTIFIERS
hi("@variable", { fg = p.sky })
hi("@variable.builtin", { fg = p.red, italic = true })    -- this, self italic
hi("@variable.parameter", { fg = p.peach, italic = true })
hi("@variable.member", { fg = p.teal })

hi("@property", { fg = p.teal })
hi("@field", { fg = p.teal })

-- CONSTANTS
hi("@constant", { fg = p.orange })
hi("@constant.builtin", { fg = p.orange, bold = true })   -- true, false bold
hi("@constant.macro", { fg = p.gold })

-- MODULES
hi("@module", { fg = p.blue })

-- FUNCTIONS - cyan, bold for definitions
hi("@function", { fg = p.cyan, bold = true })
hi("@function.builtin", { fg = p.cyan })
hi("@function.call", { fg = p.cyan })
hi("@function.macro", { fg = p.purple })
hi("@function.method", { fg = p.cyan, bold = true })
hi("@function.method.call", { fg = p.cyan })

hi("@constructor", { fg = p.magenta, bold = true })        -- JSX components bold

hi("@label", { fg = p.yellow })

-- STRINGS - green
hi("@string", { fg = p.green })
hi("@string.documentation", { fg = p.fg_dark, italic = true })
hi("@string.escape", { fg = p.lime, bold = true })        -- escapes bold
hi("@string.regex", { fg = p.gold })
hi("@string.special", { fg = p.lime })
hi("@string.special.url", { fg = p.cyan, underline = true })

hi("@character", { fg = p.green })
hi("@character.special", { fg = p.lime, bold = true })

-- NUMBERS
hi("@boolean", { fg = p.orange, bold = true })            -- bold
hi("@number", { fg = p.orange })
hi("@number.float", { fg = p.orange })

-- TYPES - lavender
hi("@type", { fg = p.lavender })
hi("@type.builtin", { fg = p.lavender, italic = true })   -- builtin types italic
hi("@type.definition", { fg = p.lavender, bold = true })

hi("@attribute", { fg = p.yellow })

-- KEYWORDS - purple, italic
hi("@keyword", { fg = p.purple, italic = true })
hi("@keyword.conditional", { fg = p.purple, italic = true })
hi("@keyword.coroutine", { fg = p.purple, italic = true })
hi("@keyword.debug", { fg = p.red })
hi("@keyword.directive", { fg = p.pink })
hi("@keyword.exception", { fg = p.red, italic = true })
hi("@keyword.function", { fg = p.purple, italic = true })
hi("@keyword.import", { fg = p.purple, italic = true })
hi("@keyword.operator", { fg = p.pink, bold = true })     -- operator keywords bold
hi("@keyword.repeat", { fg = p.purple, italic = true })
hi("@keyword.return", { fg = p.pink, italic = true })
hi("@keyword.storage", { fg = p.purple, italic = true })
hi("@keyword.type", { fg = p.cyan })

-- PUNCTUATION
hi("@punctuation.bracket", { fg = p.gold })
hi("@punctuation.delimiter", { fg = p.gold })
hi("@punctuation.special", { fg = p.pink })

-- OPERATORS
hi("@operator", { fg = p.pink })

-- COMMENTS
hi("@comment", { fg = p.fg_dark, italic = true })
hi("@comment.documentation", { fg = p.fg_dark, italic = true })
hi("@comment.error", { fg = p.fg_reverse, bg = p.diag_error, bold = true })
hi("@comment.note", { fg = p.fg_reverse, bg = p.diag_info, bold = true })
hi("@comment.todo", { fg = p.fg_reverse, bg = p.diag_warn, bold = true })
hi("@comment.warning", { fg = p.diag_warn })

-- MARKUP
hi("@markup.heading", { fg = p.pink, bold = true })
hi("@markup.heading.1", { fg = p.pink, bold = true })
hi("@markup.heading.2", { fg = p.cyan, bold = true })
hi("@markup.heading.3", { fg = p.green, bold = true })
hi("@markup.quote", { fg = p.fg_dim, italic = true })
hi("@markup.link", { fg = p.cyan, underline = true })
hi("@markup.raw", { fg = p.green })
hi("@markup.strong", { bold = true })
hi("@markup.italic", { italic = true })
hi("@markup.strikethrough", { strikethrough = true })

-- JSX/HTML TAGS
hi("@tag", { fg = p.pink })
hi("@tag.builtin", { fg = p.pink })
hi("@tag.attribute", { fg = p.yellow, italic = true })    -- attributes italic
hi("@tag.delimiter", { fg = p.pink_dim })

-------------------------------------------------------------------------------
-- LSP SEMANTIC TOKENS
-------------------------------------------------------------------------------
hi("@lsp.type.class", { fg = p.lavender })
hi("@lsp.type.decorator", { fg = p.yellow })
hi("@lsp.type.enum", { fg = p.lavender })
hi("@lsp.type.enumMember", { fg = p.orange })
hi("@lsp.type.function", { fg = p.cyan })
hi("@lsp.type.interface", { fg = p.lavender, italic = true })
hi("@lsp.type.macro", { fg = p.gold })
hi("@lsp.type.method", { fg = p.cyan })
hi("@lsp.type.namespace", { fg = p.blue })
hi("@lsp.type.parameter", { fg = p.peach, italic = true })
hi("@lsp.type.property", { fg = p.teal })
hi("@lsp.type.struct", { fg = p.lavender })
hi("@lsp.type.type", { fg = p.lavender })
hi("@lsp.type.typeParameter", { fg = p.lavender, italic = true })
hi("@lsp.type.variable", { fg = p.sky })

hi("@lsp.mod.deprecated", { strikethrough = true })
hi("@lsp.mod.readonly", { italic = true })
hi("@lsp.mod.declaration", { bold = true })

-------------------------------------------------------------------------------
-- PLUGINS
-------------------------------------------------------------------------------

-- Telescope
hi("TelescopeNormal", { fg = p.fg, bg = p.bg_dark })
hi("TelescopeBorder", { fg = p.pink, bg = p.bg_dark })
hi("TelescopeTitle", { fg = p.fg_reverse, bg = p.pink, bold = true })
hi("TelescopePromptNormal", { fg = p.fg, bg = p.bg_light })
hi("TelescopePromptBorder", { fg = p.pink, bg = p.bg_light })
hi("TelescopePromptPrefix", { fg = p.pink })
hi("TelescopeSelection", { bg = p.bg_light })
hi("TelescopeSelectionCaret", { fg = p.pink })
hi("TelescopeMatching", { fg = p.pink, bold = true })

-- NvimTree
hi("NvimTreeNormal", { fg = p.fg, bg = p.none })
hi("NvimTreeFolderIcon", { fg = p.pink })
hi("NvimTreeFolderName", { fg = p.purple })
hi("NvimTreeOpenedFolderName", { fg = p.pink, bold = true })
hi("NvimTreeRootFolder", { fg = p.pink, bold = true })
hi("NvimTreeGitDirty", { fg = p.diff_change })
hi("NvimTreeGitNew", { fg = p.diff_add })
hi("NvimTreeGitDeleted", { fg = p.diff_delete })
hi("NvimTreeIndentMarker", { fg = p.bg_lighter })

-- GitSigns
hi("GitSignsAdd", { fg = p.diff_add })
hi("GitSignsChange", { fg = p.diff_change })
hi("GitSignsDelete", { fg = p.diff_delete })

-- IndentBlankline
hi("IblIndent", { fg = p.bg_lighter })
hi("IblScope", { fg = p.pink })

-- Cmp
hi("CmpItemAbbr", { fg = p.fg })
hi("CmpItemAbbrMatch", { fg = p.pink, bold = true })
hi("CmpItemAbbrMatchFuzzy", { fg = p.pink })
hi("CmpItemKindFunction", { fg = p.cyan })
hi("CmpItemKindVariable", { fg = p.sky })
hi("CmpItemKindKeyword", { fg = p.purple })
hi("CmpItemKindText", { fg = p.green })
hi("CmpItemKindClass", { fg = p.lavender })
hi("CmpItemKindConstant", { fg = p.orange })
hi("CmpItemKindProperty", { fg = p.teal })
hi("CmpItemKindMethod", { fg = p.cyan })
hi("CmpItemKindModule", { fg = p.blue })

-- Which-key
hi("WhichKey", { fg = p.pink })
hi("WhichKeyGroup", { fg = p.cyan })
hi("WhichKeyDesc", { fg = p.fg_dim })
hi("WhichKeySeparator", { fg = p.fg_dark })
hi("WhichKeyFloat", { bg = p.bg_dark })

-- Lazy
hi("LazyNormal", { fg = p.fg, bg = p.bg_dark })
hi("LazyButton", { fg = p.fg, bg = p.bg_light })
hi("LazyButtonActive", { fg = p.fg_reverse, bg = p.pink, bold = true })
hi("LazyH1", { fg = p.fg_reverse, bg = p.pink, bold = true })
hi("LazySpecial", { fg = p.cyan })

-- Flash
hi("FlashLabel", { fg = p.fg_reverse, bg = p.pink, bold = true })
hi("FlashMatch", { fg = p.fg, bg = p.bg_light })
hi("FlashBackdrop", { fg = p.fg_dark })

-- Noice
hi("NoiceCmdlinePopup", { fg = p.fg, bg = p.bg_dark })
hi("NoiceCmdlinePopupBorder", { fg = p.pink })
hi("NoiceCmdlineIcon", { fg = p.pink })

-- Notify
hi("NotifyERRORBorder", { fg = p.diag_error })
hi("NotifyWARNBorder", { fg = p.diag_warn })
hi("NotifyINFOBorder", { fg = p.diag_info })
hi("NotifyERRORIcon", { fg = p.diag_error })
hi("NotifyWARNIcon", { fg = p.diag_warn })
hi("NotifyINFOIcon", { fg = p.diag_info })
