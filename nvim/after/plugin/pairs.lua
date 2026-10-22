local function feedkeys(key) vim.api.nvim_feedkeys(vim.keycode(key), 'nt', false) end

local function trycall(f)
    if f == nil then return true end
    return type(f) == 'function' and f() or false
end

local function is_escaped(line, col)
    local escaped = false

    while col > 0 and line:byte(col) == string.byte('\\') do
        escaped = not escaped
        col = col - 1
    end

    return escaped
end

local function is_comment_line(line)
    local commentstring = vim.bo.commentstring:match('^[^%s%%]+')
    if commentstring == nil then return false end

    return line:find(commentstring, 1, true) ~= nil
end

local function first_non_whitespace(line) return line:match('()(%S)') end

local function last_non_whitespace(line) return line:match('.*()(%S)') end

local function is_pairs_all_closed(line, left, right)
    local b = string.byte('\\')
    local l = string.byte(left)
    local r = string.byte(right)

    local i, len, count = 1, #line, 0

    while i <= len do
        local c = line:byte(i)

        if c == b then
            i = i + 2
        else
            if l == r then
                count = count + (c == l and (count == 0 and -1 or 1) or 0)
            else
                count = count + (c == l and 1 or (c == r and -1 or 0))
            end
            i = i + 1
        end
    end
    return count >= 0
end

local M = {}

-- Cursor line context
M.ctx = {
    line = '',
    row = -1,
    col = -1,

    update = function()
        M.ctx.line = vim.api.nvim_get_current_line()
        M.ctx.row, M.ctx.col = unpack(vim.api.nvim_win_get_cursor(0))
    end,

    compare_left = function(str)
        if M.ctx.col < #str then return false end
        return M.ctx.line:sub(M.ctx.col - #str + 1, M.ctx.col) == str
    end,

    compare_right = function(str)
        if #M.ctx.line - M.ctx.col < #str then return false end
        return M.ctx.line:sub(M.ctx.col + 1, M.ctx.col + #str) == str
    end
}

--- @class core.pairs.opts
--- @field left                 string
--- @field right                string
--- @field append_right         (fun(): boolean)?
--- @field expand_cr            (fun(): boolean)?
--- @field append_space         (fun(): boolean)?
--- @field input_left_callback  (fun(keycode: string): string)?
--- @field input_cr_callback    (fun(keycode: string): string)?

--- @type core.pairs.opts[]
M.pairs = {
    { left = '{', right = '}' },
    { left = '[', right = ']' },
    {
        left = '(',
        right = ')',
        -- |    -> ( -> (|)
        -- |abc -> ( -> (|abc
        append_right = function() return not M.ctx.line:sub(M.ctx.col + 1, M.ctx.col + 1):match('%w') end,
        expand_cr = function() return false end
    },
    {
        left = '"',
        right = '"',
        append_right = function() return not is_comment_line(M.ctx.line:sub(1, M.ctx.col)) end,
        expand_cr = function() return false end,
        append_space = function() return false end,
    },
    {
        left = "'",
        right = "'",
        append_right = function() return not is_comment_line(M.ctx.line:sub(1, M.ctx.col)) end,
        expand_cr = function() return false end,
        append_space = function() return false end,
    },
    {
        left = '`',
        right = '`',
        expand_cr = function() return false end,
        append_space = function() return false end,
        input_left_callback = function(keycode)
            if M.ctx.compare_left('``') then
                return keycode .. '``<Left><Left>'
            end
            return keycode
        end,
        input_cr_callback = function(keycode)
            local lline = M.ctx.line:sub(1, M.ctx.col)
            local rline = M.ctx.line:sub(M.ctx.col + 1)

            local width = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or vim.bo.tabstop
            local indent = M.ctx.line:match('^%s*') or ''

            if vim.bo.modifiable then
                vim.api.nvim_buf_set_lines(0, M.ctx.row - 1, M.ctx.row, true, { lline, indent, indent .. rline })
                vim.api.nvim_win_set_cursor(0, { M.ctx.row + 1, #indent })
            end

            return ''
        end
    },
}

function M.find_enclosing_pairs(left, right)
    for i, opts in ipairs(M.pairs) do
        if opts.left == left and opts.right == right then
            return opts
        end
    end
    return nil
end

function M.input_left(opts)
    -- \|  -> ' -> \'
    -- \\| -> ' -> \\'|'
    if is_escaped(M.ctx.line, M.ctx.col) then
        return opts.left
    end

    -- |}  -> { -> {|}
    if not is_pairs_all_closed(M.ctx.line, opts.left, opts.right) then
        return opts.left
    end

    -- '|' -> ' -> ''|
    if opts.left == opts.right and M.ctx.compare_right(opts.right) then
        return '<Right>'
    end

    -- | -> { -> {|}
    if trycall(opts.append_right) then
        return opts.left .. opts.right .. '<Left>'
    end

    return opts.left
end

function M.input_right(opts)
    -- {|} -> } -> {}|
    if M.ctx.compare_right(opts.right) then
        return '<Right>'
    end

    return opts.right
end

--- @return core.pairs.opts?
--- @return string
function M.try_bs_inline_pairs()
    local opts, keycode = nil, '<BS>'
    local lidx, left = last_non_whitespace(M.ctx.line:sub(1, M.ctx.col))
    local ridx, right = first_non_whitespace(M.ctx.line:sub(M.ctx.col + 1))

    if left and right then
        opts = M.find_enclosing_pairs(left, right)

        if opts then
            -- { | } -> <BS> -> {|}
            -- {|}   -> <BS> -> |
            if (M.ctx.compare_left(opts.left) and M.ctx.compare_right(opts.right))
                or (M.ctx.compare_left(opts.left .. ' ') and M.ctx.compare_right(' ' .. opts.right)) then
                keycode = '<BS><Del>'
            end
        end
    end

    return opts, keycode
end

--- @return core.pairs.opts?
--- @return string
function M.try_bs_expand_pairs()
    local opts, keycode = nil, '<BS>'
    local prevline = vim.api.nvim_buf_get_lines(0, M.ctx.row - 2, M.ctx.row - 1, true)[1]
    local nextline = vim.api.nvim_buf_get_lines(0, M.ctx.row - 0, M.ctx.row + 1, true)[1]

    local lidx, left = last_non_whitespace(prevline)
    local ridx, right = first_non_whitespace(nextline)

    -- ```lua|```
    if right == '`' and left ~= '`' and prevline:match('^%s*```%S+') then left = '`' end

    -- {                {
    --     | -> <BS> -> |
    -- }                }
    if lidx and ridx and M.ctx.col <= ridx then
        opts = M.find_enclosing_pairs(left, right)

        -- {            {|}
        -- | -> <BS> ->
        -- }
        if opts and vim.bo.modifiable then
            vim.api.nvim_buf_set_lines(0, M.ctx.row - 2, M.ctx.row + 1, true, { prevline .. nextline:sub(ridx) })
            vim.api.nvim_win_set_cursor(0, { M.ctx.row - 1, #prevline })
            keycode = ''
        end
    end

    return opts, keycode
end

--- @return core.pairs.opts?
--- @return string
function M.try_cr_expand_pairs()
    local opts, keycode = nil, '<CR>'
    local lline = M.ctx.line:sub(1, M.ctx.col)
    local rline = M.ctx.line:sub(M.ctx.col + 1)

    local lidx, left = last_non_whitespace(lline)
    local ridx, right = first_non_whitespace(rline)

    -- ```lua|```
    if right == '`' and left ~= '`' and lline:match('^%s*```%S+') then left = '`' end

    if lidx and ridx then
        opts = M.find_enclosing_pairs(left, right)
        if opts and vim.bo.modifiable and trycall(opts.expand_cr) then
            local width  = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or vim.bo.tabstop
            local indent = M.ctx.line:match('^%s*') or ''
            local cline  = indent .. string.rep(' ', width)

            -- {|}            {
            --     -> <CR> ->     |
            --                }
            vim.api.nvim_buf_set_lines(0, M.ctx.row - 1, M.ctx.row, true,
                { lline:sub(1, lidx), cline, indent .. rline:sub(ridx) })
            vim.api.nvim_win_set_cursor(0, { M.ctx.row + 1, #cline })
            keycode = ''
        end
    end

    return opts, keycode
end

-- Keymaps
for i, opts in ipairs(M.pairs) do
    core.sk('i', opts.left, function()
        M.ctx.update()

        local keycode = M.input_left(opts)

        if (type(opts.input_left_callback) == 'function') then
            keycode = opts.input_left_callback(keycode)
        end

        feedkeys(keycode)
    end)

    if opts.left ~= opts.right then
        core.sk('i', opts.right, function()
            M.ctx.update()

            local keycode = M.input_right(opts)

            feedkeys(keycode)
        end)
    end
end

core.sk('i', '<BS>', function()
    M.ctx.update()

    local opts = nil
    local keycode = '<BS>'

    if first_non_whitespace(M.ctx.line) then
        opts, keycode = M.try_bs_inline_pairs()
    elseif M.ctx.row > 1 and M.ctx.row < vim.api.nvim_buf_line_count(0) then
        opts, keycode = M.try_bs_expand_pairs()
    end

    feedkeys(keycode)
end)

core.sk('i', '<CR>', function()
    M.ctx.update()

    local opts, keycode = nil, '<CR>'

    if first_non_whitespace(M.ctx.line) then
        opts, keycode = M.try_cr_expand_pairs()
    end

    if opts and type(opts.input_cr_callback) == 'function' then
        keycode = opts.input_cr_callback(keycode)
    end

    feedkeys(keycode)
end)

core.sk('i', '<Space>', function()
    M.ctx.update()

    local keycode = '<Space>'

    local left = M.ctx.line:sub(M.ctx.col, M.ctx.col)
    local right = M.ctx.line:sub(M.ctx.col + 1, M.ctx.col + 1)

    local opts = M.find_enclosing_pairs(left, right)

    if opts and trycall(opts.append_space) then
        keycode = keycode .. '<Space><Left>'
    end

    feedkeys(keycode)
end)
