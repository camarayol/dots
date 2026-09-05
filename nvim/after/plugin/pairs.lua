local defpairs = {
    ['('] = { right = ')', space = true,  newline = true,  indent = true  },
    ['['] = { right = ']', space = true,  newline = true,  indent = true,  repeat_count = 2 },
    ['{'] = { right = '}', space = true,  newline = true,  indent = true  },
    ["'"] = { right = "'", space = false, newline = false, indent = false },
    ['"'] = { right = '"', space = false, newline = false, indent = false },
    ['`'] = { right = '`', space = false, newline = true,  indent = false, repeat_count = 3 },
}

local feedkeys = function(key) vim.api.nvim_feedkeys(vim.keycode(key), 'nt', false) end

local cr = function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()

    local lline, rline = line:sub(1, col), line:sub(col + 1)

    local left, right = lline:match("(%S)%s*$"), rline:match("^%s*(%S)")

    local pair = defpairs[left]

    --                {
    -- {|} -> <CR> ->     |
    --                }
    if pair and pair.right == right and pair.newline then
        local width = vim.bo.shiftwidth > 0 and vim.bo.shiftwidth or vim.bo.tabstop

        local indent = line:match('^%s*') or ''
        local cline = indent .. (pair.indent and string.rep(' ', width) or '')

        vim.api.nvim_buf_set_lines(0, row - 1, row, true, { lline, cline, indent .. rline })

        return vim.api.nvim_win_set_cursor(0, { row + 1, #cline })
    end

    return feedkeys('<CR>')
end

local bs = function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()

    -- {
    -- | -> <BS> -> {|}
    -- }
    --
    -- local opt = {
    -- |             -> <BS> -> local opt = {|}
    -- }
    if col == 0 then
        if row > 1 and row < vim.api.nvim_buf_line_count(0) then
            local prevline = vim.api.nvim_buf_get_lines(0, row - 2, row - 1, true)[1]
            local nextline = vim.api.nvim_buf_get_lines(0, row - 0, row + 1, true)[1]:match('^%s*(.*)')

            local left, right = prevline:sub(-1), nextline:match('%S')

            if left and right then
                local pair = defpairs[left]
                if pair and pair.right == right and pair.newline then
                    vim.api.nvim_buf_set_lines(0, row - 2, row + 1, true, { prevline .. nextline })
                    vim.api.nvim_win_set_cursor(0, { row - 1, #prevline })
                    return
                end
            end
        end
        return feedkeys('<BS>')
    end

    if line:match('%S') then
        local left, right = line:sub(col, col), line:sub(col + 1, col + 1)

        -- {  |  } -> <BS> -> { | } -> <BS> -> {|}
        if left == ' ' and right == ' ' then
            local lleft, rright = line:sub(col - 1, col - 1), line:sub(col + 2, col + 2)
            if lleft == ' ' and rright == ' ' then
                vim.api.nvim_buf_set_text(0, row - 1, col - 1, row - 1, col + 1, { '' })
                vim.api.nvim_win_set_cursor(0, { row, col - 1 })
                return
            end
            local pair = defpairs[lleft]
            if pair and pair.right == rright and pair.space then
                vim.api.nvim_buf_set_text(0, row - 1, col - 1, row - 1, col + 1, { '' })
                vim.api.nvim_win_set_cursor(0, { row, col - 1 })
                return
            end
        end

        -- {|} -> <BS> -> |
        local pair = defpairs[left]
        if pair and pair.right == right then
            vim.api.nvim_buf_set_text(0, row - 1, col - 1, row - 1, col + 1, { '' })
            vim.api.nvim_win_set_cursor(0, { row, col - 1 })
            return
        end

        return feedkeys('<BS>')
    end

    return feedkeys('<BS>')
end

-- {|}  -> <Space> -> { | }
-- {| } -> <Space> -> { | }
local space = function()
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()

    local left, right = line:sub(col, col), line:sub(col + 1, col + 1)

    local pair = defpairs[left]

    if pair and pair.right == right and pair.space then
        vim.api.nvim_buf_set_text(0, row - 1, col, row - 1, col, { ' ' })
    end

    return feedkeys('<Space>')
end

local lpair = function(left, ropts)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()

    local lch, rch = line:sub(col, col), line:sub(col + 1, col + 1)

    -- |  -> { -> {|}
    -- |} -> { -> {|}
    if lch ~= left then
        if rch == ropts.right then
            return feedkeys(left)
        else
            return feedkeys(left .. ropts.right .. '<Left>')
        end
    end

    -- '|' -> ' -> ''|
    if rch == ropts.right and left == ropts.right and not ropts.repeat_count then
        return feedkeys('<Right>')
    end

    -- | -> [ -> [|] -> [ -> [[|]]
    -- | -> ` -> `|` -> ` -> ``|` -> ` -> ```|```
    if ropts.repeat_count then
        local lcount, rcount = 0, 0

        for i = col, 1, -1 do
            if line:sub(i, i) ~= left or lcount >= ropts.repeat_count then
                break
            end
            lcount = lcount + 1
        end

        for i = col + 1, #line do
            if line:sub(i, i) ~= ropts.right or rcount >= ropts.repeat_count then
                break
            end
            rcount = rcount + 1
        end

        if lcount == ropts.repeat_count and rcount == ropts.repeat_count then
            return
        end

        if lcount == rcount and lcount >= 1 and lcount < ropts.repeat_count then
            local text = string.rep(left, lcount + 1) .. string.rep(ropts.right, rcount + 1)
            vim.api.nvim_buf_set_text(0, row - 1, col - lcount, row - 1, col + rcount, { text })
            vim.api.nvim_win_set_cursor(0, { row, col + 1 })
            return
        end
    end

    return feedkeys(left)
end

local rpair = function(left, ropts)
    local row, col = unpack(vim.api.nvim_win_get_cursor(0))
    local line = vim.api.nvim_get_current_line()

    -- {|} -> } -> {}|
    if line:sub(col + 1, col + 1) == ropts.right then
        feedkeys('<Right>')
    else
        feedkeys(ropts.right)
    end
end

vim.api.nvim_set_keymap('i', '<CR>',    '', { noremap = true, silent = true, callback = cr    })
vim.api.nvim_set_keymap('i', '<BS>',    '', { noremap = true, silent = true, callback = bs    })
vim.api.nvim_set_keymap('i', '<Space>', '', { noremap = true, silent = true, callback = space })

for left, ropts in pairs(defpairs) do
    vim.api.nvim_set_keymap('i', left, '', {
        noremap = true, silent = true, callback = function() lpair(left, ropts) end
    })

    if left ~= ropts.right then
        vim.api.nvim_set_keymap('i', ropts.right, '', {
            noremap = true, silent = true, callback = function() rpair(left, ropts) end
        })
    end
end
