vim.g.colors_name = 'onedark'

local c = {
    none = 'none',
    red0 = '#E06C75',
    org0 = '#D19A66',
    ylw0 = '#E5C07B',
    grn0 = '#98C379',
    grn1 = '#109868',
    cyn0 = '#56B6C2',
    blu0 = '#61AFEF',
    mag0 = '#C678DD',
    gry0 = '#7F848E',
    gry1 = '#3E4452',
    gry2 = '#ABB2BF',
    blk0 = '#1F2228',
    wht0 = '#FFFFFF',
}

local nvim_set_highlights = function(hl)
    for name, val in pairs(hl) do vim.api.nvim_set_hl(0, name, val) end
end

nvim_set_highlights {
    ['ColorColumn']        = { fg = c.wht0, bg = c.gry1 },
    ['Conceal']            = { fg = c.gry1 },
    ['CurSearch']          = { fg = c.blk0, bg = c.ylw0 },
    ['Cursor']             = {},
    ['lCursor']            = { link = 'Cursor' },
    ['CursorIM']           = { link = 'Cursor' },
    ['CursorColumn']       = { link = 'CursorLine' },
    ['CursorLine']         = { fg = c.none, bg = c.gry1 },
    ['Directory']          = { fg = c.blu0, bg = c.none },
    ['DiffAdd']            = { link = 'Added' },
    ['DiffChange']         = { link = 'Changed' },
    ['DiffDelete']         = { link = 'Removed' },
    ['DiffText']           = { link = 'Changed' },
    ['EndOfBuffer']        = { link = 'NonText' },
    ['TermCursor']         = { link = 'Cursor' },
    ['ErrorMsg']           = { fg = c.red0 },
    ['WinSeparator']       = { fg = c.wht0 },
    ['Folded']             = { fg = c.none, bg = c.gry1 },
    ['FoldColumn']         = { link = 'SignColumn' },
    ['SignColumn']         = {},
    ['IncSearch']          = { link = 'Search' },
    ['Substitute']         = { link = 'Search' },
    ['LineNr']             = { fg = c.gry0 },
    ['LineNrAbove']        = { link = 'LineNr' },
    ['LineNrBelow']        = { link = 'LineNr' },
    ['CursorLineNr']       = { bold = true },
    ['CursorLineFold']     = { link = 'FoldColumn' },
    ['CursorLineSign']     = { link = 'SignColumn' },
    ['MatchParen']         = { bg = c.gry0 },
    ['ModeMsg']            = {},
    ['MsgArea']            = {},
    ['MsgSeparator']       = { link = 'StatusLine' },
    ['MoreMsg']            = {},
    ['NonText']            = { fg = c.gry1 },
    ['Normal']             = {},
    ['NormalFloat']        = { bg = c.none },
    ['FloatBorder']        = { link = 'NormalFloat' },
    ['FloatShadow']        = {},
    ['FloatShadowThrough'] = {},
    ['FloatTitle']         = { link = 'Title' },
    ['FloatFooter']        = { link = 'FloatTitle' },
    ['NormalNC']           = {},
    ['Pmenu']              = { fg = c.gry2, bg = c.none },
    ['PmenuSel']           = { fg = c.wht0, bg = c.blu0 },
    ['PmenuKind']          = { link = 'Pmenu' },
    ['PmenuKindSel']       = { link = 'PmenuKindSel' },
    ['PmenuExtra']         = { link = 'Pmenu' },
    ['PmenuExtraSel']      = { link = 'PmenuKindSel' },
    ['PmenuSbar']          = { bg = c.gry1 },
    ['PmenuThumb']         = { bg = c.gry2 },
    ['PmenuMatch']         = { bold = true },
    ['PmenuMatchSel']      = { bold = true },
    ['ComplMatchIns']      = {},
    ['Question']           = { link = 'ErrorMsg' },
    ['QuickFixLine']       = { link = 'SpellBad' },
    ['Search']             = { fg = c.blk0, bg = c.org0 },
    ['SnippetTabstop']     = { link = 'Visual' },
    ['SpecialKey']         = { fg = c.wht0 },
    ['SpellBad']           = { sp = c.red0, undercurl = true },
    ['SpellCap']           = { sp = c.org0, undercurl = true },
    ['SpellLocal']         = { sp = c.grn0, undercurl = true },
    ['SpellRare']          = { sp = c.blu0, undercurl = true },
    ['StatusLine']         = {},
    ['StatusLineNC']       = { link = 'StatusLine' },
    ['StatusLineTerm']     = { link = 'StatusLine' },
    ['StatusLineTermNC']   = { link = 'StatusLine' },
    ['TabLine']            = { link = 'StatusLineNC' },
    ['TabLineFill']        = {},
    ['TabLineSel']         = { bold = true },
    ['Title']              = { fg = c.org0 },
    ['Visual']             = { bg = c.gry1 },
    ['VisualNOS']          = { link = 'Visual' },
    ['WarningMsg']         = { fg = c.org0 },
    ['Whitespace']         = { fg = c.gry2 },
    ['WildMenu']           = { link = 'PmenuSel' },
    ['WinBar']             = {},
    ['WinBarNC']           = {},
}

nvim_set_highlights {
    ['Character']                = { fg = c.blu0 },
    ['Constant']                 = { fg = c.cyn0 },
    ['Function']                 = { fg = c.blu0 },
    ['Identifier']               = { fg = c.red0 },
    ['Include']                  = { fg = c.blu0 },
    ['Keyword']                  = { fg = c.mag0 },
    ['PreProc']                  = { fg = c.ylw0 },
    ['String']                   = { fg = c.grn0 },
    ['Special']                  = { fg = c.blu0 },
    ['Type']                     = { fg = c.ylw0 },
    ['Number']                   = { fg = c.org0 },

    ['Conditional']              = { fg = c.mag0 },
    ['Todo']                     = { fg = c.gry0, bg = c.blu0 },
    ['Comment']                  = { fg = c.gry0, italic = true },
    ['IndentScopeOther']         = { fg = c.gry1, nocombine = true },
    ['IndentScopeCurrent']       = { fg = c.gry0, nocombine = true },

    ['Statement']                = {},

    ['Added']                    = { fg = c.grn1, bg = c.None },
    ['Boolean']                  = { fg = c.org0 },
    ['Changed']                  = { fg = c.org0, bg = c.None },
    ['Removed']                  = { fg = c.red0, bg = c.None },

    ['DiagnosticError']          = { fg = c.red0 },
    ['DiagnosticUnderlineWarn']  = { fg = c.ylw0, underline = true },
    ['DiagnosticUnderlineError'] = { fg = c.red0, underline = true },
}

-- treesitter
nvim_set_highlights {
    ['@variable']              = { fg = c.red0 },
    ['@type.builtin']          = { fg = c.mag0 },
    ['@module']                = { fg = c.ylw0 },
    ['@operator']              = { fg = c.cyn0 },
    ['@constant']              = { fg = c.ylw0 },
    ['@constant.builtin']      = { fg = c.org0 },
    ['@lsp.type.class']        = { fg = c.ylw0 },
    ['@lsp.type.namespace']    = { fg = c.ylw0 },
    ['@lsp.type.enumMember']   = { fg = c.cyn0 },
    ['@markup.list']           = { fg = c.blu0 },
    ['@markup.raw']            = { fg = c.ylw0 },
    ['@markup.heading']        = { fg = c.org0 },
    ['@markup.link']           = { fg = c.blu0 },
    ['@markup.link.url']       = { fg = c.cyn0 },
    ['@punctuation.special']   = { fg = c.mag0 },
    ['@punctuation.bracket']   = { fg = c.gry2 },
    ['@punctuation.delimiter'] = { fg = c.gry2 },
}

-- LSP
nvim_set_highlights {
    ['Error']            = { link = 'ErrorMsg' },
    ['LspInlayHint']     = { link = 'Comment'  },
    ['LspReferenceText'] = { underline = true  },
}

-- Plugins
nvim_set_highlights {
    -- gitsigns
    ['GitSignsCurrentLineBlame'] = { link = 'Comment' },

    -- mini-indentscope
    ['MiniIndentscopeSymbol']    = { link = 'IndentScopeCurrent' },

    -- nvim-tree
    ['NvimTreeGitNew']           = { link = 'Added' },
    ['NvimTreeGitDirty']         = { link = 'Changed' },
    ['NvimTreeCursorLine']       = { link = 'CursorLine' },
    ['NvimTreeOpenedFolderIcon'] = { link = 'NvimTreeOpenedFolderName' },
    ['NvimTreeIndentMarker']     = { link = 'IndentScopeOther' },

    -- lspsaga
    ['SagaVirtLine']             = { link = 'IndentScopeOther' },
    ['SagaInCurrent']            = { link = 'IndentScopeCurrent' },

    -- blink.cmp
    ['BlinkCmpGhostText']        = { link = 'Comment' },
}
