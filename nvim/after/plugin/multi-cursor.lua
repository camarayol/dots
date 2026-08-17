local track_ns = vim.api.nvim_create_namespace("multi-cursor-track")
local decor_ns = vim.api.nvim_create_namespace("multi-cursor-decor")
local next_region_id = 0

local M = {
    options = {
        keymaps = {
            global = {
                find_next       = "<C-n>",
                select_all      = "<C-d>",
                add_cursor_down = "<C-j>",
                add_cursor_up   = "<C-k>",
            },
            -- 多光标模式键默认继承 global; 只声明与全局不同的键
            multi_cursor = {
                find_previous   = "N",
                next_region     = "]",
                previous_region = "[",
                remove_region   = "q",
                insert          = "i",
                append          = "a",
                insert_bol      = "I",
                append_eol      = "A",
                insert_paste    = "<C-v>",
                change          = "c",
                delete          = "d",
                delete_char     = "x",
                yank            = "y",
                paste           = "p",
                undo            = "u",
                redo            = "U",
            },
        },
    },

    regions = {},
    active = 0,
    pattern = nil,
    register = nil,
    mode = "normal",
    syncing = false,
    expansion_stack = {},
    extend_origins = {},
    last_find = nil,
    augroup = nil,
    saved_maps = {},
    insert_state = nil,
    _insert_generation = 0,
}

core.nvim_set_highlights {
    ["MultiCursorCursor"]          = { bg = "#87afff", fg = "#4e4e4e" },
    ["MultiCursorActive"]          = { bg = "#dfdf87", fg = "#4e4e4e" },
    ["MultiCursorInsert"]          = { bg = "#4c4e50" },
    ["MultiCursorInsertActive"]    = { bg = "#4c4e50" },
    ["MultiCursorSelection"]       = { bg = "#005faf" },
    ["MultiCursorSelectionActive"] = { bg = "#87afff", fg = "#4e4e4e" },
}

core.set_keymaps {
    {
        modes = 'n',
        lhs = M.options.keymaps.global.find_next,
        rhs = function()
            M.enter()
            M.action.find_next()
        end,
        opts = { desc = 'Multi Cursor: find next' },
    },
    {
        modes = 'n',
        lhs = M.options.keymaps.global.select_all,
        rhs = function()
            M.enter()
            M.action.select_all()
        end,
        opts = { desc = 'Multi Cursor: select all' },
    },
    {
        modes = 'n',
        lhs = M.options.keymaps.global.add_cursor_down,
        rhs = function()
            M.enter()
            M.action.add_cursor_down()
        end,
        opts = { desc = 'Multi Cursor: add cursor down' },
    },
    {
        modes = 'n',
        lhs = M.options.keymaps.global.add_cursor_up,
        rhs = function()
            M.enter()
            M.action.add_cursor_up()
        end,
        opts = { desc = 'Multi Cursor: add cursor up' },
    },
    {
        modes = 'x',
        lhs = M.options.keymaps.global.find_next,
        rhs = function() M.from_visual_find_next() end,
        opts = { desc = 'Multi Cursor: find next from selection' },
    },
    {
        modes = 'x',
        lhs = M.options.keymaps.global.select_all,
        rhs = function() M.from_visual_select_all() end,
        opts = { desc = 'Multi Cursor: select all from selection' },
    },
}

---

M.action = {}



local function clamp_position(buf, row, col)
    local count = vim.api.nvim_buf_line_count(buf)
    row = math.max(0, math.min(row, count - 1))
    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, true)[1] or ""
    return { row = row, col = math.max(0, math.min(col, #line)) }
end

local function position_to_offset(buf, pos)
    return vim.api.nvim_buf_get_offset(buf, pos.row) + pos.col
end

local function offset_to_position(buf, offset)
    local count = vim.api.nvim_buf_line_count(buf)
    local last = count - 1
    local eof = vim.api.nvim_buf_get_offset(buf, last)
        + #(vim.api.nvim_buf_get_lines(buf, last, last + 1, true)[1] or "")
    offset = math.max(0, math.min(offset, eof))

    local low, high = 0, last
    while low <= high do
        local mid = math.floor((low + high) / 2)
        if vim.api.nvim_buf_get_offset(buf, mid) <= offset then
            low = mid + 1
        else
            high = mid - 1
        end
    end

    local row = math.max(0, high)
    local col = offset - vim.api.nvim_buf_get_offset(buf, row)
    return clamp_position(buf, row, col)
end

local function char_end(line, col)
    if col >= #line then
        return col
    end
    local ok, next_col = pcall(vim.str_byteindex, line, "utf-8", vim.str_utfindex(line, "utf-8", col) + 1)
    return ok and next_col or (col + 1)
end

local function previous_position(buf, pos)
    if pos.col > 0 then
        local line = vim.api.nvim_buf_get_lines(buf, pos.row, pos.row + 1, true)[1] or ""
        local chars = vim.str_utfindex(line, "utf-8", pos.col)
        return { row = pos.row, col = vim.str_byteindex(line, "utf-8", math.max(0, chars - 1)) }
    end
    if pos.row == 0 then
        return { row = 0, col = 0 }
    end
    local row = pos.row - 1
    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, true)[1] or ""
    if line == "" then
        return { row = row, col = 0 }
    end
    local chars = vim.str_utfindex(line, "utf-8", #line)
    return { row = row, col = vim.str_byteindex(line, "utf-8", math.max(0, chars - 1)) }
end

local WORD_REGEX = vim.regex([[\k\+]])

local function word_at(buf, row, col)
    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, true)[1] or ""
    if line == "" then
        return nil
    end

    col = math.min(col, math.max(0, #line - 1))
    local offset = 0
    while offset < #line do
        local start_col, end_col = WORD_REGEX:match_str(line:sub(offset + 1))
        if not start_col then
            break
        end
        start_col, end_col = start_col + offset, end_col + offset
        if start_col <= col and col < end_col then
            return {
                text = line:sub(start_col + 1, end_col),
                start = { row = row, col = start_col },
                finish = { row = row, col = end_col },
            }
        end
        offset = math.max(end_col, offset + 1)
    end
end

local function split_text(text)
    return vim.split(text, "\n", { plain = true })
end

local function get_text(buf, start_pos, end_pos)
    return table.concat(vim.api.nvim_buf_get_text(
        buf,
        start_pos.row,
        start_pos.col,
        end_pos.row,
        end_pos.col,
        {}
    ), "\n")
end

local function compare_pos(a, b)
    return a.row == b.row and a.col - b.col or a.row - b.row
end

-- virtcol([lnum, col]) 返回该位置的虚拟列 (integer)
---@param row integer
---@param col integer
---@return integer
local function virtcol_pos(row, col)
    return vim.fn.virtcol({ row, col }) --[[@as integer]]
end

-- Insert synchronization

local function end_positions()
    local wanted = {}
    for _, region in ipairs(M.regions) do
        wanted[region.end_id] = true
    end
    local positions = {}
    local marks = vim.api.nvim_buf_get_extmarks(0, track_ns, 0, -1, {})
    for _, mark in ipairs(marks) do
        if wanted[mark[1]] then
            positions[mark[1]] = { row = mark[2], col = mark[3] }
        end
    end
    return positions
end

local function insertion_position(region, kind)
    local start_pos, finish_pos = M.positions(region)
    if M.mode == "extend" then
        local line = vim.api.nvim_buf_get_lines(0, finish_pos.row, finish_pos.row + 1, true)[1] or ""
        local pos = kind == "i"
            and { row = start_pos.row, col = start_pos.col }
            or { row = finish_pos.row, col = finish_pos.col }
        if kind == "I" then
            pos.row = start_pos.row
            line = vim.api.nvim_buf_get_lines(0, pos.row, pos.row + 1, true)[1] or ""
            pos.col = #(line:match("^%s*") or "")
        elseif kind == "A" then
            pos.col = #line
        end
        return pos
    end

    local line = vim.api.nvim_buf_get_lines(0, start_pos.row, start_pos.row + 1, true)[1] or ""
    local pos = { row = start_pos.row, col = start_pos.col }
    if kind == "a" then
        pos.col = char_end(line, pos.col)
    elseif kind == "I" then
        pos.col = #(line:match("^%s*") or "")
    elseif kind == "A" then
        pos.col = #line
    end
    return pos
end

local function prepare(kind)
    local positions = {}
    for _, region in ipairs(M.regions) do
        positions[region.id] = insertion_position(region, kind)
    end
    for _, region in ipairs(M.regions) do
        local pos = positions[region.id]
        M._set_positions(region, pos, pos, true)
    end
end

local function prepare_new_lines(kind)
    local groups = {}
    local active_region = M.regions[M.active]
    for _, region in ipairs(M.regions) do
        local _, head = M.raw_positions(region)
        if head then
            local group = groups[head.row]
            if not group then
                group = { row = head.row, region = region, active = false }
                groups[head.row] = group
            elseif group.region ~= region then
                vim.api.nvim_buf_del_extmark(0, track_ns, region.start_id)
                vim.api.nvim_buf_del_extmark(0, track_ns, region.end_id)
            end
            if region == active_region then
                group.active = true
            end
        end
    end

    local ordered = vim.tbl_values(groups)
    table.sort(ordered, function(left, right)
        return left.row > right.row
    end)

    M.syncing = true
    for index, group in ipairs(ordered) do
        if index > 1 then
            pcall(vim.cmd.undojoin)
        end
        local line = vim.api.nvim_buf_get_lines(0, group.row, group.row + 1, true)[1] or ""
        local indent = vim.bo[0].autoindent and (line:match("^%s*") or "") or ""
        local insert_row = kind == "o" and group.row + 1 or group.row
        vim.api.nvim_buf_set_lines(0, insert_row, insert_row, false, { indent })
        group.mark = vim.api.nvim_buf_set_extmark(0, track_ns, insert_row, #indent, {
            right_gravity = false,
        })
    end
    M.syncing = false

    local regions, active_id = {}, nil
    for _, group in ipairs(ordered) do
        local mark = vim.api.nvim_buf_get_extmark_by_id(0, track_ns, group.mark, {})
        if #mark > 0 then
            local pos = { row = mark[1], col = mark[2] }
            M._set_positions(group.region, pos, pos, true)
            vim.api.nvim_buf_del_extmark(0, track_ns, group.mark)
            regions[#regions + 1] = group.region
            if group.active then
                active_id = group.region.id
            end
        end
    end
    M.regions = regions
    M.mode = "normal"
    M.sort_regions(active_id)
end

local function changed_text(buf, start_row, start_col, new_end_row, new_end_col)
    local end_row = start_row + new_end_row
    local end_col = new_end_row == 0 and start_col + new_end_col or new_end_col
    return vim.api.nvim_buf_get_text(buf, start_row, start_col, end_row, end_col, {})
end

local function mirror(event, generation)
    if M._insert_generation ~= generation then
        return
    end

    local state = M.insert_state
    if not state or state.generation ~= generation then
        return
    end

    local active = M.regions[M.active]
    if not active then
        return
    end

    local relative_start = event.relative_start
    local positions = end_positions()
    local simple_insert = relative_start == 0 and event.old_length == 0
    local targets = {}
    for index, region in ipairs(M.regions) do
        local cursor = positions[region.end_id]
        if index ~= M.active and cursor then
            local target = { cursor = cursor }
            if not simple_insert then
                target.start_offset = position_to_offset(0, cursor) + relative_start
            end
            targets[#targets + 1] = target
        end
    end

    M.syncing = true
    for index = #targets, 1, -1 do
        local target = targets[index]
        pcall(vim.cmd.undojoin)
        local start_pos, end_pos
        if simple_insert then
            start_pos, end_pos = target.cursor, target.cursor
        else
            start_pos = offset_to_position(0, target.start_offset)
            end_pos = offset_to_position(0, target.start_offset + event.old_length)
        end
        pcall(
            vim.api.nvim_buf_set_text,
            0,
            start_pos.row,
            start_pos.col,
            end_pos.row,
            end_pos.col,
            event.text
        )
    end
    M.syncing = false

    local active_pos = M._mark_pos(active.end_id)
    if active_pos then
        state.active_offset = position_to_offset(0, active_pos)
    end
end

local function ensure_insert_listener()
    if vim.b[0].mc_insert_attached then
        return
    end
    local ok = vim.api.nvim_buf_attach(0, false, {
        on_bytes = function(
            _, buf, _, start_row, start_col, start_byte, _, _, old_length,
            new_end_row, new_end_col, new_length
        )
            if M.syncing or M.mode ~= "insert" then
                return false
            end
            local state = M.insert_state
            if not state then
                return false
            end
            local generation = M._insert_generation
            if state.generation ~= generation then
                return false
            end
            state.changed = true
            local text = changed_text(buf, start_row, start_col, new_end_row, new_end_col)
            local relative_start = start_byte - state.input_offset
            local queue = state.queue
            local last = queue[#queue]
            if last and last.relative_start == 0 and last.old_length == 0
                and relative_start == 0 and old_length == 0
            then
                last.text[#last.text] = last.text[#last.text] .. text[1]
                for index = 2, #text do
                    last.text[#last.text + 1] = text[index]
                end
            else
                queue[#queue + 1] = {
                    relative_start = relative_start,
                    old_length = old_length,
                    text = text,
                }
            end
            state.input_offset = start_byte + new_length
            if not state.scheduled then
                state.scheduled = true
                vim.schedule(function()
                    local current = M.insert_state
                    if not current or current ~= state or current.generation ~= generation then
                        return
                    end
                    local q = current.queue
                    for index = 1, #q do
                        mirror(q[index], generation)
                    end
                    current.queue = {}
                    current.scheduled = false
                    current.input_offset = current.active_offset
                end)
            end
            return false
        end,
    })
    if ok then
        vim.b[0].mc_insert_attached = true
    end
end

local function insert(kind)
    if M.mode == "insert" or #M.regions == 0 then
        return
    end

    if kind == "o" or kind == "O" then
        prepare_new_lines(kind)
    else
        prepare(kind)
    end
    M.extend_origins = {}
    M.mode = "insert"
    M._insert_generation = (M._insert_generation or 0) + 1
    local generation = M._insert_generation
    local active = M.regions[M.active]
    local active_pos = M._mark_pos(active.end_id)
    local return_marks = {}
    for _, region in ipairs(M.regions) do
        local pos = M._mark_pos(region.end_id)
        if pos then
            local return_pos = pos
            if (kind == "a" or kind == "A") and pos.col > 0 then
                return_pos = previous_position(0, pos)
            end
            return_marks[region.id] = vim.api.nvim_buf_set_extmark(
                0,
                track_ns,
                return_pos.row,
                return_pos.col,
                { right_gravity = false, undo_restore = false, invalidate = false }
            )
        end
    end

    local active_offset = position_to_offset(0, active_pos)
    M.insert_state = {
        generation = generation,
        active_offset = active_offset,
        input_offset = active_offset,
        return_marks = return_marks,
        changed = false,
        queue = {},
        scheduled = false,
    }

    ensure_insert_listener()

    M.render()
    M.focus()
    local line = vim.api.nvim_buf_get_lines(0, active_pos.row, active_pos.row + 1, true)[1] or ""
    if #line > 0 and active_pos.col >= #line then
        vim.cmd("startinsert!")
    else
        vim.cmd("startinsert")
    end
end

local function insert_paste()
    if M.mode ~= "insert" or #M.regions == 0 then
        return
    end
    if M.insert_state then
        M.insert_state.changed = true
    end

    local values = M.register
    if not values or #values == 0 then
        values = { vim.fn.getreg('"') }
    end

    local positions = end_positions()
    local targets = {}
    local split_cache = {}
    for index, region in ipairs(M.regions) do
        local pos = positions[region.end_id]
        if pos then
            local text = values[index] or values[1] or ""
            split_cache[text] = split_cache[text] or split_text(text)
            targets[#targets + 1] = {
                pos = pos,
                lines = split_cache[text],
            }
        end
    end

    M.syncing = true
    for index = #targets, 1, -1 do
        local target = targets[index]
        pcall(vim.cmd.undojoin)
        pcall(
            vim.api.nvim_buf_set_text,
            0,
            target.pos.row,
            target.pos.col,
            target.pos.row,
            target.pos.col,
            target.lines
        )
    end
    M.syncing = false

    local active = M.regions[M.active]
    local active_pos = active and M._mark_pos(active.end_id)
    if active_pos then
        if M.insert_state then
            local offset = position_to_offset(0, active_pos)
            M.insert_state.active_offset = offset
            M.insert_state.input_offset = offset
        end
        pcall(vim.api.nvim_win_set_cursor, 0, { active_pos.row + 1, active_pos.col })
    end
end

local function insert_stop()
    if M.mode ~= "insert" then
        return
    end
    M.mode = "normal"
    M._insert_generation = (M._insert_generation or 0) + 1
    local state = M.insert_state
    M.insert_state = nil

    local positions = end_positions()
    for _, region in ipairs(M.regions) do
        local pos = positions[region.end_id]
        local return_mark = state and state.return_marks and state.return_marks[region.id]
        if state and not state.changed and return_mark then
            local saved = vim.api.nvim_buf_get_extmark_by_id(0, track_ns, return_mark, {})
            if #saved > 0 then
                pos = { row = saved[1], col = saved[2] }
            end
        elseif state and state.changed and pos and pos.col > 0 then
            pos = previous_position(0, pos)
        end
        if return_mark then
            vim.api.nvim_buf_del_extmark(0, track_ns, return_mark)
        end
        if pos then
            M._set_positions(region, pos, pos, false)
        end
    end
    M.render()
    M.focus()
end

local function save_map(mode, lhs)
    if not lhs or lhs == "" or lhs == false then
        return false
    end
    local id = mode .. "\0" .. lhs
    if M.saved_maps[id] == nil then
        local saved = vim.fn.maparg(lhs, mode, false, true)
        M.saved_maps[id] = {
            mode = mode,
            lhs = lhs,
            saved = saved.buffer == 1 and saved or false,
        }
    end
    return true
end

local function add_match(flags)
    local pattern = [[\C\V]] .. M.pattern:gsub([[\]], [[\\]]);

    local occupied = {}
    for _, region in ipairs(M.regions) do
        local start_pos = M.positions(region)
        if start_pos then
            local row_map = occupied[start_pos.row]
            if not row_map then
                row_map = {}
                occupied[start_pos.row] = row_map
            end
            row_map[start_pos.col] = true
        end
    end
    for _ = 1, #M.regions + 2 do
        local found = vim.fn.searchpos(pattern, flags)
        if found[1] == 0 then
            M.focus()
            return false
        end
        local match_start = { row = found[1] - 1, col = found[2] - 1 }
        local match_end = { row = match_start.row, col = match_start.col + #M.pattern }
        local row_map = occupied[match_start.row]
        if not row_map or not row_map[match_start.col] then
            return M.add_selection(match_start, match_end)
        end
        pcall(vim.api.nvim_win_set_cursor, 0, { found[1], found[2] - 1 })
    end
    M.focus()
    return false
end

local function find_from(from_pos, forward, flags)
    if #M.regions == 0 then
        return M.select_word()
    end
    if not M._pattern_from_selection() and (not M.pattern or M.pattern == "") then
        return false
    end
    if not from_pos then
        return false
    end
    local line = vim.api.nvim_buf_get_lines(0, from_pos.row, from_pos.row + 1, true)[1] or ""
    local col = forward and from_pos.col > 0 and math.min(#line, from_pos.col - 1) or from_pos.col
    pcall(vim.api.nvim_win_set_cursor, 0, { from_pos.row + 1, col })
    return add_match(flags)
end


M.action.find_next = function()
    local region = M.regions[M.active]
    local end_pos
    if region then
        _, end_pos = M.positions(region)
    end
    return find_from(end_pos, true, "w")
end

M.action.find_prev = function()
    local region = M.regions[M.active]
    local start_pos
    if region then
        start_pos = M.positions(region)
    end
    return find_from(start_pos, false, "bw")
end

M.action.insert_paste = function()
    if M.mode == "insert" then
        insert_paste()
    end
end
for _, motion in ipairs({ "h", "j", "k", "l", "w", "b", "e", "0", "^", "$" }) do
    M.action["move_" .. motion] = function() M.action.move(motion) end
end
for _, motion in ipairs({ "f", "F" }) do
    M.action["find_char_" .. motion] = function() M.action.find_char(motion) end
end

local function set_multi_cursor_keymaps()
    local maps_all = M.options.keymaps
    local keys = {}
    for k, v in pairs(maps_all.global) do
        keys[k] = v
    end
    for k, v in pairs(maps_all.multi_cursor) do
        keys[k] = v
    end

    local maps = {
        { modes = "n", lhs = keys.find_next,       rhs = M.action.find_next },
        { modes = "n", lhs = keys.find_previous,   rhs = M.action.find_prev },
        { modes = "n", lhs = keys.select_all,      rhs = M.action.select_all },
        { modes = "n", lhs = keys.add_cursor_down, rhs = M.action.add_cursor_down },
        { modes = "n", lhs = keys.add_cursor_up,   rhs = M.action.add_cursor_up },
        { modes = "n", lhs = keys.next_region,     rhs = M.action.next_region },
        { modes = "n", lhs = keys.previous_region, rhs = M.action.previous_region },
        { modes = "n", lhs = keys.remove_region,   rhs = M.action.remove_region },
        { modes = "n", lhs = keys.insert,          rhs = M.action.insert },
        { modes = "n", lhs = keys.append,          rhs = M.action.append },
        { modes = "n", lhs = keys.insert_bol,      rhs = M.action.insert_bol },
        { modes = "n", lhs = keys.append_eol,      rhs = M.action.append_eol },
        { modes = "n", lhs = keys.change,          rhs = M.action.change },
        { modes = "n", lhs = keys.delete,          rhs = M.action.delete },
        { modes = "n", lhs = keys.delete_char,     rhs = M.action.delete_char },
        { modes = "n", lhs = keys.yank,            rhs = M.action.yank },
        { modes = "n", lhs = keys.paste,           rhs = M.action.paste },
        { modes = "n", lhs = keys.undo,            rhs = M.action.undo },
        { modes = "n", lhs = keys.redo,            rhs = M.action.redo },
        { modes = "n", lhs = "<Esc>",              rhs = M.action.escape },

        { modes = "n", lhs = "v",                  rhs = M.action.expand_selection },
        { modes = "n", lhs = "V",                  rhs = M.action.shrink_selection },
        { modes = "n", lhs = "D",                  rhs = M.action.delete_to_eol },
        { modes = "n", lhs = "o",                  rhs = M.action.open_below },
        { modes = "n", lhs = "O",                  rhs = M.action.open_above },
        { modes = "n", lhs = ";",                  rhs = M.action.repeat_find },
        { modes = "n", lhs = ",",                  rhs = M.action.repeat_find_prev },
        { modes = "i", lhs = keys.insert_paste,    rhs = M.action.insert_paste },
    }

    for _, motion in ipairs({ "h", "j", "k", "l", "w", "b", "e", "0", "^", "$" }) do
        maps[#maps + 1] = { modes = "n", lhs = motion, rhs = M.action["move_" .. motion] }
    end
    for _, motion in ipairs({ "f", "F" }) do
        maps[#maps + 1] = { modes = "n", lhs = motion, rhs = M.action["find_char_" .. motion] }
    end

    local enabled = {}
    for _, map in ipairs(maps) do
        if save_map(map.modes, map.lhs) then
            map.opts = { buf = 0, nowait = true }
            enabled[#enabled + 1] = map
        end
    end
    core.set_keymaps(enabled)
end

local function clear_multi_cursor_keymaps()
    for _, entry in pairs(M.saved_maps) do
        pcall(vim.keymap.del, entry.mode, entry.lhs, { buffer = 0 })
        if entry.saved then
            pcall(vim.fn.mapset, entry.mode, false, entry.saved)
        end
    end
    M.saved_maps = {}
end

local function emit_event(pattern, buf)
    vim.api.nvim_exec_autocmds("User", {
        pattern = pattern,
        modeline = false,
        data = { buf = buf },
    })
end

local function same_pos(a, b)
    return a.row == b.row and a.col == b.col
end

local function normalized(a, b)
    if compare_pos(a, b) <= 0 then
        return a, b
    end
    return b, a
end

local function set_mark(buf, id, pos, gravity)
    return vim.api.nvim_buf_set_extmark(buf, track_ns, pos.row, pos.col, {
        id = id,
        right_gravity = gravity,
        undo_restore = false,
        invalidate = false,
    })
end

function M.enter()
    local buf = vim.api.nvim_get_current_buf()
    if M.augroup then
        return M
    end

    M.regions = {}
    M.active = 0
    M.pattern = nil
    M.register = nil
    M.mode = "normal"
    M.syncing = false
    M.expansion_stack = {}
    M.extend_origins = {}
    M.last_find = nil
    M.augroup = nil
    M.saved_maps = {}

    M._install_autocmds()
    set_multi_cursor_keymaps()
    emit_event("MultiCursorEnter", buf)
    return M
end

function M._install_autocmds()
    M.augroup = vim.api.nvim_create_augroup("MultiCursor", { clear = true })
    vim.api.nvim_create_autocmd({ "BufLeave", "BufWipeout" }, {
        group = M.augroup,
        buffer = 0,
        callback = function()
            if M.augroup then
                M.clear()
            end
        end,
    })
    vim.api.nvim_create_autocmd("InsertLeave", {
        group = M.augroup,
        buffer = 0,
        callback = function()
            vim.schedule(function()
                if M.augroup then
                    insert_stop()
                end
            end)
        end,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = M.augroup,
        buffer = 0,
        callback = function()
            if M.augroup and M._activate_region_at_cursor() then
                M.render()
            end
        end,
    })
end

function M._mark_pos(id)
    local mark = vim.api.nvim_buf_get_extmark_by_id(0, track_ns, id, {})
    if #mark == 0 then
        return nil
    end
    return { row = mark[1], col = mark[2] }
end

function M.raw_positions(region)
    local anchor = M._mark_pos(region.start_id)
    local head = M._mark_pos(region.end_id)
    if not anchor or not head then
        return nil
    end
    return anchor, head
end

function M.positions(region)
    local anchor, head = M.raw_positions(region)
    if not anchor then
        return nil
    end
    if M.mode ~= "extend" then
        return normalized(anchor, head)
    end

    local start_pos, last_pos = normalized(anchor, head)
    local line = vim.api.nvim_buf_get_lines(0, last_pos.row, last_pos.row + 1, true)[1] or ""
    return start_pos, {
        row = last_pos.row,
        col = char_end(line, last_pos.col),
    }
end

function M._set_positions(region, anchor, head, insert_gravity)
    anchor = clamp_position(0, anchor.row, anchor.col)
    head = clamp_position(0, head.row, head.col)
    region.start_id = set_mark(0, region.start_id, anchor, insert_gravity or false)
    region.end_id = set_mark(0, region.end_id, head, insert_gravity or true)
end

function M._find_region(start_pos, end_pos)
    for index, region in ipairs(M.regions) do
        local a, b = M.positions(region)
        if a and same_pos(a, start_pos) and same_pos(b, end_pos) then
            return index
        end
    end
end

local function mark_snapshot()
    local marks = {}
    for _, m in ipairs(vim.api.nvim_buf_get_extmarks(0, track_ns, 0, -1, {})) do
        marks[m[1]] = { row = m[2], col = m[3] }
    end
    return marks
end

local function region_start(region, marks)
    local a, b = marks[region.start_id], marks[region.end_id]
    if not a or not b then
        return { row = 0, col = 0 }
    end
    return compare_pos(a, b) <= 0 and a or b
end

function M.add_region(start_pos, end_pos)
    end_pos = end_pos or start_pos
    local existing = M._find_region(start_pos, end_pos)
    if existing then
        M.active = existing
        M.render()
        M.focus()
        return false
    end

    next_region_id = next_region_id + 1
    local region = { id = next_region_id }
    region.start_id = set_mark(0, nil, start_pos, false)
    region.end_id = set_mark(0, nil, end_pos, true)

    local marks = mark_snapshot()
    local lo, hi = 1, #M.regions
    while lo <= hi do
        local mid = math.floor((lo + hi) / 2)
        if compare_pos(region_start(M.regions[mid], marks), start_pos) < 0 then
            lo = mid + 1
        else
            hi = mid - 1
        end
    end
    table.insert(M.regions, lo, region)
    M.active = lo
    M.render()
    M.focus()
    return true
end

function M.add_selection(start_pos, finish_pos, origin)
    local head = previous_position(0, finish_pos)
    local entering = M.mode ~= "extend"
    if entering then
        M.extend_origins = {}
        for _, region in ipairs(M.regions) do
            local _, current = M.raw_positions(region)
            if current then
                M.extend_origins[region.id] = current
            end
        end
    end
    M.mode = "extend"
    local existing = M._find_region(start_pos, finish_pos)
    if existing then
        M.active = existing
        M.render()
        M.focus()
        return false
    end
    local added = M.add_region(start_pos, head)
    if entering and origin then
        local region = M.regions[M.active]
        if region then
            M.extend_origins[region.id] = origin
        end
    end
    return added
end

function M.sort_regions(active_id)
    active_id = active_id or (M.regions[M.active] and M.regions[M.active].id)
    local marks = mark_snapshot()
    table.sort(M.regions, function(left, right)
        return compare_pos(region_start(left, marks), region_start(right, marks)) < 0
    end)
    if active_id then
        for index, region in ipairs(M.regions) do
            if region.id == active_id then
                M.active = index
                break
            end
        end
    end
end

function M.render()
    vim.api.nvim_buf_clear_namespace(0, decor_ns, 0, -1)
    local marks = mark_snapshot()
    local extend = M.mode == "extend"
    for index, region in ipairs(M.regions) do
        local start_pos, end_pos = marks[region.start_id], marks[region.end_id]
        if start_pos and end_pos then
            if compare_pos(start_pos, end_pos) > 0 then
                start_pos, end_pos = end_pos, start_pos
            end
            if extend then
                local line = vim.api.nvim_buf_get_lines(0, end_pos.row, end_pos.row + 1, true)[1] or ""
                end_pos = { row = end_pos.row, col = char_end(line, end_pos.col) }
            end
            local active = index == M.active
            local cursor_hl = M.mode == "insert"
                and (active and 'MultiCursorInsertActive' or 'MultiCursorInsert')
                or (active and 'MultiCursorActive' or 'MultiCursorCursor')
            if not extend then
                local line = vim.api.nvim_buf_get_lines(0, start_pos.row, start_pos.row + 1, true)[1] or ""
                local opts = {
                    hl_group = cursor_hl,
                    priority = active and 210 or 200,
                    right_gravity = true,
                }
                if start_pos.col < #line then
                    opts.end_row = start_pos.row
                    opts.end_col = char_end(line, start_pos.col)
                    opts.end_right_gravity = true
                else
                    opts.virt_text = { { " ", cursor_hl } }
                    opts.virt_text_pos = "overlay"
                end
                vim.api.nvim_buf_set_extmark(0, decor_ns, start_pos.row, start_pos.col, opts)
            elseif same_pos(start_pos, end_pos) then
                vim.api.nvim_buf_set_extmark(0, decor_ns, start_pos.row, start_pos.col, {
                    virt_text = { { " ", active and 'MultiCursorSelectionActive' or 'MultiCursorSelection' } },
                    virt_text_pos = "overlay",
                    priority = active and 210 or 200,
                })
            else
                vim.api.nvim_buf_set_extmark(0, decor_ns, start_pos.row, start_pos.col, {
                    end_row = end_pos.row,
                    end_col = end_pos.col,
                    hl_group = active and 'MultiCursorSelectionActive' or 'MultiCursorSelection',
                    hl_eol = end_pos.row > start_pos.row,
                    priority = active and 210 or 200,
                })
            end
        end
    end
end

function M.focus()
    local region = M.regions[M.active]
    local head = region and M._mark_pos(region.end_id)
    if head then
        local cursor = head
        if M.mode == "extend" and head.col > 0 then
            local line = vim.api.nvim_buf_get_lines(0, head.row, head.row + 1, true)[1] or ""
            local char = line:sub(head.col + 1, char_end(line, head.col))
            if char == ")" or char == "]" or char == "}" then
                cursor = previous_position(0, head)
            end
        end
        pcall(vim.api.nvim_win_set_cursor, 0, { cursor.row + 1, cursor.col })
    end
end

function M.select_word()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local word = word_at(0, cursor[1] - 1, cursor[2])
    if not word then
        return false
    end
    M.pattern = word.text
    return M.add_selection(word.start, word.finish, { row = cursor[1] - 1, col = cursor[2] })
end

function M._pattern_from_selection()
    if M.mode ~= "extend" then
        return false
    end
    local region = M.regions[M.active]
    if not region then
        return false
    end
    local start_pos, end_pos = M.positions(region)
    if not start_pos then
        return false
    end
    local text = get_text(0, start_pos, end_pos)
    if text == "" or text:find("\n", 1, true) then
        return false
    end
    M.pattern = text
    return true
end

function M._replace_selections(matches)
    if #matches == 0 then
        return
    end

    vim.api.nvim_buf_clear_namespace(0, track_ns, 0, -1)
    M.regions = {}
    M.mode = "extend"
    for _, match in ipairs(matches) do
        next_region_id = next_region_id + 1
        local head = previous_position(0, match.finish)
        M.regions[#M.regions + 1] = {
            id = next_region_id,
            start_id = set_mark(0, nil, match.start, false),
            end_id = set_mark(0, nil, head, true),
        }
    end
    M.active = #M.regions
    M.render()
    M.focus()
end

M.action.select_all = function()
    if not M._pattern_from_selection() and not M.pattern then
        if not M.select_word() then
            return
        end
    end

    local matches = {}

    local pattern = vim.regex([[\C\V]] .. M.pattern:gsub([[\]], [[\\]]))
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
    for row, line in ipairs(lines) do
        local offset = 0
        while offset <= #line do
            local start_col, end_col = pattern:match_str(line:sub(offset + 1))
            if not start_col then
                break
            end
            start_col, end_col = start_col + offset, end_col + offset
            matches[#matches + 1] = {
                start = { row = row - 1, col = start_col },
                finish = { row = row - 1, col = end_col },
            }
            offset = math.max(end_col, offset + 1)
        end
    end
    M._replace_selections(matches)
end

local function add_cursor(direction)
    local cursor = vim.api.nvim_win_get_cursor(0)
    if #M.regions == 0 then
        M.add_region({ row = cursor[1] - 1, col = cursor[2] })
    end
    local region = M.regions[M.active]
    local pos = region and M._mark_pos(region.start_id)
    if not pos then
        return
    end
    local target_row = pos.row + direction
    if target_row < 0 or target_row >= vim.api.nvim_buf_line_count(0) then
        return
    end
    local vcol = virtcol_pos(pos.row + 1, pos.col + 1)
    local target_col = vim.fn.virtcol2col(0, target_row + 1, vcol)
    target_col = math.max(0, target_col - 1)
    M.add_region({ row = target_row, col = target_col })
end

M.action.add_cursor_down = function()
    add_cursor(1)
end

M.action.add_cursor_up = function()
    add_cursor(-1)
end

function M.enter_extend()
    if M.mode ~= "normal" then
        return
    end
    M.expansion_stack = {}
    M.extend_origins = {}
    for _, region in ipairs(M.regions) do
        local _, head = M.raw_positions(region)
        if head then
            M.extend_origins[region.id] = head
        end
    end
    M.mode = "extend"
    M.sort_regions()
    M.render()
    M.focus()
end

function M.exit_extend()
    if M.mode ~= "extend" then
        return
    end
    M.expansion_stack = {}
    for _, region in ipairs(M.regions) do
        local _, head = M.raw_positions(region)
        local origin = M.extend_origins[region.id] or head
        if origin then
            M._set_positions(region, origin, origin)
        end
    end
    M.extend_origins = {}
    M.mode = "normal"
    M.sort_regions()
    M.render()
    M.focus()
end

M.action.escape = function()
    if M.mode == "extend" then
        M.exit_extend()
    else
        M.clear()
    end
end

M.action.expand_selection = function()
    if M.mode == "normal" then
        M.enter_extend()
        return
    end
    if M.mode ~= "extend" then
        return
    end

    local snapshot, changes = {}, {}
    for _, region in ipairs(M.regions) do
        local anchor, head = M.raw_positions(region)
        local start_pos, finish_pos = M.positions(region)
        if anchor and head and start_pos and finish_pos then
            snapshot[#snapshot + 1] = { id = region.id, anchor = anchor, head = head }
            local candidate
            if start_pos.row == finish_pos.row then
                local line = vim.api.nvim_buf_get_lines(0, start_pos.row, start_pos.row + 1, true)[1] or ""
                local candidates = {}
                local function add(start_col, finish_col)
                    local contains = start_col <= start_pos.col and finish_col >= finish_pos.col
                    local larger = start_col < start_pos.col or finish_col > finish_pos.col
                    if contains and larger then
                        candidates[#candidates + 1] = { start = start_col, finish = finish_col }
                    end
                end

                local word = word_at(0, start_pos.row, math.min(start_pos.col, math.max(0, #line - 1)))
                if word then
                    add(word.start.col, word.finish.col)
                end
                add(0, #line)
                table.sort(candidates, function(left, right)
                    return left.finish - left.start < right.finish - right.start
                end)
                if candidates[1] then
                    candidate = {
                        start = { row = start_pos.row, col = candidates[1].start },
                        finish = { row = start_pos.row, col = candidates[1].finish },
                    }
                end
            else
                local last_line = vim.api.nvim_buf_get_lines(0, finish_pos.row, finish_pos.row + 1, true)[1] or ""
                candidate = {
                    start = { row = start_pos.row, col = 0 },
                    finish = { row = finish_pos.row, col = #last_line },
                }
            end

            if candidate then
                changes[#changes + 1] = { region = region, start = candidate.start, finish = candidate.finish }
            end
        end
    end

    if #changes == 0 then
        return
    end
    M.expansion_stack[#M.expansion_stack + 1] = snapshot
    local active_id = M.regions[M.active] and M.regions[M.active].id
    for _, change in ipairs(changes) do
        local head = change.finish.col > 0 and previous_position(0, change.finish) or change.start
        M._set_positions(change.region, change.start, head)
    end
    M.sort_regions(active_id)
    M.render()
    M.focus()
end

M.action.shrink_selection = function()
    if M.mode ~= "extend" then
        return
    end
    local snapshot = table.remove(M.expansion_stack)
    if not snapshot or #snapshot ~= #M.regions then
        M.expansion_stack = {}
        return
    end

    local by_id = {}
    for _, saved in ipairs(snapshot) do
        by_id[saved.id] = saved
    end
    local active_id = M.regions[M.active] and M.regions[M.active].id
    for _, region in ipairs(M.regions) do
        local saved = by_id[region.id]
        if not saved then
            M.expansion_stack = {}
            return
        end
        M._set_positions(region, saved.anchor, saved.head)
    end
    M.sort_regions(active_id)
    M.render()
    M.focus()
end

M.action.next_region = function()
    if #M.regions == 0 then
        return
    end
    M.active = (M.active % #M.regions) + 1
    M.render()
    M.focus()
end

M.action.previous_region = function()
    if #M.regions == 0 then
        return
    end
    M.active = ((M.active - 2) % #M.regions) + 1
    M.render()
    M.focus()
end

function M._region_index_at_cursor()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local pos = { row = cursor[1] - 1, col = cursor[2] }
    local low, high, candidate = 1, #M.regions, nil
    while low <= high do
        local mid = math.floor((low + high) / 2)
        local start_pos = M.positions(M.regions[mid])
        if start_pos and compare_pos(start_pos, pos) <= 0 then
            candidate = mid
            low = mid + 1
        else
            high = mid - 1
        end
    end
    if candidate then
        local start_pos, end_pos = M.positions(M.regions[candidate])
        local after_start = compare_pos(pos, start_pos) >= 0
        local before_end = compare_pos(pos, end_pos) < 0
        if (same_pos(start_pos, end_pos) and same_pos(pos, start_pos))
            or (after_start and before_end)
        then
            return candidate
        end
    end
end

function M._activate_region_at_cursor()
    local index = M._region_index_at_cursor()
    if not index then
        return false
    end
    local changed = M.active ~= index
    M.active = index
    return changed
end

M.action.remove_region = function()
    M._activate_region_at_cursor()
    local region = M.regions[M.active]
    if not region then
        return
    end
    vim.api.nvim_buf_del_extmark(0, track_ns, region.start_id)
    vim.api.nvim_buf_del_extmark(0, track_ns, region.end_id)
    table.remove(M.regions, M.active)
    if #M.regions == 0 then
        M.clear()
        return
    end
    M.active = math.min(M.active, #M.regions)
    M.render()
    M.focus()
end

function M._edits_for_regions(kind, values)
    local edits = {}
    for index, region in ipairs(M.regions) do
        local start_pos, end_pos = M.positions(region)
        if start_pos then
            if same_pos(start_pos, end_pos) and kind ~= "insert" then
                local line = vim.api.nvim_buf_get_lines(0, start_pos.row, start_pos.row + 1, true)[1] or ""
                end_pos = { row = start_pos.row, col = char_end(line, start_pos.col) }
            end
            edits[#edits + 1] = {
                region = region,
                start = start_pos,
                finish = end_pos,
                text = values and (values[index] or values[1]) or "",
            }
        end
    end
    table.sort(edits, function(a, b)
        return compare_pos(a.start, b.start) > 0
    end)
    return edits
end

function M._deduplicate_regions()
    local active_region = M.regions[M.active]
    local rows, regions, active = {}, {}, 1
    for _, region in ipairs(M.regions) do
        local pos = M._mark_pos(region.end_id)
        if pos then
            local seen = rows[pos.row]
            if not seen then
                seen = {}
                rows[pos.row] = seen
            end
            local index = seen[pos.col]
            if not index then
                regions[#regions + 1] = region
                index = #regions
                seen[pos.col] = index
            else
                vim.api.nvim_buf_del_extmark(0, track_ns, region.start_id)
                vim.api.nvim_buf_del_extmark(0, track_ns, region.end_id)
            end
            if region == active_region then
                active = index
            end
        end
    end
    M.regions = regions
    M.active = math.min(active, #regions)
end

function M._apply_edits(edits, deduplicate)
    for index, edit in ipairs(edits) do
        if index > 1 then
            pcall(vim.cmd.undojoin)
        end
        local start_pos = clamp_position(0, edit.start.row, edit.start.col)
        local finish_pos = clamp_position(0, edit.finish.row, edit.finish.col)
        vim.api.nvim_buf_set_text(
            0,
            start_pos.row,
            start_pos.col,
            finish_pos.row,
            finish_pos.col,
            split_text(edit.text)
        )
    end

    M.mode = "normal"
    M.extend_origins = {}
    for _, edit in ipairs(edits) do
        local start_pos = M._mark_pos(edit.region.start_id) or edit.start
        M._set_positions(edit.region, start_pos, start_pos)
    end
    M.sort_regions()
    if deduplicate then
        M._deduplicate_regions()
    end
    M.render()
    M.focus()
end

M.action.yank = function(keep_extend)
    local values = {}
    for _, region in ipairs(M.regions) do
        local start_pos, end_pos = M.positions(region)
        if start_pos and end_pos then
            if same_pos(start_pos, end_pos) then
                local line = vim.api.nvim_buf_get_lines(0, start_pos.row, start_pos.row + 1, true)[1] or ""
                end_pos = { row = start_pos.row, col = char_end(line, start_pos.col) }
            end
            values[#values + 1] = get_text(0, start_pos, end_pos)
        end
    end
    M.register = values
    if values[1] then
        vim.fn.setreg('"', values[1], "v")
    end

    if M.mode == "extend" and not keep_extend then
        for _, region in ipairs(M.regions) do
            local _, head = M.raw_positions(region)
            M._set_positions(region, head, head)
        end
        M.mode = "normal"
        M.extend_origins = {}
        M.sort_regions()
        M.render()
        M.focus()
    end
end

M.action.change = function()
    M.action.delete()
    M.action.insert()
end

local MOTION_NEEDS_NEXT = { f = true, F = true, t = true, T = true, g = true, i = true, a = true }
local DIGIT = "[0-9]"
local function read_motion()
    local seq = ""
    local c = vim.fn.getcharstr()
    if c == "" or c == vim.keycode("<Esc>") or c == vim.keycode("<C-c>") then
        return nil
    end
    while c:match(DIGIT) do
        seq = seq .. c
        c = vim.fn.getcharstr()
        if c == "" or c == vim.keycode("<Esc>") or c == vim.keycode("<C-c>") then
            return nil
        end
    end
    seq = seq .. c
    if MOTION_NEEDS_NEXT[c] then
        local c2 = vim.fn.getcharstr()
        if c2 == "" or c2 == vim.keycode("<Esc>") or c2 == vim.keycode("<C-c>") then
            return nil
        end
        seq = seq .. c2
    end
    return seq
end

local function operator_delete(seq)
    local items = {}
    for _, region in ipairs(M.regions) do
        local pos = M._mark_pos(region.end_id)
        if pos then
            items[#items + 1] = { region = region, pos = pos }
        end
    end
    table.sort(items, function(a, b)
        return compare_pos(a.pos, b.pos) > 0
    end)
    for index, item in ipairs(items) do
        if index > 1 then
            pcall(vim.cmd.undojoin)
        end
        pcall(vim.api.nvim_win_set_cursor, 0, { item.pos.row + 1, item.pos.col })
        vim.cmd.normal({ args = { "d" .. seq }, bang = true })
        local cursor = vim.api.nvim_win_get_cursor(0)
        local moved = { row = cursor[1] - 1, col = cursor[2] }
        M._set_positions(item.region, moved, moved)
    end
    M.mode = "normal"
    M.extend_origins = {}
    M.sort_regions()
    M.render()
    M.focus()
end

M.action.delete_char = function()
    M.action.yank(true)
    M._apply_edits(M._edits_for_regions("delete"))
end

M.action.delete = function()
    if M.mode == "extend" then
        M.action.delete_char()
        return
    end
    local seq = read_motion()
    if seq then
        operator_delete(seq)
    else
        M.focus()
    end
end

M.action.delete_to_eol = function()
    local edits, values = {}, {}
    for index, region in ipairs(M.regions) do
        local _, head = M.raw_positions(region)
        if head then
            local line = vim.api.nvim_buf_get_lines(0, head.row, head.row + 1, true)[1] or ""
            local finish_pos = { row = head.row, col = #line }
            values[index] = get_text(0, head, finish_pos)
            edits[#edits + 1] = {
                region = region,
                start = head,
                finish = finish_pos,
                text = "",
            }
        end
    end
    table.sort(edits, function(left, right)
        return compare_pos(left.start, right.start) > 0
    end)
    M.register = values
    if values[1] then
        vim.fn.setreg('"', values[1], "v")
    end
    M._apply_edits(edits, true)
    M.action.insert()
end

M.action.paste = function()
    local values = M.register
    if not values or #values == 0 then
        values = { vim.fn.getreg('"') }
    end
    if M.mode == "extend" then
        M._apply_edits(M._edits_for_regions("replace", values), true)
        return
    end

    local saved = vim.fn.getreginfo("z")
    for index, region in ipairs(M.regions) do
        local _, pos = M.raw_positions(region)
        if pos then
            if index > 1 then
                pcall(vim.cmd.undojoin)
            end
            vim.fn.setreg("z", values[index] or values[1] or "", "v")
            pcall(vim.api.nvim_win_set_cursor, 0, { pos.row + 1, pos.col })
            vim.cmd.normal({ args = { [["zp]] }, bang = true })
            local cursor = vim.api.nvim_win_get_cursor(0)
            local pasted = { row = cursor[1] - 1, col = cursor[2] }
            region.vcol = nil
            M._set_positions(region, pasted, pasted)
        end
    end
    vim.fn.setreg("z", saved.regcontents, saved.regtype)
    M.sort_regions()
    M._deduplicate_regions()
    M.render()
    M.focus()
end

function M.sync_after_history()
    if M.mode == "normal" then
        local active_id = M.regions[M.active] and M.regions[M.active].id
        for _, region in ipairs(M.regions) do
            local cursor = M.positions(region)
            if cursor then
                region.vcol = nil
                M._set_positions(region, cursor, cursor)
            end
        end
        M.sort_regions(active_id)
    end
    M.render()
    M.focus()
    vim.schedule(function()
        if M.augroup then
            M.focus()
        end
    end)
end

M.action.find_char = function(motion, count, char)
    count = count or vim.v.count1
    if not char then
        local ok
        ok, char = pcall(vim.fn.getcharstr)
        if not ok then
            M.focus()
            return false
        end
    end
    if char == "" or char == vim.keycode("<Esc>") or char == vim.keycode("<C-c>") then
        M.focus()
        return false
    end
    M.last_find = { motion = motion, char = char }
    M.action.move(motion .. char, count)
    return true
end

local function repeat_find(opposite, count)
    if not M.last_find then
        return false
    end
    local motion = M.last_find.motion
    if opposite then
        motion = motion == "f" and "F" or "f"
    end
    M.action.move(motion .. M.last_find.char, count)
    return true
end

M.action.repeat_find = function()
    repeat_find(false)
end

M.action.repeat_find_prev = function()
    repeat_find(true)
end

M.action.move = function(motion, count)
    M.expansion_stack = {}
    count = count or vim.v.count1
    local active_id = M.regions[M.active] and M.regions[M.active].id
    local vertical = motion == "j" or motion == "k"
    local line_local = motion == "w" or motion == "b" or motion == "e" or motion == "h" or motion == "l"
    local backward = motion == "b" or motion == "h"
    for _, region in ipairs(M.regions) do
        local anchor, head = M.raw_positions(region)
        if head then
            if vertical and not region.vcol then
                region.vcol = virtcol_pos(head.row + 1, head.col + 1)
            elseif not vertical then
                region.vcol = nil
            end
            pcall(vim.api.nvim_win_set_cursor, 0, { head.row + 1, head.col })
            vim.cmd.normal({ args = { tostring(count) .. motion }, bang = true })
            local cursor = vim.api.nvim_win_get_cursor(0)
            local moved = { row = cursor[1] - 1, col = cursor[2] }
            if vertical then
                local target_col = vim.fn.virtcol2col(0, moved.row + 1, region.vcol)
                moved.col = math.max(0, target_col - 1)
            elseif line_local and moved.row ~= head.row then
                local line = vim.api.nvim_buf_get_lines(0, head.row, head.row + 1, true)[1] or ""
                moved = (backward or line == "") and { row = head.row, col = 0 }
                    or previous_position(0, { row = head.row, col = #line })
            end
            if M.mode == "extend" then
                M._set_positions(region, anchor, moved)
            else
                M._set_positions(region, moved, moved)
            end
        end
    end
    M.sort_regions(active_id)
    M.render()
    M.focus()
end

M.action.insert = function()
    insert("i")
end

M.action.append = function()
    insert("a")
end

M.action.insert_bol = function()
    insert("I")
end

M.action.append_eol = function()
    insert("A")
end

M.action.open_below = function()
    insert("o")
end

M.action.open_above = function()
    insert("O")
end

M.action.undo = function()
    vim.cmd.undo()
    M.sync_after_history()
end

M.action.redo = function()
    vim.cmd.redo()
    M.sync_after_history()
end

function M.clear()
    if not M.augroup then
        return
    end
    local buf = vim.api.nvim_get_current_buf()
    M.mode = "normal"
    clear_multi_cursor_keymaps()
    if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_clear_namespace(buf, track_ns, 0, -1)
        vim.api.nvim_buf_clear_namespace(buf, decor_ns, 0, -1)
    end
    if M.augroup then
        pcall(vim.api.nvim_del_augroup_by_id, M.augroup)
        M.augroup = nil
    end
    emit_event("MultiCursorLeave", buf)
end

local function visual_selection()
    if vim.fn.mode() ~= "v" then
        vim.notify("multi-cursor: only characterwise Visual selections are supported", vim.log.levels.WARN)
        return
    end
    local region = vim.fn.getregionpos(vim.fn.getpos("v"), vim.fn.getpos("."), {
        type = "v",
        exclusive = vim.o.selection == "exclusive",
        eol = true,
    })
    if #region ~= 1 then
        vim.notify("multi-cursor: multiline Visual selections are not supported", vim.log.levels.WARN)
        return
    end
    local first, last = region[1][1], region[1][2]
    local start_pos = { row = first[2] - 1, col = math.max(0, first[3] - 1) }
    local last_pos = { row = last[2] - 1, col = math.max(0, last[3] - 1) }
    local line = vim.api.nvim_buf_get_lines(0, last_pos.row, last_pos.row + 1, true)[1] or ""
    local finish_pos = { row = last_pos.row, col = char_end(line, last_pos.col) }
    return start_pos, finish_pos
end

local function from_visual(next)
    local start_pos, finish_pos = visual_selection()
    if not start_pos then
        return
    end
    local text = get_text(0, start_pos, finish_pos)
    if text == "" or text:find("\n", 1, true) then
        return
    end
    vim.cmd.normal({ args = { vim.keycode("<Esc>") }, bang = true })
    local s = M.enter()
    s.pattern = text
    s:add_selection(start_pos, finish_pos)
    if next then
        M.action.find_next()
    else
        M.action.select_all()
    end
end

function M.from_visual_find_next()
    from_visual(true)
end

function M.from_visual_select_all()
    from_visual(false)
end

return M
