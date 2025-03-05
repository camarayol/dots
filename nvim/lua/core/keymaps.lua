local Core = require("core")
local opts = { noremap = true, silent = true }

Core.setCommentStrings {
    { cs = "# %s",     pattern = { "ini" } },
    { cs = "/* %s */", pattern = { "css" } },
    { cs = "// %s",    pattern = { "cpp", "rust", "kdl", "rasi", "jsonc" } },
}

local function lineComment()
    local mode = vim.api.nvim_get_mode().mode
    if mode == "n" or mode == "i" then
        local line = vim.api.nvim_get_current_line()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))

        if not line:find("%S") then
            local cs = vim.bo.commentstring
            if cs == nil or cs == '' then
                return Core.warn("Option 'commentstring' is empty.")
            end
            local cursor_position = { row, col + cs:find("%%s") - 1 }
            local commentline = string.rep(" ", col) .. cs:gsub("%%s", "")
            vim.api.nvim_buf_set_lines(0, row - 1, row, false, { commentline })
            vim.api.nvim_win_set_cursor(0, cursor_position)

            if mode == "n" then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("a", true, false, true), "n", false)
            end
        else
            require("vim._comment").toggle_lines(row, row)
        end
    else
        local srow = math.min(vim.fn.getpos("v")[2], vim.fn.getpos(".")[2])
        local erow = math.max(vim.fn.getpos("v")[2], vim.fn.getpos(".")[2])
        require("vim._comment").toggle_lines(srow, erow)
    end
end

local function betterHome()
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    local feedkeys =
    -- move cursor to the real beginning of the line
        (col == 0 or vim.api.nvim_get_current_line():sub(0, col):match("^%s*$")) and "<Home>" or
        -- move cursor to beginning of non-whitespace characters of the line
        (vim.api.nvim_get_mode().mode == "i" and "<C-o>^" or "^")

    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(feedkeys, true, false, true), "n", false)
end


local function codeCompile()
    local commands = {
        ["cpp"]  = "make\n",
        ["rust"] = "cargo build\n",
    }
    local command = commands[vim.bo.filetype]
    if command then
        Core.toggleFloatTerminal(function() vim.api.nvim_feedkeys(command, "n", false) end)
    else
        Core.warn("Compile command is empty.")
    end
end

Core.setKeyMaps {
    { { "i", "s" },      "jk",         "<Esc>",                  opts },
    { "t",               "<Esc>",      "<C-\\><C-n>",            opts }, -- in terminal switch TERMINAL mode to NORMAL mode
    { "n",               "<M-2>",      "@q",                     opts },
    { "n",               "<F5>",       codeCompile,              opts },
    { { "n", "i", "v" }, "<Home>",     betterHome,               opts },
    { { "i", "v" },      "<M-i>",      betterHome,               opts },
    { { "i", "v" },      "<M-a>",      "<End>",                  opts },
    { { "n", "i" },      "<C-s>",      "<Cmd>w<CR>",             opts },
    { { "n", "i" },      "<C-z>",      "<Cmd>undo<CR>",          opts },
    { { "n", "i" },      "<C-y>",      "<Cmd>redo<CR>",          opts },
    { { "n", "v" },      "-",          "g_",                     opts },
    { "n",               "d-",         "d$",                     opts },
    { "n",               "Q",          "<Cmd>bdelete<CR>",       opts },
    { "n",               "<Tab>",      "<Cmd>bnext<CR>",         opts },
    { "n",               "<S-Tab>",    "<Cmd>bprevious<CR>",     opts },
    { "v",               "<Tab>",      ">gv",                    opts },
    { "v",               "<S-Tab>",    "<gv",                    opts },
    { "i",               "<S-Tab>",    "<C-d>",                  opts },
    { "i",               "<M-h>",      "<Left>",                 opts },
    { "i",               "<M-l>",      "<Right>",                opts },
    { "n",               "<leader>t",  Core.toggleFloatTerminal, opts },
    { "n",               "<leader>q",  "<Cmd>qa<CR>",            opts },
    { "n",               "<leader>h",  "gd",                     opts },
    { "n",               "<leader>nh", "<Cmd>noh<CR>",           opts },
    { "n",               "<C-a>",      "ggVG",                   opts },
    { "n",               "<M-a>",      "<C-o>",                  opts },
    { "n",               "<M-d>",      "<C-i>",                  opts },
    { { "n", "t" },      "<Leader>wh", "<Cmd>wincmd h<CR>",      opts },
    { { "n", "t" },      "<Leader>wj", "<Cmd>wincmd j<CR>",      opts },
    { { "n", "t" },      "<Leader>wk", "<Cmd>wincmd k<CR>",      opts },
    { { "n", "t" },      "<Leader>wl", "<Cmd>wincmd l<CR>",      opts },
    { "n",               "<M-j>",      ":move .+1<CR>",          opts }, -- move current line  down
    { "n",               "<M-k>",      ":move .-2<CR>",          opts }, -- move current line  up
    { "n",               "<M-J>",      ":copy .<CR>",            opts }, -- copy current line  down
    { "n",               "<M-K>",      ":copy .-1<CR>",          opts }, -- copy current line  up
    { "v",               "<M-j>",      ":move '>+1<CR>gv",       opts }, -- move select  block down
    { "v",               "<M-k>",      ":move '<-2<CR>gv",       opts }, -- move select  block up
    { "v",               "<M-J>",      ":copy '<-1<CR>gv",       opts }, -- copy select  block down
    { "v",               "<M-K>",      ":copy '><CR>gv",         opts }, -- copy select  block up
    { "c",               "<M-j>",      "<Down>",                 opts },
    { "c",               "<M-k>",      "<Up>",                   opts },
    { { "n", "i", "v" }, "<C-_>",      lineComment,              opts }, -- line-comment
    { { "n", "i", "v" }, "<C-/>",      lineComment,              opts }, -- line-comment
    -- { { "n", "i", "v" }, "<M-A>",      comment.hunk_comment,      opts }, -- hunk-comment
}
