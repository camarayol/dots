--- Continue Markdown bullet list on <CR> or 'o'
local o  = vim.fn.maparg('o', 'n', false, true)
local cr = vim.fn.maparg('<CR>', 'i', false, true)

local function feedkeys(key) vim.api.nvim_feedkeys(vim.keycode(key), 'nt', false) end

local function check_bullet_list()
    local line = vim.api.nvim_get_current_line()
    local _, marker, content = line:match('^(%s*)(%d+)%.%s*(.*)$')

    local nmarker

    if marker then
        nmarker = (marker + 1) .. '. '
    else
        _, marker, content = line:match('^(%s*)([-+*])%s*(.*)$')
        nmarker = marker and (marker .. ' ')
    end

    return nmarker, content
end

core.sk('i', '<CR>', function()
    local nmarker, content = check_bullet_list()

    if not nmarker then
        if cr and cr.callback then
            return cr.callback()
        end
        return feedkeys('<CR>')
    end

    if content == '' then
        vim.api.nvim_set_current_line('')
        return feedkeys('<CR>')
    end

    feedkeys('<CR>' .. nmarker)
end, { buf = vim.api.nvim_win_get_buf(0) })

core.sk('n', 'o', function()
    local nmarker, content = check_bullet_list()

    if not nmarker then
        if o and o.callback then
            return o.callback()
        end
        return feedkeys('o')
    end

    if content == '' then
        vim.api.nvim_set_current_line('')
        return feedkeys('o')
    end

    feedkeys('o' .. nmarker)
end, { buf = vim.api.nvim_win_get_buf(0) })
