vim.g.colors_name = "onedark"

local Core = require("core")

C = {
    None   = "None",
    Red    = "#E06C75",
    DRed   = "#BD3D37",
    Orange = "#D19A66",
    Yellow = "#E5C07B",
    Green  = "#98C379",
    DGreen = "#109868",
    Cyan   = "#56B6C2",
    Blue   = "#61AFEF",
    Purple = "#C678DD",
    Gray   = "#5C6370",
    DGray  = "#3e4452",
    LGray  = "#ABB2BF",
    Black  = "#282c34",
    White  = "#FFFFFF",
}

S = {
    None          = "None",
    Bold          = "Bold",
    Italic        = "Italic",
    Reverse       = "Reverse",
    Inverse       = "Inverse",
    Altfont       = "Altfont",
    Standout      = "Standout",
    Nocombine     = "Nocombine",
    Underline     = "Underline",
    Undercurl     = "Undercurl",
    Underdouble   = "Underdouble",
    Underdotted   = "Underdotted",
    Underdashed   = "Underdashed",
    Strikethrough = "Strikethrough",
}

Core.setHighlights {
    ["Visual"]                 = { bg = C.DGray },
    ["CursorLine"]             = { bg = C.DGray },
    ["NormalFloat"]            = { bg = C.None  },
    ["LineNr"]                 = { fg = C.Gray  },
    ["Normal"]                 = { fg = C.LGray, bg = C.None },

    ["PmenuSbar"]              = { bg = C.DGray },
    ["PmenuThumb"]             = { bg = C.LGray },
    ["Pmenu"]                  = { fg = C.LGray, bg = C.None },
    ["PmenuSel"]               = { fg = C.White, bg = C.Blue },

    ["Title"]                  = { fg = C.Orange },
    ["NonText"]                = { fg = C.DGray  },
    ["Directory"]              = { fg = C.Blue   },
    ["MatchParen"]             = { bg = C.Gray   },
    ["Identifier"]             = { fg = C.Red    },
    ["Boolean"]                = { fg = C.Orange },
    ["Number"]                 = { fg = C.Orange },
    ["PreProc"]                = { fg = C.Yellow },
    ["Type"]                   = { fg = C.Yellow },
    ["String"]                 = { fg = C.Green  },
    ["Character"]              = { fg = C.Blue   },
    ["Constant"]               = { fg = C.Cyan   },
    ["Special"]                = { fg = C.Blue   },
    ["Include"]                = { fg = C.Blue   },
    ["Function"]               = { fg = C.Blue   },
    ["Keyword"]                = { fg = C.Purple },
    ["Conditional"]            = { fg = C.Purple },
    ["Comment"]                = { fg = C.Gray,  ui = S.Italic },
    ["Search"]                 = { fg = C.Black, bg = C.Orange },
    ["Todo"]                   = { fg = C.Gray,  bg = C.Blue   },

    -- Treesitter
    ["@variable"]              = { fg = C.Red    },
    ["@type.builtin"]          = { fg = C.Purple },
    ["@module"]                = { fg = C.Yellow },
    ["@operator"]              = { fg = C.Cyan   },
    ["@constant"]              = { fg = C.Yellow },
    ["@constant.builtin"]      = { fg = C.Orange },
    ["@lsp.type.class"]        = { fg = C.Yellow },
    ["@lsp.type.namespace"]    = { fg = C.Yellow },
    ["@lsp.type.enumMember"]   = { fg = C.Cyan   },

    -- Markdown
    ["@markup.list"]           = { fg = C.Blue   },
    ["@markup.raw"]            = { fg = C.Yellow },
    ["@markup.heading"]        = { fg = C.Orange },
    ["@markup.link"]           = { fg = C.Blue   },
    ["@markup.link.url"]       = { fg = C.Cyan   },

    ["@punctuation.special"]   = { fg = C.Purple },
    ["@punctuation.bracket"]   = { fg = C.LGray  },
    ["@punctuation.delimiter"] = { fg = C.LGray  },
}

Core.linkHighlights {
    ["@storageclass"]       = "Keyword",
    ["@string.special.url"] = "Comment",

    -- syntax
    ["luaFunc"]             = "Function",
    ["zshVariable"]         = "Identifier",
    ["zshOperator"]         = "Operator",
    ["zshKSHFunction"]      = "Function",
}

Core.clearHighlights {
    "Statement",
    "SignColumn",
    "CursorLineNr",
    "StatusLine",
    "TabLineFill",
}
