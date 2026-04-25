vim.g.colors_name = 'onedark'

core.nvim_set_highlights {
    ['ColorColumn']        = { fg = '#FFFFFF', bg = '#3E4452' },
    ['Conceal']            = { fg = '#3E4452' },
    ['CurSearch']          = { fg = '#1F2228', bg = '#E5C07B' },
    ['Cursor']             = {},
    ['lCursor']            = { link = 'Cursor' },
    ['CursorIM']           = { link = 'Cursor' },
    ['CursorColumn']       = { link = 'CursorLine' },
    ['CursorLine']         = { fg = 'none', bg = '#3E4452' },
    ['Directory']          = { fg = '#61AFEF', bg = 'none' },

    ['DiffAdd']            = { bg = '#39544F' },
    ['DiffChange']         = { bg = '#3F483C' },
    ['DiffDelete']         = { bg = '#78292A' },
    ['DiffText']           = { bg = '#39544F' },

    ['EndOfBuffer']        = { link = 'NonText' },
    ['TermCursor']         = { link = 'Cursor' },
    ['ErrorMsg']           = { fg = '#E06C75' },
    ['WinSeparator']       = { fg = '#FFFFFF' },
    ['Folded']             = { fg = 'none', bg = '#3E4452' },
    ['FoldColumn']         = { link = 'SignColumn' },
    ['SignColumn']         = {},
    ['IncSearch']          = { link = 'Search' },
    ['Substitute']         = { link = 'Search' },

    ['LineNr']             = { fg = '#7F848E' },
    ['LineNrAbove']        = { link = 'LineNr' },
    ['LineNrBelow']        = { link = 'LineNr' },

    ['CursorLineNr']       = { bold = true },
    ['CursorLineFold']     = { link = 'FoldColumn' },
    ['CursorLineSign']     = { link = 'SignColumn' },

    ['MatchParen']         = { bg = '#7F848E' },
    ['ModeMsg']            = {},
    ['MsgArea']            = {},
    ['MsgSeparator']       = { link = 'StatusLine' },
    ['MoreMsg']            = {},
    ['NonText']            = { fg = '#3E4452' },
    ['Normal']             = {},
    ['NormalFloat']        = { bg = 'none' },
    ['FloatBorder']        = { link = 'NormalFloat' },
    ['FloatShadow']        = {},
    ['FloatShadowThrough'] = {},
    ['FloatTitle']         = { link = 'Title' },
    ['FloatFooter']        = { link = 'FloatTitle' },
    ['NormalNC']           = {},

    ['Pmenu']              = { fg = '#ABB2BF', bg = 'none' },
    ['PmenuSel']           = { fg = '#FFFFFF', bg = '#61AFEF' },
    ['PmenuKind']          = { link = 'Pmenu' },
    ['PmenuKindSel']       = { link = 'PmenuKindSel' },
    ['PmenuExtra']         = { link = 'Pmenu' },
    ['PmenuExtraSel']      = { link = 'PmenuKindSel' },
    ['PmenuSbar']          = { bg = '#3E4452' },
    ['PmenuThumb']         = { bg = '#ABB2BF' },
    ['PmenuMatch']         = { bold = true },
    ['PmenuMatchSel']      = { bold = true },

    ['ComplMatchIns']      = {},
    ['Question']           = { link = 'ErrorMsg' },
    ['QuickFixLine']       = { link = 'SpellBad' },
    ['Search']             = { fg = '#1F2228', bg = '#D19A66' },
    ['SnippetTabstop']     = { link = 'Visual' },
    ['SpecialKey']         = { fg = '#FFFFFF' },

    ['SpellBad']           = { sp = '#E06C75', undercurl = true },
    ['SpellCap']           = { sp = '#D19A66', undercurl = true },
    ['SpellLocal']         = { sp = '#98C379', undercurl = true },
    ['SpellRare']          = { sp = '#61AFEF', undercurl = true },

    ['StatusLine']         = {},
    ['StatusLineNC']       = { link = 'StatusLine' },
    ['StatusLineTerm']     = { link = 'StatusLine' },
    ['StatusLineTermNC']   = { link = 'StatusLine' },

    ['TabLine']            = { link = 'StatusLineNC' },
    ['TabLineFill']        = {},
    ['TabLineSel']         = { bold = true },

    ['Title']              = { fg = '#D19A66' },
    ['Visual']             = { bg = '#3E4452' },
    ['VisualNOS']          = { link = 'Visual' },
    ['WarningMsg']         = { fg = '#D19A66' },
    ['Whitespace']         = { fg = '#ABB2BF' },
    ['WildMenu']           = { link = 'PmenuSel' },
    ['WinBar']             = {},
    ['WinBarNC']           = {},
}

core.nvim_set_highlights {
    ['Character']                = { fg = '#61AFEF' },
    ['Constant']                 = { fg = '#56B6C2' },
    ['Function']                 = { fg = '#61AFEF' },
    ['Identifier']               = { fg = '#E06C75' },
    ['Include']                  = { fg = '#61AFEF' },
    ['Keyword']                  = { fg = '#C678DD' },
    ['PreProc']                  = { fg = '#E5C07B' },
    ['String']                   = { fg = '#98C379' },
    ['Special']                  = { fg = '#61AFEF' },
    ['Type']                     = { fg = '#E5C07B' },
    ['Number']                   = { fg = '#D19A66' },

    ['Conditional']              = { fg = '#C678DD' },
    ['Todo']                     = { fg = '#7F848E', bg = '#61AFEF' },
    ['Comment']                  = { fg = '#7F848E', italic = true },
    ['IndentScopeOther']         = { fg = '#3E4452', nocombine = true },
    ['IndentScopeCurrent']       = { fg = '#7F848E', nocombine = true },

    ['Statement']                = {},

    ['Added']                    = { fg = '#109868', bg = 'none' },
    ['Boolean']                  = { fg = '#D19A66' },
    ['Changed']                  = { fg = '#D19A66', bg = 'none' },
    ['Removed']                  = { fg = '#E06C75', bg = 'none' },

    ['DiagnosticInfo']           = { fg = '#D19A66' },
    ['DiagnosticError']          = { fg = '#E06C75' },
    ['DiagnosticUnderlineWarn']  = { fg = '#E5C07B', underline = true },
    ['DiagnosticUnderlineError'] = { fg = '#E06C75', underline = true },
}

-- treesitter
core.nvim_set_highlights {
    ['@variable']              = { fg = '#E06C75' },
    ['@type.builtin']          = { fg = '#C678DD' },
    ['@module']                = { fg = '#E5C07B' },
    ['@operator']              = { fg = '#56B6C2' },
    ['@constant']              = { fg = '#E5C07B' },
    ['@constant.builtin']      = { fg = '#D19A66' },
    ['@lsp.type.class']        = { fg = '#E5C07B' },
    ['@lsp.type.namespace']    = { fg = '#E5C07B' },
    ['@lsp.type.enumMember']   = { fg = '#56B6C2' },
    ['@markup.list']           = { fg = '#61AFEF' },
    ['@markup.raw']            = { fg = '#E5C07B' },
    ['@markup.heading']        = { fg = '#D19A66' },
    ['@markup.link']           = { fg = '#61AFEF' },
    ['@markup.link.url']       = { fg = '#56B6C2' },
    ['@punctuation.special']   = { fg = '#C678DD' },
    ['@punctuation.bracket']   = { fg = '#ABB2BF' },
    ['@punctuation.delimiter'] = { fg = '#ABB2BF' },
}

-- LSP
core.nvim_set_highlights {
    ['Error']            = { link = 'ErrorMsg' },
    ['LspInlayHint']     = { link = 'Comment' },
    ['LspReferenceText'] = { underline = true },
}

