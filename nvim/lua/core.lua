Core = {}

Core.coreGroup = vim.api.nvim_create_augroup('CoreGroup', { clear = true })

Core.lspConfig = { 'lua_ls', 'rust_analyzer' }

Core.osSysname = function(sysname)
    return vim.uv.os_uname().sysname:match(sysname)
end

Core.setOptions = function(options)
    for type, opts in pairs(options) do
        for k, v in pairs(opts) do
            vim[type][k] = v;
        end
    end
end

Core.setKeyMaps = function(keymaps)
    for _, maps in pairs(keymaps) do
        vim.keymap.set(maps[1], maps[2], maps[3], maps[4] or { noremap = true, silent = true })
    end
end

Core.setKeyMaps2 = function(keymaps)
    for mode, mappings in pairs(keymaps) do
        for k, v in pairs(mappings) do
            if type(v) == 'table' then
                vim.keymap.set(mode, k, v[1], v[2] or { noremap = true, silent = true })
            else
                vim.keymap.set(mode, k, v, { noremap = true, silent = true })
            end
        end
    end
end

Core.setCommentStrings = function(commentstrings)
    for _, opts in pairs(commentstrings) do
        vim.api.nvim_create_autocmd('FileType', {
            pattern = opts.pattern,
            callback = function() vim.bo.commentstring = opts.cs end
        })
    end
end

--- @param event    string|string[]
--- @param pattern  string|string[]
--- @param callback function|string
--- @param opts     nil|vim.api.keyset.create_autocmd
Core.createAutoCommand = function(event, pattern, callback, opts)
    opts = vim.tbl_extend('force', {
        group    = Core.coreGroup,
        pattern  = pattern,
        callback = callback,
    }, opts or {})
    vim.api.nvim_create_autocmd(event, opts)
end

--- @param name string
--- @param command string|fun(args: vim.api.keyset.create_user_command.command_args)
--- @param opts nil|vim.api.keyset.user_command
Core.createUserCommand = function(name, command, opts)
    vim.api.nvim_create_user_command(name, command, opts or {})
end

Core.compile_commands = {
    ['cpp']  = 'make\n',
    ['rust'] = 'cargo build\n',
}
Core.codeCompile = function()
    local command = Core.compile_commands[vim.bo.filetype]
    if command then
        Core.toggleFloatTerminal(function() vim.api.nvim_feedkeys(command, 't', false) end)
    else
        Core.warn('Compile command is empty.')
    end
end

Core.info = function(msg) vim.notify(msg, vim.log.levels.INFO) end
Core.warn = function(msg) vim.notify(msg, vim.log.levels.WARN) end

Core.prependEnvPath = function(path)
    local expanded_path = vim.fn.fnamemodify(vim.fn.expand(path), ':p:h')

    if vim.fn.isdirectory(expanded_path) == 0 then
        return
    end

    local sep = vim.uv.os_uname().sysname:match('Windows') and ';' or ':'

    local current_path = vim.env.PATH
    local pattern = '(^|' .. sep .. ')' .. vim.pesc(expanded_path) .. '($|' .. sep .. ')'
    if string.find(current_path, pattern) then
        return
    end

    vim.env.PATH = expanded_path .. sep .. current_path
end

return Core
