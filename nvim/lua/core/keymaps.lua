local Core = require("core")
local comment = require("core.comment")
local opts = { noremap = true, silent = true }

local function better_home()
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    local feedkeys =
    -- move cursor to the real beginning of the line
        (col == 0 or vim.api.nvim_get_current_line():sub(0, col):match("^%s*$")) and "<Home>" or
        -- move cursor to beginning of non-whitespace characters of the line
        (vim.api.nvim_get_mode().mode == "i" and "<C-o>^" or "^")

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(feedkeys, true, false, true), "n", false)
end

Core.setKeyMaps {
    { { "i", "s" },      "jk",         "<Esc>",                   opts },
 -- { "t",               "jk",         "<C-\\><C-n>",             opts }, -- in terminal switch TERMINAL mode to NORMAL mode
    { "t",               "<Esc>",      "<C-\\><C-n>",             opts }, -- in terminal switch TERMINAL mode to NORMAL mode
    { "n",               "<M-2>",      "@q",                      opts },
    { { "n", "i", "v" }, "<Home>",     better_home,               opts },
    { { "i", "v" },      "<M-i>",      better_home,               opts },
    { { "i", "v" },      "<M-a>",      "<End>",                   opts },
    { { "n", "i" },      "<C-s>",      "<Cmd>w<CR>",              opts },
    { { "n", "i" },      "<C-z>",      "<Cmd>undo<CR>",           opts },
    { { "n", "i" },      "<C-y>",      "<Cmd>redo<CR>",           opts },
    { { "n", "v" },      "-",          "g_",                      opts },
    { "n",               "d-",         "d$",                      opts },
    { "n",               "Q",          "<Cmd>bdelete<CR>",        opts },
    { "n",               "<Tab>",      "<Cmd>bnext<CR>",          opts },
    { "n",               "<S-Tab>",    "<Cmd>bprevious<CR>",      opts },
    { "v",               "<Tab>",      ">gv",                     opts },
    { "v",               "<S-Tab>",    "<gv",                     opts },
    { "i",               "<S-Tab>",    "<C-d>",                   opts },
    { "i",               "<M-h>",      "<Left>",                  opts },
    { "i",               "<M-l>",      "<Right>",                 opts },
    { "n",               "<leader>q",  "<Cmd>qa<CR>",             opts },
    { "n",               "<leader>h",  "gd",                      opts },
    { "n",               "<leader>nh", "<Cmd>noh<CR>",            opts },
    { "n",               "<C-a>",      "ggVG",                    opts },
    { "n",               "<M-a>",      "<C-o>",                   opts },
    { "n",               "<M-d>",      "<C-i>",                   opts },
    { { "n", "t" },      "<Leader>wh", "<Cmd>wincmd h<CR>",       opts },
    { { "n", "t" },      "<Leader>wj", "<Cmd>wincmd j<CR>",       opts },
    { { "n", "t" },      "<Leader>wk", "<Cmd>wincmd k<CR>",       opts },
    { { "n", "t" },      "<Leader>wl", "<Cmd>wincmd l<CR>",       opts },
    { "n",               "<M-j>",      ":move .+1<CR>",           opts }, -- move current line down
    { "n",               "<M-k>",      ":move .-2<CR>",           opts }, -- move current line up
    { "n",               "<M-J>",      ":copy .<CR>",             opts }, -- copy current line down
    { "n",               "<M-K>",      ":copy .-1<CR>",           opts }, -- copy current line up
    { "v",               "<M-j>",      ":move '>+1<CR>gv",        opts }, -- move select block down
    { "v",               "<M-k>",      ":move '<-2<CR>gv",        opts }, -- move select block up
    { "v",               "<M-J>",      ":copy '<-1<CR>gv",        opts }, -- copy select block down
    { "v",               "<M-K>",      ":copy '><CR>gv",          opts }, -- copy select block up
    { { "n", "i", "v" }, "<C-_>",      comment.line_comment,      opts }, -- line-comment
    { { "n", "i", "v" }, "<C-/>",      comment.line_comment,      opts }, -- line-comment
    { { "n", "i", "v" }, "<M-A>",      comment.hunk_comment,      opts }, -- hunk-comment
}
