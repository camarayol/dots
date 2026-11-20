-- simple auto-pairs and surround-pairs implementation
local M = {}

--- @class core.pairs.opts
--- @field left                 string
--- @field right                string
--- @field motion               string?
--- @field append_right         (fun(): boolean)?
--- @field expand_cr            (fun(): boolean)?
--- @field append_space         (fun(): boolean)?
--- @field input_left_callback  (fun(keycode: string): string)?
--- @field input_cr_callback    (fun(keycode: string): string)?

--- @type core.pairs.opts[]
M.pairs = {
    { left = '{', right = '}', motion = 'a{' },
    { left = '[', right = ']', motion = 'a[' },
    {
        left = '(', right = ')', motion = 'a(',
        -- |    -> ( -> (|)
        -- |abc -> ( -> (|abc
        append_right = function() return not M.ctx.line:sub(M.ctx.col + 1, M.ctx.col + 1):match('%w') end,
        expand_cr = function() return false end
    },
    {
        left = '<', right = '>', motion = 'a<',
        append_right = function() return false end,
        expand_cr = function() return false end,
    },
    {
        left = '"', right = '"', motion = 'a"',
        append_right = function() return not M.utils.is_comment_line(M.ctx.line:sub(1, M.ctx.col)) end,
        expand_cr = function() return false end,
        append_space = function() return false end,
    },
    {
        left = "'", right = "'", motion = "a'",
        append_right = function() return not M.utils.is_comment_line(M.ctx.line:sub(1, M.ctx.col)) end,
        expand_cr = function() return false end,
        append_space = function() return false end,
    },
    {
        left = '`', right = '`', motion = 'a`',
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

-- pairs cursor line context
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

-- pairs utils function
M.utils = {
    feedkeys = function(key) vim.api.nvim_feedkeys(vim.keycode(key), 'in', false) end,

    trycall = function(f)
        if f == nil then return true end
        return type(f) == 'function' and f() or false
    end,

    is_comment_line = function(line)
        local commentstring = vim.bo.commentstring:match('^[^%s%%]+')
        if commentstring == nil then return false end

        return line:find(commentstring, 1, true) ~= nil
    end,

    is_escaped = function(line, col)
        local escaped = false

        while col > 0 and line:byte(col) == string.byte('\\') do
            escaped = not escaped
            col = col - 1
        end

        return escaped
    end,

    first_non_whitespace = function(line) return line:match('()(%S)') end,

    last_non_whitespace = function(line) return line:match('.*()(%S)') end,

    is_pairs_all_closed = function(line, left, right)
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
                    count = count + (c == l and (count == 0 and 1 or -1) or 0)
                else
                    count = count + (c == l and 1 or (c == r and -1 or 0))
                end
                i = i + 1
            end
        end
        return count == 0
    end,

    find_enclosing_pairs = function(left, right)
        for i, opts in ipairs(M.pairs) do
            if opts.left == left and opts.right == right then
                return opts
            end
        end
        return nil
    end,

    end_of_line = function()
        return vim.bo.fileformat == 'dos' and '\r\n' or (vim.bo.fileformat == 'mac' and '\r' or '\n')
    end,
}

-- input pairs left character
local function input_left(opts)
    -- \|  -> ' -> \'
    -- \\| -> ' -> \\'|'
    if M.utils.is_escaped(M.ctx.line, M.ctx.col) then
        return opts.left
    end

    -- |}  -> { -> {|}
    if not M.utils.is_pairs_all_closed(M.ctx.line, opts.left, opts.right) then
        return opts.left
    end

    -- '|' -> ' -> ''|
    if opts.left == opts.right and M.ctx.compare_right(opts.right) then
        return '<Right>'
    end

    -- | -> { -> {|}
    if M.utils.trycall(opts.append_right) then
        return opts.left .. opts.right .. '<Left>'
    end

    return opts.left
end

-- input pairs right character
local function input_right(opts)
    -- {|} -> } -> {}|
    if M.utils.is_pairs_all_closed(M.ctx.line, opts.left, opts.right) then
        if M.ctx.compare_right(opts.right) then
            return '<Right>'
        end
    end

    -- {{|} -> } -> {{|}}
    if M.utils.trycall(opts.append_right) and M.ctx.col < #M.ctx.line then
        return opts.right .. '<Left>'
    end

    return opts.right
end

--- @return core.pairs.opts?
--- @return string
local function try_bs_inline_pairs()
    local opts, keycode = nil, '<BS>'
    local lidx, left = M.utils.last_non_whitespace(M.ctx.line:sub(1, M.ctx.col))
    local ridx, right = M.utils.first_non_whitespace(M.ctx.line:sub(M.ctx.col + 1))

    if left and right then
        opts = M.utils.find_enclosing_pairs(left, right)

        if opts then
            -- { | } -> <BS> -> {|}
            -- {|}   -> <BS> -> |
            -- {{|}  -> <BS> -> {|}
            if (M.ctx.compare_left(opts.left) and M.ctx.compare_right(opts.right)
                    and M.utils.is_pairs_all_closed(M.ctx.line, opts.left, opts.right))
                or (M.ctx.compare_left(opts.left .. ' ') and M.ctx.compare_right(' ' .. opts.right)) then
                keycode = '<BS><Del>'
            end
        end
    end

    return opts, keycode
end

--- @return core.pairs.opts?
--- @return string
local function try_bs_expand_pairs()
    local opts, keycode = nil, '<BS>'
    local prevline = vim.api.nvim_buf_get_lines(0, M.ctx.row - 2, M.ctx.row - 1, true)[1]
    local nextline = vim.api.nvim_buf_get_lines(0, M.ctx.row - 0, M.ctx.row + 1, true)[1]

    local lidx, left = M.utils.last_non_whitespace(prevline)
    local ridx, right = M.utils.first_non_whitespace(nextline)

    -- ```lua|```
    if right == '`' and left ~= '`' and prevline:match('^%s*```%S+') then left = '`' end

    -- {                {
    --     | -> <BS> -> |
    -- }                }
    if lidx and ridx and M.ctx.col <= ridx then
        opts = M.utils.find_enclosing_pairs(left, right)

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
local function try_cr_expand_pairs()
    local opts, keycode = nil, '<CR>'
    local lline = M.ctx.line:sub(1, M.ctx.col)
    local rline = M.ctx.line:sub(M.ctx.col + 1)

    local lidx, left = M.utils.last_non_whitespace(lline)
    local ridx, right = M.utils.first_non_whitespace(rline)

    -- ```lua|```
    if right == '`' and left ~= '`' and lline:match('^%s*```%S+') then left = '`' end

    if lidx and ridx then
        opts = M.utils.find_enclosing_pairs(left, right)
        if opts and vim.bo.modifiable and M.utils.trycall(opts.expand_cr) then
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

-------------------------------------------------------------------------------------
--- ====> pairs keymaps
for i, opts in ipairs(M.pairs) do
    core.sk('i', opts.left, function()
        M.ctx.update()

        local keycode = input_left(opts)

        if (type(opts.input_left_callback) == 'function') then
            keycode = opts.input_left_callback(keycode)
        end

        M.utils.feedkeys(keycode)
    end)

    --- different left/right pairs keymap
    if opts.left ~= opts.right then
        core.sk('i', opts.right, function()
            M.ctx.update()

            local keycode = input_right(opts)

            M.utils.feedkeys(keycode)
        end)
    end
end

core.sk('i', '<BS>', function()
    M.ctx.update()

    local opts = nil
    local keycode = '<BS>'

    --- delete inline pairs
    if M.utils.first_non_whitespace(M.ctx.line) then
        opts, keycode = try_bs_inline_pairs()
    --- delete cross-line pairs
    elseif M.ctx.row > 1 and M.ctx.row < vim.api.nvim_buf_line_count(0) then
        opts, keycode = try_bs_expand_pairs()
    end

    M.utils.feedkeys(keycode)
end)

core.sk('i', '<CR>', function()
    M.ctx.update()

    local opts, keycode = nil, '<CR>'

    if M.utils.first_non_whitespace(M.ctx.line) then
        opts, keycode = try_cr_expand_pairs()
    end

    if opts and type(opts.input_cr_callback) == 'function' then
        keycode = opts.input_cr_callback(keycode)
    end

    M.utils.feedkeys(keycode)
end)

core.sk('i', '<Space>', function()
    M.ctx.update()

    local keycode = '<Space>'

    local left = M.ctx.line:sub(M.ctx.col, M.ctx.col)
    local right = M.ctx.line:sub(M.ctx.col + 1, M.ctx.col + 1)

    local opts = M.utils.find_enclosing_pairs(left, right)

    if opts and M.utils.trycall(opts.append_space) then
        keycode = keycode .. '<Space><Left>'
    end

    M.utils.feedkeys(keycode)
end)
--- <==== pairs keymaps
-------------------------------------------------------------------------------------


-- surround
M.surround = {
    hl = 'Search',
    ns = vim.api.nvim_create_namespace('core.pairs.surround'),
}

local function get_curpos()
    local curpos = vim.api.nvim_win_get_cursor(0)
    return { curpos[1], curpos[2] + 1 }
end

local function set_curpos(pos)
    if not pos then return end

    local lnum = math.min(math.max(pos[1], 1), vim.api.nvim_buf_line_count(0))
    local line_len = #(vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or '')
    vim.api.nvim_win_set_cursor(0, { lnum, math.max(math.min(pos[2] - 1, line_len - 1), 0) })
end

local function get_line(lnum)
    return vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ''
end

--- Re-indents the lines an action touched, like nvim-surround does: only when
--- the buffer actually has an indent provider.
local function indent_lines(first, last)
    if first >= last or not (vim.bo.equalprg ~= '' or vim.bo.indentexpr ~= ''
            or vim.bo.cindent or vim.bo.smartindent or vim.bo.lisp) then
        return
    end
    pcall(vim.api.nvim_command, ('silent normal! %dG=%dG'):format(first, last))
end

local function comes_before(pos1, pos2)
    return pos1[1] < pos2[1] or (pos1[1] == pos2[1] and pos1[2] <= pos2[2])
end

-- Moves a position off of surrounding whitespace: forward for the start of a
-- selection, backward for its end. This is what makes `( a )` and `(a)` behave
-- the same when the delete pattern is applied.
local function trim_pos(pos, start)
    local line = get_line(pos[1])
    if start then
        while line:sub(pos[2], pos[2]):match('%s') do pos[2] = pos[2] + 1 end
    else
        while pos[2] > 1 and line:sub(pos[2], pos[2]):match('%s') do pos[2] = pos[2] - 1 end
    end

    return pos
end

-- UTF-8 aware helpers, so that byte offsets coming from Lua patterns stay valid.
local function get_first_byte(pos)
    local line = get_line(pos[1])
    local byte = line:sub(pos[2], pos[2]):byte()
    if not byte then return pos end

    while pos[2] > 1 and byte >= 0x80 and byte < 0xc0 do
        pos[2] = pos[2] - 1
        byte = line:sub(pos[2], pos[2]):byte()
    end

    return pos
end

local function get_last_byte(pos)
    local byte = get_line(pos[1]):sub(pos[2], pos[2]):byte()
    if not byte then return pos end

    if byte >= 0xf0 then
        pos[2] = pos[2] + 3
    elseif byte >= 0xe0 then
        pos[2] = pos[2] + 2
    elseif byte >= 0xc0 then
        pos[2] = pos[2] + 1
    end

    return pos
end

local function adjust_selection(selection)
    selection.first_pos = get_first_byte(selection.first_pos)
    selection.last_pos = get_last_byte(selection.last_pos)
    return selection
end

local function get_text(selection)
    local first_pos, last_pos = selection.first_pos, selection.last_pos
    local last_col = math.min(last_pos[2], #get_line(last_pos[1]))

    return vim.api.nvim_buf_get_text(0, first_pos[1] - 1, first_pos[2] - 1, last_pos[1] - 1, last_col, {})
end

local function insert_text(pos, lines)
    local col = math.min(pos[2], #get_line(pos[1]) + 1)

    vim.api.nvim_buf_set_text(0, pos[1] - 1, col - 1, pos[1] - 1, col - 1, lines)
end

local function delete_selection(selection)
    vim.api.nvim_buf_set_text(0, selection.first_pos[1] - 1, selection.first_pos[2] - 1,
        selection.last_pos[1] - 1, selection.last_pos[2], {})
end

local function change_selection(selection, lines)
    vim.api.nvim_buf_set_text(0, selection.first_pos[1] - 1, selection.first_pos[2] - 1,
        selection.last_pos[1] - 1, selection.last_pos[2], lines)
end

--- Returns the current visual selection: `first_pos, last_pos`, the mode it was
--- made in ('v' / 'V' / '\22') and the desired column (`$` blocks only).
--- Must be called while visual mode is still active: `getpos('v')` is the anchor
--- and the cursor is the other end of the selection.
local function current_visual_selection()
    local mode = vim.api.nvim_get_mode().mode
    local anchor, cursor = vim.fn.getpos('v'), vim.fn.getpos('.')

    local first_pos, last_pos = { anchor[2], anchor[3] }, { cursor[2], cursor[3] }
    if not comes_before(first_pos, last_pos) then
        first_pos, last_pos = last_pos, first_pos
    end

    return first_pos, last_pos, mode, vim.fn.winsaveview().curswant
end

--- Marks are 1-indexed as well, nil when they do not exist.
local function get_mark(mark)
    local pos = vim.api.nvim_buf_get_mark(0, mark)
    if pos[1] == 0 then return nil end

    return { pos[1], pos[2] + 1 }
end

--- The no-op operator: `g@` needs *some* `operatorfunc`, and running `g@` with
--- this one only moves the `[` / `]` marks (see `operator_selection`) or refills
--- the redo buffer (see `set_repeat`). Reachable as `v:lua.__pairs.noop`.
local function noop() end

--- Runs a text object as an operator (`g@a(`), which makes Neovim put its range
--- into the `[` / `]` marks. Deliberately *not* done through visual mode: that
--- would let visual-mode mappings (mini.clue maps `a` / `i`) and visual-mode
--- plugins interfere with the motion.
--- @return table? first_pos, table? last_pos
local function operator_selection(motion)
    local curpos = get_curpos()

    vim.api.nvim_buf_del_mark(0, '[')
    vim.api.nvim_buf_del_mark(0, ']')
    vim.go.operatorfunc = 'v:lua.core.surround.noop'
    pcall(vim.cmd.normal, { args = { 'g@' .. motion }, bang = true })

    local first_pos, last_pos = get_mark('['), get_mark(']')
    set_curpos(curpos)

    return first_pos, last_pos
end

-- Highlighting the pair that `cs` matched.

--- Marks both delimiters of a pair, then clears the marks after
--- `surround_hl_duration` milliseconds.
local function highlight_selections(selections)
    if not selections then return end

    local buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_buf_clear_namespace(0, M.surround.ns, 0, -1)

    for _, selection in ipairs({ selections.left, selections.right }) do
        vim.api.nvim_buf_set_extmark(buf, M.surround.ns, selection.first_pos[1] - 1, selection.first_pos[2] - 1, {
            end_row = selection.last_pos[1] - 1,
            end_col = selection.last_pos[2],
            hl_group = M.surround.hl,
        })
    end

    -- Make the marks visible while blocking for the next input character.
    pcall(vim.api.nvim_command, 'redraw')
    vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(buf) then
            vim.api.nvim_buf_clear_namespace(buf, M.surround.ns, 0, -1)
        end
    end, 100)
end

-- Finding a pair.

--- Runs a text object and returns the range of the pair it found.
local function text_object_selection(motion)
    local curpos = get_curpos()
    local view = vim.fn.winsaveview()

    local function select()
        local first_pos, last_pos = operator_selection(motion)
        -- A delimiter pair always spans at least two characters, so a missing or
        -- single-character range means that the text object found nothing.
        if not first_pos or not last_pos then return nil end
        if first_pos[1] == last_pos[1] and first_pos[2] == last_pos[2] then return nil end

        trim_pos(first_pos, true)
        trim_pos(last_pos, false)
        if not comes_before(first_pos, last_pos) then return nil end

        return { first_pos = first_pos, last_pos = last_pos }
    end

    local selection = select()

    -- `a(` only looks at the block around the cursor, so nvim-surround jumps back
    -- to the delimiter and tries again: this is what makes `ds(` work with the
    -- cursor on (or after) the closing delimiter.
    if not selection then
        local char = motion:sub(2, 2)
        local quote = char == "'" or char == '"' or char == '`'
        -- Quotes are only looked up on the current line, so that we do not jump
        -- into an unrelated string that happens to be above the cursor.
        -- `\V` matches the delimiter literally, even for `[` or `\`.
        local pattern = '\\V' .. char:gsub('\\', '\\\\')
        local found = vim.fn.searchpos(pattern, quote and 'bncW' or 'bcW')

        if found[1] ~= 0 and (not quote or found[1] == curpos[1]) then
            if quote then vim.fn.searchpos(pattern, 'bcW') end

            selection = select()
        end
    end

    vim.fn.winrestview(view)
    set_curpos(curpos)

    return selection
end

local function pos_to_index(pos)
    local index = vim.api.nvim_buf_get_offset(0, pos[1] - 1) + pos[2]
    -- `nvim_buf_get_offset` assumes 1-byte EOLs; add back the CRs on Windows files.
    if vim.bo.fileformat == 'dos' then index = index + pos[1] - 1 end

    return index
end

local function index_to_pos(index)
    local lnum = vim.fn.byte2line(index)
    local col = index - vim.fn.line2byte(lnum) + 1

    return { lnum, col }
end

--- Splits the text object that contains a pair into the two delimiters, using a 4-capture Lua pattern
--- @return { left: table, right: table }?
local function split_selection(selection, pattern)
    local offset = pos_to_index(selection.first_pos)
    local text = table.concat(get_text(selection), M.utils.end_of_line())
    local ok, _, left_delimiter, first_index, right_delimiter, last_index = text:find(pattern)
    if not ok or type(first_index) ~= 'number' or type(last_index) ~= 'number' then
        return nil
    end

    local left_len = type(left_delimiter) == 'string' and #left_delimiter or 0
    local right_len = type(right_delimiter) == 'string' and #right_delimiter or 0
    local selections = {
        left = adjust_selection({
            first_pos = index_to_pos(offset + first_index - left_len - 1),
            last_pos = index_to_pos(offset + first_index - 2),
        }),
        right = adjust_selection({
            first_pos = index_to_pos(offset + last_index - right_len - 1),
            last_pos = index_to_pos(offset + last_index - 2),
        }),
    }

    -- A trailing delimiter can point just past the end of a line; normalize that
    -- to the beginning of the next line (or to the end of the buffer).
    for _, sel in ipairs({ selections.left, selections.right }) do
        if sel.last_pos[2] > #get_line(sel.last_pos[1]) then
            if sel.last_pos[1] < vim.api.nvim_buf_line_count(0) then
                sel.last_pos[1] = sel.last_pos[1] + 1
                sel.last_pos[2] = 0
            else
                sel.last_pos[2] = #get_line(sel.last_pos[1])
            end
        end
    end

    return selections
end

--- Returns the `M.pairs` entry that owns `char` and knows how to surround with it.
--- @return core.pairs.opts?
local function find_surround_opts(char)
    for _, opts in ipairs(M.pairs) do
        if opts.motion and (opts.left == char or opts.right == char) then return opts end
    end

    return nil
end

--- The opening character of a bracket pair introduces padding (`S(` -> `( ... )`),
--- the closing one and quotes never do: one rule for deleting and for adding.
--- @param opts core.pairs.opts
--- @param char string
local function is_padded(opts, char)
    return char == opts.left and opts.left ~= opts.right
end

--- The delete pattern for the key that was pressed. The opening character of a
--- bracket pair also absorbs its padding (`ds(` turns `( a )` into `a`), the
--- closing one only removes the delimiters (`ds)` leaves ` a `). Quotes never
--- add padding, so they always use the plain pattern.
local function surround_delete_pattern(opts, char)
    return is_padded(opts, char) and '^(. ?)().-( ?.)()$' or '^(.)().-(.)()$'
end

--- All byte indices of `char` in `text`.
local function find_char_positions(text, char)
    local positions, init = {}, 1

    while true do
        local index = text:find(char, init, true)
        if not index then break end

        positions[#positions + 1] = index
        init = index + #char
    end

    return positions
end

--- Finds the closest `char ... char` around the cursor for a character that has
--- no `motion` (e.g. `abbbba` -> `cs a c`). There is no text object for those,
--- so the delimiters are looked up directly in the buffer: two consecutive
--- occurrences form a pair, and the innermost one holding the cursor wins.
--- @return { left: table, right: table }?
local function custom_selection(char)
    -- Control characters are far more likely to be a typo than a pair.
    if not char or char:find('%c') then return nil end

    local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), M.utils.end_of_line())
    local positions = find_char_positions(text, char)
    if #positions < 2 then return nil end

    local cursor, opening, closing = pos_to_index(get_curpos()), nil, nil

    for i = 1, #positions - 1 do
        if positions[i] <= cursor and cursor <= positions[i + 1] then
            opening, closing = positions[i], positions[i + 1]
        end
    end

    -- The cursor is outside of every pair: take the nearest one after it, or
    -- else the nearest one before it.
    if not opening then
        for i = 1, #positions - 1 do
            if positions[i] > cursor then
                opening, closing = positions[i], positions[i + 1]
                break
            end
        end
    end

    if not opening then
        for i = 1, #positions - 1 do
            if positions[i + 1] <= cursor then opening, closing = positions[i], positions[i + 1] end
        end
    end

    if not opening then return nil end

    local function delimiter(index)
        local pos = index_to_pos(index)
        return { first_pos = pos, last_pos = { pos[1], pos[2] + #char - 1 } }
    end

    return { left = delimiter(opening), right = delimiter(closing) }
end

--- Finds the delimiter pair of `char` around the cursor.
local function find_pair(char)
    local opts = find_surround_opts(char)
    if not opts then return custom_selection(char) end

    local selection = text_object_selection(opts.motion)
    if not selection then return nil end

    return split_selection(selection, surround_delete_pattern(opts, char))
end

-- Input / delimiters.

--- Reads a single character, nil on <Esc>/<C-c> or a special key.
local function get_char()
    local ok, char = pcall(vim.fn.getcharstr)
    if not ok or char == '\27' then return nil end

    -- `<F1>`, arrows, ... come back as a K_SPECIAL (0x80) sequence; they are not
    -- usable delimiters.
    if char:byte() == 0x80 then return nil end

    -- Multi-byte characters arrive as their UTF-8 bytes, anything else is a keycode.
    if #char == 1 or char:byte() >= 0x80 then return char end

    return vim.api.nvim_replace_termcodes(char, true, true, true)
end

--- Returns `{ left, right }` (lists of lines) for the given character:
--- the *opening* character of a bracket pair adds padding (`S(` -> `( ... )`),
--- the closing one does not (`S)` -> `(...)`), quotes never do.
--- @return string[][]?
local function get_delimiters(char, line_mode)
    if not char or char:find('%c') then return nil end

    local opts = find_surround_opts(char)
    local delimiters
    if opts then
        if is_padded(opts, char) then
            delimiters = { { opts.left .. ' ' }, { ' ' .. opts.right } }
        else
            delimiters = { { opts.left }, { opts.right } }
        end
    else
        -- Unknown character: use it on both sides, e.g. `Sx` -> `x...x`.
        delimiters = { { char }, { char } }
    end

    if line_mode then
        -- Put the delimiters on their own lines, without adding inner spaces.
        delimiters[1][#delimiters[1]] = delimiters[1][#delimiters[1]]:gsub('%s+$', '')
        delimiters[2][1] = delimiters[2][1]:gsub('^%s+', '')
        table.insert(delimiters[2], 1, '')
        table.insert(delimiters[1], '')
    end

    return delimiters
end

-- Actions.

-- `.` repeats the last `g@` operator, which runs `operatorfunc` again. The input
-- that was asked for the first time is reused, so `.` needs no extra mapping.
--- @class core.pairs.repeat_input
--- @field char string?
--- @field delimiters string[][]?
local repeat_input = {}

--- `.` repeats the last operator, so replaying `g@l` with a no-op operatorfunc
--- puts it back into the redo buffer and leaves the real callback installed for
--- the next repeat (a nested `g@a(` inside the action overwrites the redo buffer).
local function set_repeat(callback)
    local curpos = get_curpos()

    vim.go.operatorfunc = 'v:lua.core.surround.noop'
    pcall(vim.cmd.normal, { args = { 'g@l' }, bang = true })
    vim.go.operatorfunc = callback
    set_curpos(curpos)
end

--- First / last screen column of the character at `pos`, so that tabs and wide
--- characters line up when a block is wrapped.
local function char_start_vcol(pos)
    return vim.fn.strdisplaywidth(get_line(pos[1]):sub(1, pos[2] - 1)) + 1
end

local function char_end_vcol(pos)
    return vim.fn.strdisplaywidth(get_line(pos[1]):sub(1, get_last_byte(pos)[2]))
end

--- Wraps every line of a visual block selection, one pair per line. The columns
--- come from the block's screen columns, so tabs and wide characters line up;
--- lines that are too short are clamped to their last character.
local function surround_block(first_pos, last_pos, curswant, delimiters)
    local left_vcol = math.min(char_start_vcol(first_pos), char_start_vcol(last_pos))
    local right_vcol = math.max(char_end_vcol(first_pos), char_end_vcol(last_pos))
    local to_end_of_line = curswant == vim.v.maxcol

    for lnum = math.min(first_pos[1], last_pos[1]), math.max(first_pos[1], last_pos[1]) do
        local left_col = vim.fn.virtcol2col(0, lnum, left_vcol)
        local right_col = to_end_of_line and #get_line(lnum) or vim.fn.virtcol2col(0, lnum, right_vcol)

        if left_col > 0 and right_col >= left_col then
            insert_text({ lnum, right_col + 1 }, delimiters[2])
            insert_text({ lnum, left_col }, delimiters[1])
        end
    end
end

--- delete surround pairs
function surround_delete()
    repeat_input.char = repeat_input.char or get_char()
    if not repeat_input.char then return end

    local selections = find_pair(repeat_input.char)
    if not selections then return end

    -- Right first: deleting it does not invalidate the left positions.
    delete_selection(selections.right)
    delete_selection(selections.left)
    indent_lines(selections.left.first_pos[1], selections.right.first_pos[1])
    set_curpos(selections.left.first_pos)
    set_repeat('v:lua.core.surround.delete')
end

--- replace surround pairs
function surround_change()
    repeat_input.char = repeat_input.char or get_char()
    if not repeat_input.char then return end

    local selections = find_pair(repeat_input.char)
    if not selections then return end

    local delimiters = repeat_input.delimiters
    if not delimiters then
        -- Mark the matched pair while asking for the replacement.
        highlight_selections(selections)

        local new_char = get_char()

        vim.api.nvim_buf_clear_namespace(0, M.surround.ns, 0, -1)

        if not new_char then return end

        delimiters = get_delimiters(new_char, false)
        if not delimiters then return end

        repeat_input.delimiters = delimiters
    end

    -- The whitespace handling below mutates the delimiters, so work on a copy.
    delimiters = vim.deepcopy(delimiters)

    -- Drop whitespace that only existed because of the *old* delimiters: `( ... )`
    -- -> `(...)`, instead of ending up with `(  ...  )`.
    local line = get_line(selections.left.last_pos[1])
    local space_begin, space_end = line:find('%s*$')
    if space_begin - 1 <= selections.left.last_pos[2] then
        delimiters[1][#delimiters[1]] = delimiters[1][#delimiters[1]]:gsub('%s+$', '')
        selections.left.last_pos[2] = space_end
    end

    line = get_line(selections.right.first_pos[1])
    space_begin, space_end = line:find('^%s*')
    if space_end + 1 >= selections.right.first_pos[2] then
        delimiters[2][1] = delimiters[2][1]:gsub('^%s+', '')
        selections.right.first_pos[2] = space_end + 1
    end

    change_selection(selections.right, delimiters[2])
    change_selection(selections.left, delimiters[1])
    set_curpos(selections.left.first_pos)
    set_repeat('v:lua.core.surround.change')
end

--- add surround pairs in visual mode
local function surroound_add_visual()
    local first_pos, last_pos, mode, curswant = current_visual_selection()
    local char = get_char()

    -- Leave visual mode ourselves, also when the input was cancelled.
    pcall(vim.cmd.normal, { args = { vim.keycode('<Esc>') }, bang = true })

    if not char then return end

    local line_mode = mode == 'V'
    local delimiters = get_delimiters(char, line_mode)
    if not delimiters then return end

    if line_mode then
        first_pos = { first_pos[1], 1 }
        last_pos = { last_pos[1], #get_line(last_pos[1]) }

        insert_text({ last_pos[1], last_pos[2] + 1 }, delimiters[2])
        insert_text(first_pos, delimiters[1])
        indent_lines(first_pos[1], last_pos[1] + #delimiters[1] + #delimiters[2] - 2)
    elseif mode == '\22' then
        surround_block(first_pos, last_pos, curswant, delimiters)
    else
        if vim.o.selection == 'exclusive' then last_pos[2] = last_pos[2] - 1 end
        last_pos = get_last_byte(last_pos)

        insert_text({ last_pos[1], last_pos[2] + 1 }, delimiters[2])
        insert_text(first_pos, delimiters[1])
    end

    set_curpos(first_pos)
end

-------------------------------------------------------------------------------------
--- ====> surround keymaps
core.surround = {
    noop   = noop,
    delete = surround_delete,
    change = surround_change,
}

core.sk('n', 'ds', function()
    repeat_input = {}
    vim.go.operatorfunc = 'v:lua.core.surround.delete'

    return 'g@l'
end, { expr = true, desc = 'Delete surround pair' })

core.sk('n', 'cs', function()
    repeat_input = {}
    vim.go.operatorfunc = 'v:lua.core.surround.change'

    return 'g@l'
end, { expr = true, desc = 'Change surround pair' })

core.sk('x', 'S', surroound_add_visual, { desc = 'Add surround pair' })
--- <==== surround keymaps
-------------------------------------------------------------------------------------
