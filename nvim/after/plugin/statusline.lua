-- simple statusline implementation (depends gitsigns.nvim)
core.hl {
    ['SLModeNormal']   = { fg = '#98c379' },
    ['SLModeInsert']   = { fg = '#61afef' },
    ['SLModeVisual']   = { fg = '#c678dd' },
    ['SLModeReplace']  = { fg = '#e06c75' },
    ['SLModeCommand']  = { fg = '#e5c07b' },
    ['SLModeTerminal'] = { fg = '#56b6c2' },
}

local modes = {
    ['n']     = { text = 'NORMAL',    hl = 'SLModeNormal' },
    ['niI']   = { text = 'NORMAL',    hl = 'SLModeNormal' },
    ['niR']   = { text = 'NORMAL',    hl = 'SLModeNormal' },
    ['niV']   = { text = 'NORMAL',    hl = 'SLModeNormal' },
    ['nt']    = { text = 'NORMAL',    hl = 'SLModeNormal' },
    ['ntT']   = { text = 'NORMAL',    hl = 'SLModeNormal' },
    ['no']    = { text = 'O-PENDING', hl = 'SLModeNormal' },
    ['nov']   = { text = 'O-PENDING', hl = 'SLModeNormal' },
    ['noV']   = { text = 'O-PENDING', hl = 'SLModeNormal' },
    ['no\22'] = { text = 'O-PENDING', hl = 'SLModeNormal' },
    ['v']     = { text = 'VISUAL',    hl = 'SLModeVisual' },
    ['vs']    = { text = 'VISUAL',    hl = 'SLModeVisual' },
    ['V']     = { text = 'V-LINE',    hl = 'SLModeVisual' },
    ['Vs']    = { text = 'V-LINE',    hl = 'SLModeVisual' },
    ['\22']   = { text = 'V-BLOCK',   hl = 'SLModeVisual' },
    ['\22s']  = { text = 'V-BLOCK',   hl = 'SLModeVisual' },
    ['s']     = { text = 'SELECT',    hl = 'SLModeVisual' },
    ['S']     = { text = 'S-LINE',    hl = 'SLModeVisual' },
    ['\19']   = { text = 'S-BLOCK',   hl = 'SLModeVisual' },
    ['i']     = { text = 'INSERT',    hl = 'SLModeInsert' },
    ['ic']    = { text = 'INSERT',    hl = 'SLModeInsert' },
    ['ix']    = { text = 'INSERT',    hl = 'SLModeInsert' },
    ['R']     = { text = 'REPLACE',   hl = 'SLModeReplace' },
    ['Rc']    = { text = 'REPLACE',   hl = 'SLModeReplace' },
    ['Rx']    = { text = 'REPLACE',   hl = 'SLModeReplace' },
    ['Rv']    = { text = 'V-REPLACE', hl = 'SLModeReplace' },
    ['Rvc']   = { text = 'V-REPLACE', hl = 'SLModeReplace' },
    ['Rvx']   = { text = 'V-REPLACE', hl = 'SLModeReplace' },
    ['c']     = { text = 'COMMAND',   hl = 'SLModeCommand' },
    ['cr']    = { text = 'C-REPLACE', hl = 'SLModeCommand' },
    ['cv']    = { text = 'EX',        hl = 'SLModeCommand' },
    ['ce']    = { text = 'EX',        hl = 'SLModeCommand' },
    ['r']     = { text = 'PROMPT',    hl = 'SLModeCommand' },
    ['rm']    = { text = 'MORE',      hl = 'SLModeCommand' },
    ['r?']    = { text = 'CONFIRM',   hl = 'SLModeCommand' },
    ['!']     = { text = 'SHELL',     hl = 'SLModeTerminal' },
    ['t']     = { text = 'TERMINAL',  hl = 'SLModeTerminal' },
}

local function hl_text_format(text, hl)
    if type(text) ~= 'string' or text == '' then return '' end

    text = text:gsub('%%', '%%%%')

    if type(hl) ~= 'string' or hl == '' then return text end

    return string.format('%%#%s#%s%%*', hl, text)
end

--- statusline components
local components = {
    mode = {
        text = '',
        update = function(self)
            local mode = vim.api.nvim_get_mode().mode
            local m = modes[mode]
            self.text = m and hl_text_format(m.text, m.hl) or mode
        end
    },

    --- gitsigns.nvim
    branch = {
        text = '',
        update = function(self)
            self.text = hl_text_format(vim.b.gitsigns_head)
        end
    },

    --- gitsigns.nvim
    diff = {
        text = '',
        update = function(self)
            local diff = vim.b.gitsigns_status_dict
            if type(diff) ~= 'table' then return end

            local parts = {}

            if (diff.added or 0) > 0 then
                table.insert(parts, hl_text_format('+' .. diff.added, 'Added'))
            end
            if (diff.changed or 0) > 0 then
                table.insert(parts, hl_text_format('~' .. diff.changed, 'Changed'))
            end
            if (diff.removed or 0) > 0 then
                table.insert(parts, hl_text_format('-' .. diff.removed, 'Removed'))
            end

            self.text = table.concat(parts, ' ')
        end
    },

    diagnostics = {
        text = '',
        update = function(self)
            local diagnostic = vim.diagnostic.count(0)
            local parts = {}

            for severity, hl in ipairs { 'DiagnosticError', 'DiagnosticWarn', 'DiagnosticInfo', 'DiagnosticHint' } do
                local count = diagnostic[severity] or 0
                if count > 0 then
                    table.insert(parts, hl_text_format('󱓻 ' .. count, hl))
                end
            end

            self.text = table.concat(parts, ' ')
        end,
    },

    filename = {
        text = '',
        update = function(self)
            local name = vim.fn.expand('%:~:.')
            if name == '' then name = '[No Name]' end

            local max_length = 40
            local length = vim.fn.strdisplaywidth(name)
            if length > max_length then
                name = name:gsub('([^/\\]+)([/\\])', function(dir, sep)
                    if length <= max_length or dir:match('^%a:$') then return dir .. sep end

                    local short = vim.fn.strcharpart(dir, 0, dir:sub(1, 1) == '.' and 2 or 1)
                    length = length - vim.fn.strdisplaywidth(dir) + vim.fn.strdisplaywidth(short)
                    return short .. sep
                end)
            end

            if vim.bo.modified then name = name .. ' [+]' end
            if vim.bo.readonly or not vim.bo.modifiable then name = name .. ' [-]' end

            self.text = '%<' .. hl_text_format(name)
        end,
    },

    filesize = {
        text = '',
        update = function(self)
            if vim.bo.buftype ~= '' then return end

            local file = vim.fn.expand('%:p')
            if file == nil or #file == 0 then return end

            local size = vim.fn.getfsize(file) / 1024
            if size <= 0 then return end

            local units = { 'K', 'M', 'G', 'T' }

            local unit = 1
            while size >= 1024 and unit < #units do
                size = size / 1024
                unit = unit + 1
            end

            self.text = hl_text_format(string.format('%.1f%s', size, units[unit]))
        end,
    },

    filetype = {
        text = '',
        update = function(self)
            self.text = hl_text_format(vim.bo.filetype)
        end
    },

    encoding = {
        text = '',
        update = function(self)
            self.text = hl_text_format(vim.bo.fileencoding)
        end,
    },

    fileformat = {
        text = '',
        update = function(self)
            self.text = hl_text_format(vim.bo.fileformat)
        end
    },

    location = {
        text = '',
        rpadding = false,
        update = function(self)
            self.text = hl_text_format(string.format('%3d:%-3d', vim.fn.line('.'), vim.fn.charcol('.')))
        end
    },

    progress = {
        text = '',
        lpadding = false,
        update = function(self)
            local current, total = vim.fn.line('.'), vim.fn.line('$')
            self.text = hl_text_format(string.format('%3d%%', math.floor(current / total * 100)))
        end
    },

    searchcount = {
        text = '',
        update = function(self)
            if vim.v.hlsearch == 0 then return end

            local ok, result = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 20 })
            if not ok or not result.total then return end

            local denominator = math.min(result.total, result.maxcount)

            if denominator > 0 then
                self.text = hl_text_format(string.format('[%d/%d]', result.current, denominator), 'Search')
            end
        end
    },

    selectioncount = {
        text = '',
        update = function(self)
            local mode = vim.fn.mode(true)
            local srow, scol = vim.fn.line('v'), vim.fn.col('v')
            local erow, ecol = vim.fn.line('.'), vim.fn.col('.')

            local text = ''

            if mode:match('') then
                text = string.format('%dx%d', math.abs(srow - erow) + 1, math.abs(scol - ecol) + 1)
            elseif mode:match('V') or srow ~= erow then
                text = tostring(math.abs(srow - erow) + 1)
            elseif mode:match('v') then
                text = tostring(math.abs(scol - ecol) + 1)
            end

            if text ~= '' then
                self.text = hl_text_format(text, 'SLModeVisual')
            end
        end
    }
}

---@param component string[]? Components to update. nil update all components.
function components.update(component)
    for _, name in ipairs(component or vim.tbl_keys(components)) do
        if type(components[name]) == 'table' and type(components[name].update) == 'function' then
            components[name].text = ''
            components[name]:update()
        end
    end
end

---@param cs string[] Components to concatenate, in display order.
---@return string
function components.compile(cs)
    local parts = {}
    for _, name in ipairs(cs) do
        local component = components[name]
        if type(component) == 'table' and type(component.text) == 'string' and component.text ~= '' then
            local lpadding = component.lpadding ~= false and ' ' or ''
            local rpadding = component.rpadding ~= false and ' ' or ''
            table.insert(parts, lpadding .. component.text .. rpadding)
        end
    end
    return table.concat(parts)
end

------------------------------------------------------------------------
--- ====> autocommands update statusline components
local group = vim.api.nvim_create_augroup('core.Statusline', { clear = true })

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
    group = group,
    callback = function(ev)
        components.update()
    end
})

vim.api.nvim_create_autocmd('ModeChanged', {
    group = group,
    callback = function(ev)
        components.update { 'mode' }
    end
})

vim.api.nvim_create_autocmd('DiagnosticChanged', {
    group = group,
    callback = vim.schedule_wrap(function(ev)
        if ev.buf ~= vim.api.nvim_get_current_buf() then return end
        components.update { 'diagnostics' }
        vim.cmd.redrawstatus()
    end)
})

vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufFilePost', 'FileChangedShellPost' }, {
    group = group,
    callback = function(ev)
        if ev.buf ~= vim.api.nvim_get_current_buf() then return end

        components.update { 'filename', 'filesize', 'encoding', 'fileformat' }
        vim.cmd.redrawstatus()
    end
})

vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
    group = group,
    callback = function(ev)
        components.update { 'location', 'progress', 'searchcount', 'selectioncount' }
    end
})

vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'GitSignsUpdate',
    callback = function(ev)
        local buffer = ev.data and ev.data.buffer
        if buffer == vim.api.nvim_get_current_buf() then
            components.update { 'branch', 'diff' }
            vim.cmd('redrawstatus')
        end
    end
})

vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'core.SearchChanged',
    callback = function()
        components.update { 'searchcount' }
        vim.cmd.redrawstatus()
    end
})
--- <==== autocommands update statusline components
------------------------------------------------------------------------

components.update()

function core.statusline()
    return components.compile { 'mode', 'branch', 'diff', 'diagnostics', 'filename' }
           .. '%=' ..
           components.compile { 'filesize', 'filetype', 'encoding', 'fileformat', 'location', 'progress', 'searchcount', 'selectioncount', }
end

vim.go.statusline = '%{%v:lua.core.statusline()%}'
