vim.g.colors_name = 'onedark'

-- highlight-groups
core.nvim_set_highlights {
    ['ColorColumn']          = { fg = '#FFFFFF', bg = '#3E4452' },
    ['Conceal']              = { fg = '#3E4452' },

    ['Cursor']               = {},
    ['lCursor']              = { link = 'Cursor' },
    ['CursorIM']             = { link = 'Cursor' },
    ['CursorColumn']         = { link = 'CursorLine' },
    ['CursorLine']           = { fg = 'none', bg = '#3E4452' },

    ['Directory']            = { fg = '#61AFEF', bg = 'none' },

    ['DiffAdd']              = { bg = '#39544F' },
    ['DiffChange']           = { bg = '#3F483C' },
    ['DiffDelete']           = { bg = '#78292A' },
    ['DiffText']             = { bg = '#39544F' },
    ['DiffTextAdd']          = { link = 'DiffText' },

    ['EndOfBuffer']          = { link = 'NonText' },

    ['TermCursor']           = { link = 'Cursor' },

    ['WinSeparator']         = { link = 'NonText' },

    ['Folded']               = { link = 'CursorLine' },
    ['FoldColumn']           = { link = 'SignColumn' },
    ['SignColumn']           = {},

    ['Search']               = { fg = '#1F2228', bg = '#D19A66' },
    ['IncSearch']            = { link = 'Search' },
    ['Substitute']           = { link = 'Search' },
    ['CurSearch']            = { fg = '#1F2228', bg = '#E5C07B' },

    ['LineNr']               = { fg = '#7F848E' },
    ['LineNrAbove']          = { link = 'LineNr' },
    ['LineNrBelow']          = { link = 'LineNr' },
    ['CursorLineNr']         = { bold = true },
    ['CursorLineFold']       = { link = 'FoldColumn' },
    ['CursorLineSign']       = { link = 'SignColumn' },

    ['MatchParen']           = { bg = '#7F848E' },

    ['OkMsg']                = { fg = '#98C379' },
    ['MoreMsg']              = { fg = '#56B6C2' },
    ['WarningMsg']           = { fg = '#D19A66' },
    ['ErrorMsg']             = { fg = '#E06C75' },
    ['StderrMsg']            = { link = 'ErrorMsg' },
    ['StdoutMsg']            = { link = 'ModeMsg' },
    ['ModeMsg']              = { link = 'OkMsg' },
    ['MsgArea']              = {},
    ['MsgSeparator']         = { link = 'WinSeparator' },

    ['NonText']              = { fg = '#3E4452' },

    ['Normal']               = { bg = '#282C34' },
    ['NormalNC']             = {},

    ['NormalFloat']          = { fg = '#ABB2BF', bg = 'none' },
    ['FloatBorder']          = { link = 'WinSeparator' },
    ['FloatShadow']          = {},
    ['FloatShadowThrough']   = {},
    ['FloatTitle']           = { link = 'Title' },
    ['FloatFooter']          = { link = 'FloatTitle' },

    ['Pmenu']                = { fg = '#ABB2BF', bg = 'none' },
    ['PmenuSel']             = { fg = '#FFFFFF', bg = '#61AFEF' },
    ['PmenuKind']            = { link = 'Pmenu' },
    ['PmenuKindSel']         = { link = 'PmenuSel' },
    ['PmenuExtra']           = { link = 'Pmenu' },
    ['PmenuExtraSel']        = { link = 'PmenuKindSel' },
    ['PmenuSbar']            = { bg = '#3E4452' },
    ['PmenuThumb']           = { bg = '#ABB2BF' },
    ['PmenuMatch']           = { bold = true },
    ['PmenuMatchSel']        = { bold = true },
    ['PmenuBorder']          = { link = 'FloatBorder' },
    ['PmenuShadow']          = { link = 'FloatShadow' },
    ['PmenuShadowThrough']   = { link = 'FloatShadowThrough' },

    ['ComplMatchIns']        = {},
    ['PreInsert']            = {},
    ['ComplHint']            = {},
    ['ComplHintMore']        = { link = 'ComplHint' },

    ['Question']             = { link = 'ErrorMsg' },

    ['QuickFixLine']         = { link = 'SpellBad' },

    ['SnippetTabstop']       = { link = 'Visual' },
    ['SnippetTabstopActive'] = { link = 'SnippetTabstop' },

    ['SpecialKey']           = { fg = '#FFFFFF' },

    ['SpellBad']             = { sp = '#E06C75', undercurl = true },
    ['SpellCap']             = { sp = '#D19A66', undercurl = true },
    ['SpellLocal']           = { sp = '#98C379', undercurl = true },
    ['SpellRare']            = { sp = '#61AFEF', undercurl = true },

    ['StatusLine']           = {},
    ['StatusLineNC']         = { link = 'StatusLine' },
    ['StatusLineTerm']       = { link = 'StatusLine' },
    ['StatusLineTermNC']     = { link = 'StatusLine' },

    ['TabLine']              = { link = 'StatusLineNC' },
    ['TabLineFill']          = {},
    ['TabLineSel']           = { bold = true },

    ['Title']                = { fg = '#D19A66' },

    ['Visual']               = { bg = '#3E4452' },
    ['VisualNOS']            = { link = 'Visual' },

    ['Whitespace']           = { fg = '#ABB2BF' },

    ['WildMenu']             = { link = 'PmenuSel' },

    ['WinBar']               = {},
    ['WinBarNC']             = {},
}

-- group-name
core.nvim_set_highlights {
    ['Comment']        = { fg = '#7F848E', italic = true },
    ['Constant']       = { fg = '#56B6C2' },
    ['String']         = { fg = '#98C379' },
    ['Character']      = { fg = '#61AFEF' },
    ['Number']         = { fg = '#D19A66' },
    ['Boolean']        = { link = 'Number' },
    ['Float']          = { link = 'Number' },
    ['Identifier']     = { fg = '#E06C75' },
    ['Function']       = { fg = '#61AFEF' },
    ['Statement']      = {},
    ['Conditional']    = { fg = '#C678DD' },
    ['Repeat']         = { link = 'Statement' },
    ['Label']          = { link = 'Keyword' },
    ['Operator']       = { link = 'Special' },
    ['Keyword']        = { fg = '#C678DD' },
    ['Exception']      = { link = 'Keyword' },
    ['PreProc']        = { fg = '#E5C07B' },
    ['Include']        = { fg = '#61AFEF' },
    ['Define']         = { link = 'PreProc' },
    ['Macro']          = { link = 'PreProc' },
    ['PreCondit']      = { link = 'PreProc' },
    ['Type']           = { fg = '#E5C07B' },
    ['StorageClass']   = { link = 'Type' },
    ['Structure']      = { link = 'Type' },
    ['Typedef']        = { link = 'Type' },
    ['Special']        = { fg = '#61AFEF' },
    ['SpecialChar']    = { link = 'Special' },
    ['Tag']            = { link = 'Special' },
    ['Delimiter']      = { link = 'Special' },
    ['SpecialComment'] = { link = 'Special' },
    ['Debug']          = { link = 'Special' },
    ['Underlined']     = { underline = true },
    ['Ignore']         = {},
    ['Error']          = { link = 'ErrorMsg' },
    ['Todo']           = { fg = '#7F848E', bg = '#61AFEF' },

    --- Diff syntax groups
    ['Added']          = { fg = '#109868', bg = 'none' },
    ['Changed']        = { fg = '#D19A66', bg = 'none' },
    ['Removed']        = { fg = '#E06C75', bg = 'none' },
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
    --- Base diagnostic groups
    ['DiagnosticError']             = { link = 'ErrorMsg' },
    ['DiagnosticWarn']              = { link = 'WarningMsg' },
    ['DiagnosticInfo']              = { link = 'MoreMsg' },
    ['DiagnosticHint']              = { link = 'MoreMsg' },
    ['DiagnosticOk']                = { link = 'OkMsg' },

    --- Virtual text
    ['DiagnosticVirtualTextError']  = { link = 'DiagnosticError' },
    ['DiagnosticVirtualTextWarn']   = { link = 'DiagnosticWarn' },
    ['DiagnosticVirtualTextInfo']   = { link = 'DiagnosticInfo' },
    ['DiagnosticVirtualTextHint']   = { link = 'DiagnosticHint' },
    ['DiagnosticVirtualTextOk']     = { link = 'DiagnosticOk' },

    --- Virtual lines
    ['DiagnosticVirtualLinesError'] = { link = 'DiagnosticError' },
    ['DiagnosticVirtualLinesWarn']  = { link = 'DiagnosticWarn' },
    ['DiagnosticVirtualLinesInfo']  = { link = 'DiagnosticInfo' },
    ['DiagnosticVirtualLinesHint']  = { link = 'DiagnosticHint' },
    ['DiagnosticVirtualLinesOk']    = { link = 'DiagnosticOk' },

    --- Underline
    ['DiagnosticUnderlineError']    = { fg = '#E06C75', underline = true },
    ['DiagnosticUnderlineWarn']     = { fg = '#E5C07B', underline = true },
    ['DiagnosticUnderlineInfo']     = { fg = '#D19A66', underline = true },
    ['DiagnosticUnderlineHint']     = { fg = '#56B6C2', underline = true },
    ['DiagnosticUnderlineOk']       = { fg = '#98C379', underline = true },

    --- Floating window
    ['DiagnosticFloatingError']     = { link = 'DiagnosticError' },
    ['DiagnosticFloatingWarn']      = { link = 'DiagnosticWarn' },
    ['DiagnosticFloatingInfo']      = { link = 'DiagnosticInfo' },
    ['DiagnosticFloatingHint']      = { link = 'DiagnosticHint' },
    ['DiagnosticFloatingOk']        = { link = 'DiagnosticOk' },

    --- Sign column
    ['DiagnosticSignError']         = { link = 'DiagnosticError' },
    ['DiagnosticSignWarn']          = { link = 'DiagnosticWarn' },
    ['DiagnosticSignInfo']          = { link = 'DiagnosticInfo' },
    ['DiagnosticSignHint']          = { link = 'DiagnosticHint' },
    ['DiagnosticSignOk']            = { link = 'DiagnosticOk' },

    --- Deprecated / Unnecessary
    ['DiagnosticDeprecated']        = { sp = '#E06C75', strikethrough = true },
    ['DiagnosticUnnecessary']       = { fg = '#7F848E' },
}

-- treesitter-highlights
core.nvim_set_highlights {
    ['@variable']                    = { link = 'Identifier' },
    ['@variable.builtin']            = { link = '@variable' },
    ['@variable.parameter']          = { link = '@variable' },
    ['@variable.parameter.builtin']  = { link = '@variable.builtin' },
    ['@variable.member']             = { link = '@variable' },

    ['@constant']                    = { fg = '#E5C07B' },
    ['@constant.builtin']            = { fg = '#D19A66' },
    ['@constant.macro']              = { link = '@constant' },

    ['@module']                      = { fg = '#E5C07B' },
    ['@module.builtin']              = { link = '@module' },

    ['@label']                       = { link = 'Label' },

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

    ['@operator']                    = { fg = '#56B6C2' },

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

    ['@punctuation.delimiter']       = { fg = '#ABB2BF' },
    ['@punctuation.bracket']         = { link = '@punctuation.delimiter' },
    ['@punctuation.special']         = { fg = '#C678DD' },

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
    ['@markup.link']                 = { fg = '#61AFEF' },
    ['@markup.link.label']           = { link = '@markup.link' },
    ['@markup.link.url']             = { fg = '#56B6C2' },
    ['@markup.raw']                  = { fg = '#E5C07B' },
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

-- avante.nvim
core.nvim_set_highlights {
    ['AvantePopupHint']               = { link = 'Comment' },
    ['AvanteSidebarWinSeparator']     = { link = 'WinSeparator' },
    ['AvanteStateSpinnerSucceeded']   = { link = 'OkMsg' },
    ['AvanteStateSpinnerToolCalling'] = { link = 'MoreMsg' },

}
