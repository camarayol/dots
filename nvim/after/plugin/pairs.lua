local function compare_cursor_right(line, col, count, str)
    return line:sub(col + 1, col + count) == str
end

-- text\|  -> ' -> text\'|
-- text\\| -> ' -> text\\'|'
local function is_escaped(line, col)
    local escaped = false

    while col > 0 and line:byte(col) == string.byte('\\') do
        escaped = not escaped
        col = col - 1
    end

    return escaped
end

local function parse_samepairs_lr_count(line, col, left)
    local lcount, rcount = 0, 0
    local i, len = 1, #line

    while i <= len do
        if line:byte(i) == string.byte('\\') then
            i = i + 2
        else
            if i <= col then
                if line:byte(i) == string.byte(left) then lcount = lcount + 1 end
            else
                if line:byte(i) == string.byte(left) then rcount = rcount + 1 end
            end
            i = i + 1
        end
    end
    return lcount, rcount
end

local function parse_diffpairs_lr_count(line, col, left, right)
    local lcount, rcount = 0, 0
    local i, len = 1, #line

    while i <= len do
        if line:byte(i) == string.byte('\\') then
            i = i + 2
        else
            if i <= col then
                if line:byte(i) == string.byte(left) then lcount = lcount + 1 end
                if line:byte(i) == string.byte(right) then lcount = lcount - 1 end
            else
                if line:byte(i) == string.byte(left) then lcount = lcount + 1 end
                if line:byte(i) == string.byte(right) then rcount = rcount + 1 end
            end
            i = i + 1
        end
    end
    return lcount, rcount
end

local function is_filetype(ft) return vim.tbl_contains(ft, vim.bo.filetype) end

local function feedkeys(key) vim.api.nvim_feedkeys(vim.keycode(key), 'nt', false) end

local function parse_list(line)
    local indent, bullet, content = line:match('^(%s*)([-+*])%s*(.*)$')
    if bullet then
        return indent, bullet, content, false
    end

    local num
    indent, num, content = line:match('^(%s*)(%d+)%.%s*(.*)$')
    if num then
        return indent, num, content, true
    end
end

local M = {}

M.ctx = {}

function M.update_ctx()
    M.ctx.line = vim.api.nvim_get_current_line()
    M.ctx.row, M.ctx.col = unpack(vim.api.nvim_win_get_cursor(0))
    M.ctx.run_cr_post = false
    M.ctx.run_bs_post = false
end

M.cr_hooks = {
    post = {
        when = function()
            return is_filetype { 'markdown' } and parse_list(M.ctx.line) ~= nil
        end,
        callback = function()
            if not M.ctx.run_cr_post or not M.cr_hooks.post.when() then
                return
            end

            local _, bullet, content, ordered = parse_list(M.ctx.line)
            if content == '' then
                return vim.api.nvim_set_current_line('')
            end
            return feedkeys(ordered and (tonumber(bullet) + 1 .. '. ') or (bullet .. ' '))
        end,
    },
}

M.bs_hooks = {
    prev = nil,
    post = {
        when = function()
            if not is_filetype { 'markdown' } or M.ctx.col ~= #M.ctx.line then
                return false
            end

            local _, _, content = parse_list(M.ctx.line)

            return content == ''
        end,
        callback = function()
            if not M.ctx.run_bs_post or not M.bs_hooks.post.when() then
                return
            end

            for _ = 2, M.ctx.col do
                feedkeys('<BS>')
            end
        end,
    },
}

M.space_hooks = {
    post = {
        when = function()
            if not is_filetype { 'markdown' } then return false end

            return M.ctx.line:sub(1, M.ctx.col):match('^%s*[-+*]%s*%[$') ~= nil
                and M.ctx.line:sub(M.ctx.col + 1, M.ctx.col + 1) == ']'
        end,
        callback = function()
            if not M.space_hooks.post.when() then
                return
            end

            feedkeys('<BS><Right>')
        end,
    },
}

M.pairs = {
    ['('] = { right = ')', opts = { space = true, cr = true, indent = true } },
    ['['] = { right = ']', opts = { space = true, cr = true, indent = true } },
    ['{'] = { right = '}', opts = { space = true, cr = true, indent = true } },
    ["'"] = { right = "'", opts = { space = false, cr = false, indent = false } },
    ['"'] = { right = '"', opts = { space = false, cr = false, indent = false } },
    ['`'] = {
        right = '`',
        opts = {
            space = false,
            indent = false,
            cr = function(line, lline, rline, row, col)
                if lline:match('^%s*```[%w_+-]*$') and compare_cursor_right(rline, 0, 3, '```') then
                    local indent = line:match('^%s*') or ''
                    vim.api.nvim_buf_set_lines(0, row - 1, row, true, { lline, indent, indent .. rline })
                    vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
                    return
                end
                M.ctx.run_cr_post = true
                return feedkeys('<CR>')
            end
        }
    },
}

local cr = function()
    local line, row, col = M.ctx.line, M.ctx.row, M.ctx.col
    local lline = line:sub(1, col):match('^(.-)%s*$')
    local rline = line:sub(col + 1):match('^%s*(.*)')
    local left, right = lline:sub(-1), rline:sub(1, 1)
    local ropts = M.pairs[left] or M.pairs[right]

    if not ropts or ropts.right ~= right
        or (type(ropts.opts.cr) == 'boolean' and not ropts.opts.cr) then
        M.ctx.run_cr_post = true
        return feedkeys('<CR>')
    end

    if type(ropts.opts.cr) == 'function' then
        return ropts.opts.cr(line, lline, rline, row, col)
    end

    --                {
    -- {|} -> <CR> ->     |
    --                }
    local width  = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or vim.bo.tabstop
    local indent = line:match('^%s*') or ''
    local cline  = indent .. (ropts.opts.indent and string.rep(' ', width) or '')

    vim.api.nvim_buf_set_lines(0, row - 1, row, true, { lline, cline, indent .. rline })
    vim.api.nvim_win_set_cursor(0, { row + 1, #cline })
end

local bs = function()
    local line, row, col = M.ctx.line, M.ctx.row, M.ctx.col

    -- {
    -- | -> <BS> -> {|}
    -- }
    --
    -- local opt = {
    -- |             -> <BS> -> local opt = {|}
    -- }
    if line:match('^%s*$') and row > 1 and row < vim.api.nvim_buf_line_count(0) then
        local prevline = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, true)[1]
        local nextline = vim.api.nvim_buf_get_lines(0, row - 0, row + 1, true)[1]:match('^%s*(.*)')

        local left, right = prevline:sub(-1), nextline:match('%S')
        if not left or not right then
            M.ctx.run_bs_post = true
            return feedkeys('<BS>')
        end

        local ropts = M.pairs[left]

        -- ```
        if not ropts then
            ropts = M.pairs[right]
            if ropts and not prevline:match('^%s*' .. vim.pesc(right)) then
                ropts = nil
            end
        end

        if not ropts or ropts.right ~= right or (type(ropts.opts.cr) == 'boolean' and not ropts.opts.cr) then
            M.ctx.run_bs_post = true
            return feedkeys('<BS>')
        end

        -- {                {
        --     | -> <BS> -> |
        -- }                }
        if col > #prevline then
            M.ctx.run_bs_post = true
            return feedkeys('<BS>')
        end

        vim.api.nvim_buf_set_lines(0, row - 2, row + 1, true, { prevline .. nextline })
        vim.api.nvim_win_set_cursor(0, { row - 1, #prevline })
        return
    end

    if line:match('%S') then
        local left  = line:sub(col, col)
        local right = line:sub(col + 1, col + 1)

        -- {  |  } -> <BS> -> { | } -> <BS> -> {|}
        if left == ' ' and right == ' ' then
            vim.api.nvim_buf_set_text(0, row - 1, col - 1, row - 1, col + 1, { '' })
            vim.api.nvim_win_set_cursor(0, { row, col - 1 })
            return
        end

        local ropts = M.pairs[left]

        -- {|} -> <BS> -> |
        if ropts and ropts.right == right then
            vim.api.nvim_buf_set_text(0, row - 1, col - 1, row - 1, col + 1, { '' })
            vim.api.nvim_win_set_cursor(0, { row, col - 1 })
            return
        end

        M.ctx.run_bs_post = true
        return feedkeys('<BS>')
    end

    if row > 1 and row < vim.api.nvim_buf_line_count(0) then
        local prevline = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, true)[1]
        local nextline = vim.api.nvim_buf_get_lines(0, row - 0, row + 1, true)[1]:match('^%s*(.*)')

        vim.api.nvim_buf_set_lines(0, row - 2, row + 1, true, { prevline .. nextline })
        vim.api.nvim_win_set_cursor(0, { row - 1, #prevline })

        return
    end

    M.ctx.run_bs_post = true
    return feedkeys('<BS>')
end

-- {|}  -> <Space> -> { | }
-- {| } -> <Space> -> { | }
local function space()
    local left  = M.ctx.line:sub(M.ctx.col, M.ctx.col)
    local right = M.ctx.line:sub(M.ctx.col + 1, M.ctx.col + 1)

    local ropts = M.pairs[left]

    if ropts and right == ropts.right and ropts.opts.space then
        return feedkeys('<Space><Space><Left>')
    end

    return feedkeys('<Space>')
end

M.samepairs_input = function(left, opts)
    M.update_ctx()

    -- text\|  -> ' -> text\'|
    -- text\\| -> ' -> text\\'|'
    if is_escaped(M.ctx.line, M.ctx.col) then
        return left
    end

    local lcount, rcount = parse_samepairs_lr_count(M.ctx.line, M.ctx.col, left)

    if lcount % 2 > 0 then
        -- 'te|xt' -> ' -> 'te'|'xt'
        if rcount % 2 > 0 then
            return left .. left .. '<Left>'
        end

        -- 'text|' -> ' -> 'text'|
        if compare_cursor_right(M.ctx.line, M.ctx.col, 1, left) then
            return '<Right>'
        end

        -- 'text| -> ' -> 'text'|
        return left
    end

    -- | -> ' -> '|'
    -- te|x't' -> ' -> te'|'x't'
    if rcount % 2 == 0 then
        return left .. left .. '<Left>'
    end

    -- |text' -> ' -> '|text'
    return left
end

M.diffpairs_input_left = function(left, right, opts)
    M.update_ctx()

    -- text\|  -> { -> text\{|
    -- text\\| -> { -> text\\{|}
    if is_escaped(M.ctx.line, M.ctx.col) then
        return left
    end

    local lcount, rcount = parse_diffpairs_lr_count(M.ctx.line, M.ctx.col, left, right)

    -- |} -> {|}
    if rcount > lcount then
        return left
    end

    -- | -> { -> {|}
    -- {te|xt} -> { -> {te{|}xt}
    return left .. right .. '<Left>'
end

M.diffpairs_input_right = function(left, right, opts)
    M.update_ctx()

    -- text\|  -> } -> text\}|
    if is_escaped(M.ctx.line, M.ctx.col) then
        return right
    end

    -- { {|} -> { {}|}
    local lcount, rcount = parse_diffpairs_lr_count(M.ctx.line, M.ctx.col, left, right)
    if lcount > rcount then
        return right
    end

    -- {|} -> } -> {}|
    if compare_cursor_right(M.ctx.line, M.ctx.col, 1, right) then
        return '<Right>'
    end

    return right
end

vim.api.nvim_set_keymap('i', '<CR>', '', {
    noremap  = true,
    silent   = true,
    callback = function()
        M.update_ctx()

        cr()

        M.cr_hooks.post.callback()
    end,
})

vim.api.nvim_set_keymap('i', '<BS>', '', {
    noremap  = true,
    silent   = true,
    callback = function()
        M.update_ctx()

        bs()

        M.bs_hooks.post.callback()
    end,
})

vim.api.nvim_set_keymap('i', '<Space>', '', {
    noremap  = true,
    silent   = true,
    callback = function()
        M.update_ctx()

        space()

        M.space_hooks.post.callback()
    end,
})

for left, ropts in pairs(M.pairs) do
    if left == ropts.right then
        vim.api.nvim_set_keymap('i', left, '', {
            silent           = true,
            noremap          = true,
            expr             = true,
            replace_keycodes = true,
            callback         = function() return M.samepairs_input(left, ropts.opts) end
        })
    else
        vim.api.nvim_set_keymap('i', left, '', {
            silent           = true,
            noremap          = true,
            expr             = true,
            replace_keycodes = true,
            callback         = function() return M.diffpairs_input_left(left, ropts.right, ropts.opts) end
        })

        vim.api.nvim_set_keymap('i', ropts.right, '', {
            silent           = true,
            noremap          = true,
            expr             = true,
            replace_keycodes = true,
            callback         = function() return M.diffpairs_input_right(left, ropts.right, ropts.opts) end
        })
    end
end
