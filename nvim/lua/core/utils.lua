local M = {}

-- Home
M.Home = function()
    local feedkeys
    local _, col = unpack(vim.api.nvim_win_get_cursor(0))
    if col == 0 or vim.api.nvim_get_current_line():sub(0, col):match("^%s*$") then
        -- move cursor to the real beginning of the line
        feedkeys = "<Home>"
    else
        -- move cursor to beginning of non-whitespace characters of the line
        if vim.api.nvim_get_mode().mode == "i" then feedkeys = "<C-o>^" else feedkeys = "^" end
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(feedkeys, true, false, true), "n", false)
end

-- Comment
local opts = {
    line = {
        lua     = "--",
        cpp     = "//",
        go      = "//",
        vim     = '"',
        rust    = "//",
        default = '#',
    },
    hunk = {
        lua = { "--[[", "]]" },
        default = { "/*", "*/" },
    },
    space_padding = 1,
}

local spacePadding = function()
    return string.rep(" ", opts.space_padding)
end

local commentRanges = function()
    local range = {}
    local mode = vim.api.nvim_get_mode().mode
    if mode == "n" or mode == "i" then
        local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
        range.srow, range.erow = row, row
    else
        local spos, epos = vim.fn.getpos("v"), vim.fn.getpos(".")
        range.srow, range.erow = math.min(spos[2], epos[2]), math.max(spos[2], epos[2])
    end
    range.lines = vim.api.nvim_buf_get_lines(0, range.srow - 1, range.erow, false)
    return range
end


local lineCommentCheck = function(ch, range)
    for i = 1, #range.lines do
        local _, pos = range.lines[i]:find("^%s*" .. ch:gsub("(%p)", "%%%1"))
        if pos == nil then
            return false
        end
    end
    return true
end

local hunkCommentCheck = function(ch, range)
    local sline, eline = range.lines[1], range.lines[#range.lines]

    local spos, _ = sline:find("^%s*" .. ch[1]:gsub("(%p)", "%%%1"))
    local epos, _ = eline:find(ch[2]:gsub("(%p)", "%%%1") .. "%s*")
    if not spos or not epos then
        return false
    end

    return true
end

local lineCommentUpdate = function(ch, range, commented)
    if commented then
        for i = 1, #range.lines do
            local spos, epos = range.lines[i]:find(ch:gsub("(%p)", "%%%1") .. "%s?")
            if spos and epos then
                range.lines[i] = string.rep(" ", spos - 1) .. range.lines[i]:sub(epos + 1)
            else
                range.lines[i] = ""
            end
        end
    else
        local minpos = -1
        for i = 1, #range.lines do
            local _, epos = range.lines[i]:find("^%s*%S")
            if minpos == -1 or (epos and epos < minpos) then
                minpos = epos
            end
        end

        for i = 1, #range.lines do
            if minpos then
                range.lines[i] = string.rep(" ", minpos - 1) .. ch .. spacePadding() .. range.lines[i]:sub(minpos)
            else
                range.lines[i] = ch .. spacePadding()
            end
        end
    end
end

local hunkCommentUpdate = function(ch, range, commented)
    if commented then
        local spos, epos = range.lines[1]:find(ch[1]:gsub("(%p)", "%%%1") .. "%s?")
        if spos and epos then
            range.lines[1] = string.rep(" ", spos - 1) .. range.lines[1]:sub(epos + 1)
        end

        spos, epos = range.lines[#range.lines]:find("%s?" .. ch[2]:gsub("(%p)", "%%%1"))
        if spos and epos then
            range.lines[#range.lines] = range.lines[#range.lines]:sub(0, spos - 1)
        end
    else
        local _, epos = range.lines[1]:find("^%s*%S")
        if epos then
            range.lines[1] = string.rep(" ", epos - 1) .. ch[1] .. spacePadding() .. range.lines[1]:sub(epos)
        else
            range.lines[1] = ch[1] .. spacePadding()
        end
        range.lines[#range.lines] = range.lines[#range.lines] .. spacePadding() .. ch[2]
    end
end

M.CommentLine = function()
    local ft = vim.bo.filetype
    local ch = vim.deepcopy(opts.line[ft])
    if not ch then ch = vim.deepcopy(opts.line["default"]) end

    local range = commentRanges()
    local commented = lineCommentCheck(ch, range)

    local start_insert = false
    if not commented and range.srow == range.erow then
        if not range.lines[1]:find("%S") then
            start_insert = true
        end
    end

    lineCommentUpdate(ch, range, commented)
    vim.api.nvim_buf_set_lines(0, range.srow - 1, range.erow, false, range.lines)

    if start_insert then
        vim.api.nvim_win_set_cursor(0, { range.srow, #range.lines[1] })
        if vim.api.nvim_get_mode().mode == "n" then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("a", true, false, true), "n", false)
        end
    end
end

M.CommentHunk = function()
    local ft = vim.bo.filetype
    local ch = vim.deepcopy(opts.hunk[ft])
    if not ch then ch = vim.deepcopy(opts.hunk["default"]) end

    local range = commentRanges()
    local commented = hunkCommentCheck(ch, range)

    local start_insert = false
    if not commented and range.srow == range.erow then
        if not range.lines[1]:find("%S") then
            start_insert = true
        end
    end

    hunkCommentUpdate(ch, range, commented)
    vim.api.nvim_buf_set_lines(0, range.srow - 1, range.erow, false, range.lines)

    if start_insert then
        vim.api.nvim_win_set_cursor(0, { range.srow, #range.lines[1] - #ch[2] - #spacePadding() })
        if vim.api.nvim_get_mode().mode == "n" then
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, false, true), "n", false)
        end
    end
end

return M
