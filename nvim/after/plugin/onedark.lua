vim.g.colors_name = 'onedark'

local c = {
    fg             = '#ABB2BF',
    fg_bright      = '#FFFFFF',
    fg_dark        = '#1F2228',
    bg             = '#282C34',
    bg_alt         = '#3E4452',
    gray           = '#7F848E',

    blue           = '#61AFEF',
    green          = '#98C379',
    cyan           = '#56B6C2',
    red            = '#E06C75',
    orange         = '#D19A66',
    yellow         = '#E5C07B',
    purple         = '#C678DD',

    diff_add       = '#109868',
    diff_add_bg    = '#39544F',
    diff_change_bg = '#3F483C',
    diff_del_bg    = '#78292A',
}

core.nvim_set_highlights {
    ['Normal']               = { fg = c.fg, bg = 'none' },
    ['NormalNC']             = {},
    ['NormalFloat']          = { fg = c.fg, bg = 'none' },
    ['FloatBorder']          = { link = 'WinSeparator' },
    ['FloatShadow']          = {},
    ['FloatShadowThrough']   = {},
    ['FloatTitle']           = { link = 'Title' },
    ['FloatFooter']          = { link = 'FloatTitle' },

    ['Cursor']               = {},
    ['lCursor']              = { link = 'Cursor' },
    ['CursorIM']             = { link = 'Cursor' },
    ['TermCursor']           = { link = 'Cursor' },
    ['CursorLine']           = { fg = 'none', bg = c.bg_alt },
    ['CursorColumn']         = { link = 'CursorLine' },

    ['LineNr']               = { fg = c.gray },
    ['LineNrAbove']          = { link = 'LineNr' },
    ['LineNrBelow']          = { link = 'LineNr' },
    ['CursorLineNr']         = { bold = true },
    ['CursorLineFold']       = { link = 'FoldColumn' },
    ['CursorLineSign']       = { link = 'SignColumn' },

    ['Visual']               = { bg = c.bg_alt },
    ['VisualNOS']            = { link = 'Visual' },

    ['Search']               = { fg = c.fg_dark, bg = c.orange },
    ['IncSearch']            = { link = 'Search' },
    ['Substitute']           = { link = 'Search' },
    ['CurSearch']            = { fg = c.fg_dark, bg = c.yellow },
    ['MatchParen']           = { bg = c.gray },

    ['StatusLine']           = {},
    ['StatusLineNC']         = { link = 'StatusLine' },
    ['StatusLineTerm']       = { link = 'StatusLine' },
    ['StatusLineTermNC']     = { link = 'StatusLine' },
    ['WinSeparator']         = { fg = c.gray },
    ['MsgSeparator']         = { link = 'WinSeparator' },

    ['Title']                = { fg = c.orange },
    ['Directory']            = { fg = c.blue },

    ['NonText']              = { fg = c.bg_alt },
    ['EndOfBuffer']          = { link = 'NonText' },
    ['SpecialKey']           = { fg = c.fg_bright },
    ['Whitespace']           = { fg = c.fg },
    ['Conceal']              = { fg = c.bg_alt },

    ['SignColumn']           = {},
    ['FoldColumn']           = { link = 'SignColumn' },
    ['Folded']               = { link = 'CursorLine' },

    ['ColorColumn']          = { bg = c.bg_alt },

    ['Pmenu']                = { fg = c.fg, bg = 'none' },
    ['PmenuSel']             = { fg = c.fg_bright, bg = c.blue },
    ['PmenuSbar']            = { bg = c.bg_alt },
    ['PmenuThumb']           = { bg = c.fg },
    ['PmenuMatch']           = { bold = true },
    ['PmenuMatchSel']        = { bold = true },
    ['ComplMatchIns']        = {},
    ['ComplInsert']          = {},
    ['ComplHint']            = {},
    ['ComplHintMore']        = { link = 'ComplHint' },

    ['PmenuKind']            = { link = 'Pmenu' },
    ['PmenuKindSel']         = { link = 'PmenuSel' },
    ['PmenuExtra']           = { link = 'Pmenu' },
    ['PmenuExtraSel']        = { link = 'PmenuKindSel' },
    ['PmenuBorder']          = { link = 'FloatBorder' },
    ['PmenuShadow']          = { link = 'FloatShadow' },
    ['PmenuShadowThrough']   = { link = 'FloatShadowThrough' },
    ['WildMenu']             = { link = 'PmenuSel' },

    ['MsgArea']              = {},
    ['ModeMsg']              = { link = 'OkMsg' },
    ['OkMsg']                = { fg = c.green },
    ['MoreMsg']              = { fg = c.cyan },
    ['WarningMsg']           = { fg = c.orange },
    ['ErrorMsg']             = { fg = c.red },
    ['StderrMsg']            = { link = 'ErrorMsg' },
    ['StdoutMsg']            = { link = 'ModeMsg' },
    ['Question']             = { link = 'ErrorMsg' },

    ['QuickFixLine']         = { link = 'SpellBad' },
    ['SnippetTabstop']       = { link = 'Visual' },
    ['SnippetTabstopActive'] = { link = 'SnippetTabstop' },

    ['SpellBad']             = { sp = c.red, undercurl = true },
    ['SpellCap']             = { sp = c.orange, undercurl = true },
    ['SpellLocal']           = { sp = c.green, undercurl = true },
    ['SpellRare']            = { sp = c.blue, undercurl = true },

    ['TabLine']              = { link = 'StatusLineNC' },
    ['TabLineFill']          = {},
    ['TabLineSel']           = { bold = true },

    ['WinBar']               = {},
    ['WinBarNC']             = {},

    ['Comment']              = { fg = c.gray, italic = true },
    ['Constant']             = { fg = c.cyan },
    ['String']               = { fg = c.green },
    ['Character']            = { fg = c.blue },
    ['Number']               = { fg = c.orange },
    ['Boolean']              = { link = 'Number' },
    ['Float']                = { link = 'Number' },
    ['Identifier']           = { fg = c.red },
    ['Function']             = { fg = c.blue },
    ['Statement']            = { link = 'Keyword' },
    ['Conditional']          = { fg = c.purple },
    ['Repeat']               = { link = 'Statement' },
    ['Label']                = { link = 'Keyword' },
    ['Operator']             = { link = 'Special' },
    ['Keyword']              = { fg = c.purple },
    ['Exception']            = { link = 'Keyword' },
    ['PreProc']              = { fg = c.yellow },
    ['Include']              = { fg = c.blue },
    ['Define']               = { link = 'PreProc' },
    ['Macro']                = { link = 'PreProc' },
    ['PreCondit']            = { link = 'PreProc' },
    ['Type']                 = { fg = c.yellow },
    ['StorageClass']         = { link = 'Type' },
    ['Structure']            = { link = 'Type' },
    ['Typedef']              = { link = 'Type' },
    ['Special']              = { fg = c.blue },
    ['SpecialChar']          = { link = 'Special' },
    ['Tag']                  = { link = 'Special' },
    ['Delimiter']            = { link = 'Special' },
    ['SpecialComment']       = { link = 'Special' },
    ['Debug']                = { link = 'Special' },
    ['Underlined']           = { underline = true },
    ['Ignore']               = {},
    ['Error']                = { link = 'ErrorMsg' },
    ['Todo']                 = { fg = c.gray, bg = c.blue },

    -- git / diff
    ['DiffAdd']              = { fg = c.diff_add, bg = c.diff_add_bg },
    ['DiffChange']           = { fg = c.orange, bg = c.diff_change_bg },
    ['DiffDelete']           = { fg = c.red, bg = c.diff_del_bg },
    ['DiffText']             = { bg = c.diff_add_bg },
    ['DiffTextAdd']          = { link = 'DiffText' },
    ['Added']                = { fg = c.diff_add, bg = 'none' },
    ['Changed']              = { fg = c.orange, bg = 'none' },
    ['Removed']              = { fg = c.red, bg = 'none' },
}

-- lsp-highlight
core.nvim_set_highlights {
    ['LspReferenceText']   = { underline = true },
    ['LspReferenceRead']   = { underline = true },
    ['LspReferenceWrite']  = { underline = true },
    ['LspReferenceTarget'] = { underline = true },
    ['LspInlayHint']       = { link = 'Comment' },
}

-- diagnostic-highlights
core.nvim_set_highlights {
    ['DiagnosticError']             = { link = 'ErrorMsg' },
    ['DiagnosticWarn']              = { link = 'WarningMsg' },
    ['DiagnosticInfo']              = { link = 'MoreMsg' },
    ['DiagnosticHint']              = { link = 'MoreMsg' },
    ['DiagnosticOk']                = { link = 'OkMsg' },

    ['DiagnosticVirtualTextError']  = { link = 'DiagnosticError' },
    ['DiagnosticVirtualTextWarn']   = { link = 'DiagnosticWarn' },
    ['DiagnosticVirtualTextInfo']   = { link = 'DiagnosticInfo' },
    ['DiagnosticVirtualTextHint']   = { link = 'DiagnosticHint' },
    ['DiagnosticVirtualTextOk']     = { link = 'DiagnosticOk' },

    ['DiagnosticVirtualLinesError'] = { link = 'DiagnosticError' },
    ['DiagnosticVirtualLinesWarn']  = { link = 'DiagnosticWarn' },
    ['DiagnosticVirtualLinesInfo']  = { link = 'DiagnosticInfo' },
    ['DiagnosticVirtualLinesHint']  = { link = 'DiagnosticHint' },
    ['DiagnosticVirtualLinesOk']    = { link = 'DiagnosticOk' },

    ['DiagnosticUnderlineError']    = { fg = c.red, underline = true },
    ['DiagnosticUnderlineWarn']     = { fg = c.yellow, underline = true },
    ['DiagnosticUnderlineInfo']     = { fg = c.orange, underline = true },
    ['DiagnosticUnderlineHint']     = { fg = c.cyan, underline = true },
    ['DiagnosticUnderlineOk']       = { fg = c.green, underline = true },

    ['DiagnosticFloatingError']     = { link = 'DiagnosticError' },
    ['DiagnosticFloatingWarn']      = { link = 'DiagnosticWarn' },
    ['DiagnosticFloatingInfo']      = { link = 'DiagnosticInfo' },
    ['DiagnosticFloatingHint']      = { link = 'DiagnosticHint' },
    ['DiagnosticFloatingOk']        = { link = 'DiagnosticOk' },

    ['DiagnosticSignError']         = { link = 'DiagnosticError' },
    ['DiagnosticSignWarn']          = { link = 'DiagnosticWarn' },
    ['DiagnosticSignInfo']          = { link = 'DiagnosticInfo' },
    ['DiagnosticSignHint']          = { link = 'DiagnosticHint' },
    ['DiagnosticSignOk']            = { link = 'DiagnosticOk' },

    ['DiagnosticDeprecated']        = { sp = c.red, strikethrough = true },
    ['DiagnosticUnnecessary']       = { fg = c.gray },
}

-- treesitter-highlights
core.nvim_set_highlights {
    ['@variable']                    = { link = 'Identifier' },
    ['@variable.builtin']            = { link = '@variable' },
    ['@variable.parameter']          = { link = '@variable' },
    ['@variable.parameter.builtin']  = { link = '@variable.builtin' },
    ['@variable.member']             = { link = '@variable' },

    ['@constant']                    = { fg = c.yellow },
    ['@constant.builtin']            = { fg = c.orange },
    ['@constant.macro']              = { link = '@constant' },

    ['@module']                      = { fg = c.yellow },
    ['@module.builtin']              = { link = '@module' },

    ['@label']                       = { link = 'Label' },
    ['@spell']                       = { link = 'Whitespace' },

    ['@string']                      = { link = 'String' },
    ['@string.documentation']        = { link = '@string' },
    ['@string.regexp']               = { link = '@string' },
    ['@string.escape']               = { link = 'SpecialChar' },
    ['@string.special']              = { link = 'Special' },
    ['@string.special.symbol']       = { link = '@string.special' },
    ['@string.special.path']         = { link = '@string.special' },
    ['@string.special.url']          = { link = '@markup.link.url' },

    ['@character']                   = { link = 'Character' },
    ['@character.special']           = { link = 'SpecialChar' },

    ['@boolean']                     = { link = 'Boolean' },
    ['@number']                      = { link = 'Number' },
    ['@number.float']                = { link = 'Float' },

    ['@type']                        = { link = 'Type' },
    ['@type.builtin']                = { link = 'Keyword' },
    ['@type.definition']             = { link = 'Typedef' },

    ['@attribute']                   = { link = 'PreProc' },
    ['@attribute.builtin']           = { link = '@attribute' },
    ['@property']                    = { link = '@variable.member' },

    ['@function']                    = { link = 'Function' },
    ['@function.builtin']            = { link = '@function' },
    ['@function.call']               = { link = '@function' },
    ['@function.macro']              = { link = 'Macro' },
    ['@function.method']             = { link = '@function' },
    ['@function.method.call']        = { link = '@function.method' },

    ['@constructor']                 = { link = 'Special' },
    ['@operator']                    = { fg = c.cyan },

    ['@keyword']                     = { link = 'Keyword' },
    ['@keyword.coroutine']           = { link = '@keyword' },
    ['@keyword.function']            = { link = '@keyword' },
    ['@keyword.operator']            = { link = '@keyword' },
    ['@keyword.import']              = { link = 'Include' },
    ['@keyword.type']                = { link = '@keyword' },
    ['@keyword.modifier']            = { link = '@keyword' },
    ['@keyword.repeat']              = { link = 'Repeat' },
    ['@keyword.return']              = { link = '@keyword' },
    ['@keyword.debug']               = { link = 'Debug' },
    ['@keyword.exception']           = { link = 'Exception' },
    ['@keyword.conditional']         = { link = 'Conditional' },
    ['@keyword.conditional.ternary'] = { link = '@keyword.conditional' },
    ['@keyword.directive']           = { link = 'PreProc' },
    ['@keyword.directive.define']    = { link = 'Define' },

    ['@punctuation.delimiter']       = { fg = c.fg },
    ['@punctuation.bracket']         = { link = '@punctuation.delimiter' },
    ['@punctuation.special']         = { fg = c.purple },

    ['@comment']                     = { link = 'Comment' },
    ['@comment.documentation']       = { link = '@comment' },
    ['@comment.error']               = { link = 'DiagnosticError' },
    ['@comment.warning']             = { link = 'DiagnosticWarn' },
    ['@comment.todo']                = { link = 'Todo' },
    ['@comment.note']                = { link = '@comment' },

    ['@markup.strong']               = { bold = true },
    ['@markup.italic']               = { italic = true },
    ['@markup.strikethrough']        = { strikethrough = true },
    ['@markup.underline']            = { underline = true },
    ['@markup.heading']              = { link = 'Title' },
    ['@markup.heading.1']            = { link = '@markup.heading' },
    ['@markup.heading.2']            = { link = '@markup.heading' },
    ['@markup.heading.3']            = { link = '@markup.heading' },
    ['@markup.heading.4']            = { link = '@markup.heading' },
    ['@markup.heading.5']            = { link = '@markup.heading' },
    ['@markup.heading.6']            = { link = '@markup.heading' },
    ['@markup.quote']                = { link = '@markup' },
    ['@markup.math']                 = { link = 'Special' },
    ['@markup.link']                 = { fg = c.blue },
    ['@markup.link.label']           = { link = '@markup.link' },
    ['@markup.link.url']             = { fg = c.cyan },
    ['@markup.raw']                  = { link = 'Whitespace' },
    ['@markup.raw.block']            = { link = '@markup.raw' },
    ['@markup.list']                 = { link = '@markup.link' },
    ['@markup.list.checked']         = { link = '@markup.list' },
    ['@markup.list.unchecked']       = { link = '@markup.list' },

    ['@diff.plus']                   = { link = 'Added' },
    ['@diff.minus']                  = { link = 'Removed' },
    ['@diff.delta']                  = { link = 'Changed' },

    ['@tag']                         = { link = 'Tag' },
    ['@tag.builtin']                 = { link = '@tag' },
    ['@tag.attribute']               = { link = '@property' },
    ['@tag.delimiter']               = { link = 'Delimiter' },

    ['@lsp.type.class']              = { link = 'Type' },
    ['@lsp.type.comment']            = { link = '@comment' },
    ['@lsp.type.decorator']          = { link = '@attribute' },
    ['@lsp.type.enum']               = { link = '@type' },
    ['@lsp.type.enumMember']         = { link = 'Constant' },
    ['@lsp.type.event']              = { link = '@type' },
    ['@lsp.type.function']           = { link = '@function' },
    ['@lsp.type.interface']          = { link = '@type' },
    ['@lsp.type.keyword']            = { link = '@keyword' },
    ['@lsp.type.macro']              = { link = '@function.macro' },
    ['@lsp.type.method']             = { link = '@function.method' },
    ['@lsp.type.modifier']           = { link = '@keyword' },
    ['@lsp.type.namespace']          = { link = '@module' },
    ['@lsp.type.number']             = { link = '@number' },
    ['@lsp.type.operator']           = { link = '@operator' },
    ['@lsp.type.parameter']          = { link = '@variable.parameter' },
    ['@lsp.type.property']           = { link = '@property' },
    ['@lsp.type.regexp']             = { link = '@string.regexp' },
    ['@lsp.type.string']             = { link = '@string' },
    ['@lsp.type.struct']             = { link = '@type' },
    ['@lsp.type.type']               = { link = '@type' },
    ['@lsp.type.typeParameter']      = { link = '@type' },
    ['@lsp.type.variable']           = { link = '@variable' },

    ['@lsp.mod.abstract']            = { link = '@lsp.type.class' },
    ['@lsp.mod.async']               = { link = '@lsp.type.function' },
    ['@lsp.mod.declaration']         = { link = '@lsp.type' },
    ['@lsp.mod.defaultLibrary']      = { link = '@lsp.type' },
    ['@lsp.mod.definition']          = { link = '@lsp.type' },
    ['@lsp.mod.deprecated']          = { strikethrough = true },
}

-- plugins
core.nvim_set_highlights {
    -- gitsigns.nvim
    ['GitSignsCurrentLineBlame'] = { link = 'Comment' },

    -- blink.cmp
    ['BlinkCmpGhostText']        = { link = 'Comment' },

    -- mini.indentscope
    ['IndentScopeOther']         = { link = 'WinSeparator' },
    ['IndentScopeCurrent']       = { link = 'WinSeparator' },
    ['MiniIndentscopeSymbol']    = { link = 'WinSeparator' },

    -- nvim-surround
    ['NvimSurroundHighlight']    = { link = 'IndentScopeCurrent' },
}

-- nvim-tree
core.nvim_set_highlights {
    ['NvimTreeGitNew']           = { link = 'Added' },
    ['NvimTreeGitDirty']         = { link = 'Changed' },
    ['NvimTreeGitDirtyIcon']     = { link = 'Changed' },
    ['NvimTreeCursorLine']       = { link = 'CursorLine' },
    ['NvimTreeOpenedFolderIcon'] = { link = 'NvimTreeOpenedFolderName' },
    ['NvimTreeIndentMarker']     = { link = 'IndentScopeOther' },
}

-- pi.nvim
core.nvim_set_highlights {
    ['PiUserMessageLabel']   = { fg = c.fg, bg = c.cyan },
    ['PiAgentResponseLabel'] = { fg = c.fg, bg = c.yellow },

    ['PiDebugLabel']         = { link = 'Comment' },
    ['PiStartupLabel']       = { link = 'Comment' },
    ['PiStartupErrorLabel']  = { link = 'ErrorMsg' },
    ['PiStartupHint']        = { link = 'Comment' },
    ['PiStartupDetail']      = { link = 'Comment' },
    ['PiStartupError']       = { link = 'Comment' },
    ['PiCompactionLabel']    = { link = 'Comment' },
    ['PiCompactionText']     = { link = 'Comment' },
    ['PiCompactionHint']     = { link = 'Comment' },
    ['PiMessageDateTime']    = { link = 'Comment' },
    ['PiMessageQueueTag']    = { link = 'Comment' },
    ['PiMessageAttachments'] = { link = 'Comment' },
    ['PiPendingQueueLabel']  = { link = 'Comment' },
    ['PiPendingQueueText']   = { link = 'Comment' },
    ['PiThinking']           = { link = 'Comment' },

    ['PiToolBorder']         = { fg = 'none', bg = 'none' },
    ['PiToolHeader']         = { fg = c.green, bg = 'none' },
    ['PiToolStatus']         = { fg = c.green, bg = 'none' },
    ['PiToolError']          = { fg = c.red, bg = 'none' },
    ['PiToolCall']           = { link = 'Comment' },
    ['PiToolOutput']         = { link = 'Comment' },
    ['PiToolCollapsed']      = { link = 'Comment' },

    ['PiMention']            = { link = 'Keyword' },
    ['PiCommand']            = { link = 'Comment' },
    ['PiWelcome']            = { link = 'Comment' },
    ['PiWelcomeHint']        = { link = 'Comment' },
    ['PiBusy']               = { link = 'Comment' },
    ['PiBusyTime']           = { link = 'Comment' },
    ['PiWarning']            = { link = 'WarningMsg' },
    ['PiError']              = { link = 'ErrorMsg' },
    ['PiDebug']              = { link = 'Comment' },
}
