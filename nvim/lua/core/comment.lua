local opts = {
    line = {
        default = '#',
        lua     = '--',
        cpp     = '//',
        go      = '//',
        vim     = '"',
        rust    = '//',
        kdl     = '//',
    },
    hunk = {
        default = { '/*', '*/' },
        lua = { '--[[', ']]' },
    },
    space = ' '
}

local function get_comment_characters(chs)
    return chs[vim.bo.filetype] or chs['default']
end

local function get_comment_ranges()
    local range = {}
    local mode = vim.api.nvim_get_mode().mode
    if mode == 'n' or mode == 'i' then
        local pos, _ = unpack(vim.api.nvim_win_get_cursor(0))
        range.spos, range.epos = pos, pos
    else
        local spos, epos = vim.fn.getpos('v'), vim.fn.getpos('.')
        range.spos, range.epos = math.min(spos[2], epos[2]), math.max(spos[2], epos[2])
    end
    range.lines = vim.api.nvim_buf_get_lines(0, range.spos - 1, range.epos, false)
    return range
end

local function get_comment_status(ch, ranges, type)
    if type == 'line' then
        for i = 1, #ranges.lines do
            local _, pos = ranges.lines[i]:find('^%s*' .. ch:gsub('(%p)', '%%%1'))
            if pos == nil then
                return false
            end
        end
        return true
    elseif type == 'hunk' then
        local sline, eline = ranges.lines[1], ranges.lines[#ranges.lines]
        local spos, _ = sline:find("^%s*" .. ch[1]:gsub("(%p)", "%%%1"))
        local epos, _ = eline:find(ch[2]:gsub("(%p)", "%%%1") .. "%s*")
        if not spos or not epos then
            return false
        end
        return true
    end
end

local function get_insert_status(ranges, commented)
    if not commented and ranges.epos == ranges.spos then
        if not ranges.lines[1]:find('%S') then
            return true
        end
    end
    return false
end

return {
    line_comment = function()
        -- 1. get the comment characters for the corresponding filetype
        -- 2. get line comment/uncomment range
        -- 3. check comment/uncomment status
        -- 4. change to INSERT mode while comment a whitespace line
        -- 5. update comment/uncomment contents
        local ch = get_comment_characters(opts.line)
        local ranges = get_comment_ranges()
        local commented = get_comment_status(ch, ranges, 'line')
        local start_insert = get_insert_status(ranges, commented)

        if commented then
            for i = 1, #ranges.lines do
                local spos, epos = ranges.lines[i]:find(ch:gsub('(%p)', '%%%1') .. '%s?')
                if spos and epos then
                    ranges.lines[i] = string.rep(' ', spos - 1) .. ranges.lines[i]:sub(epos + 1)
                else
                    ranges.lines[i] = ''
                end
            end
        else
            local minpos = -1
            for i = 1, #ranges.lines do
                local _, epos = ranges.lines[i]:find('^%s*%S')
                if epos and (minpos == -1 or epos < minpos) then
                    minpos = epos
                end
            end

            for i = 1, #ranges.lines do
                if minpos then
                    ranges.lines[i] = string.rep(' ', minpos - 1) ..
                        ch .. opts.space .. ranges.lines[i]:sub(minpos)
                else
                    ranges.lines[i] = ch .. opts.space
                end
            end
        end

        vim.api.nvim_buf_set_lines(0, ranges.spos - 1, ranges.epos, false, ranges.lines)

        -- 6.
        if start_insert then
            vim.api.nvim_win_set_cursor(0, { ranges.spos, #ranges.lines[1] })
            if vim.api.nvim_get_mode().mode == 'n' then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('a', true, false, true), 'n', false)
            end
        end
    end,

    hunk_comment = function()
        local ch = get_comment_characters(opts.hunk)
        local ranges = get_comment_ranges()
        local commented = get_comment_status(ch, ranges, 'hunk')
        local start_insert = get_insert_status(ranges, commented)

        if commented then
            local spos, epos = ranges.lines[1]:find(ch[1]:gsub("(%p)", "%%%1") .. "%s?")
            if spos and epos then
                ranges.lines[1] = string.rep(" ", spos - 1) .. ranges.lines[1]:sub(epos + 1)
            end

            spos, epos = ranges.lines[#ranges.lines]:find("%s?" .. ch[2]:gsub("(%p)", "%%%1"))
            if spos and epos then
                ranges.lines[#ranges.lines] = ranges.lines[#ranges.lines]:sub(0, spos - 1)
            end
        else
            local _, epos = ranges.lines[1]:find("^%s*%S")
            if epos then
                ranges.lines[1] = string.rep(" ", epos - 1) .. ch[1] .. opts.space .. ranges.lines[1]:sub(epos)
            else
                ranges.lines[1] = ch[1] .. opts.space
            end
            ranges.lines[#ranges.lines] = ranges.lines[#ranges.lines] .. opts.space .. ch[2]
        end

        vim.api.nvim_buf_set_lines(0, ranges.spos - 1, ranges.epos, false, ranges.lines)

        if start_insert then
            vim.api.nvim_win_set_cursor(0, { ranges.spos, #ranges.lines[1] - #ch[2] - #opts.space })
            if vim.api.nvim_get_mode().mode == "n" then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, false, true), "n", false)
            end
        end
    end
}
