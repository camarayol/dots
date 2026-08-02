core.set_keymaps {
    { modes = 'n', lhs = '<Bslash>\\', rhs = '<Cmd>FzfLua<CR>',             opts = { desc = 'FzfLua' } },
    { modes = 'n', lhs = '<Bslash>r',  rhs = '<Cmd>FzfLua resume<CR>',      opts = { desc = 'FzfLua resume' } },
    { modes = 'n', lhs = '<Bslash>f',  rhs = '<Cmd>FzfLua files<CR>',       opts = { desc = 'FzfLua files' } },
    { modes = 'n', lhs = '<Bslash>b',  rhs = '<Cmd>FzfLua buffers<CR>',     opts = { desc = 'FzfLua buffers' } },
    { modes = 'n', lhs = '<Bslash>g',  rhs = '<Cmd>FzfLua git_diff<CR>',    opts = { desc = 'FzfLua git diff' } },
    { modes = 'n', lhs = '<Bslash>h',  rhs = '<Cmd>FzfLua helptags<CR>',    opts = { desc = 'FzfLua help tags' } },
    { modes = 'n', lhs = '<Bslash>j',  rhs = '<Cmd>FzfLua jumps<CR>',       opts = { desc = 'FzfLua jumps' } },
    { modes = 'n', lhs = '<Bslash>o',  rhs = '<Cmd>FzfLua history<CR>',     opts = { desc = 'FzfLua history file/buffer' } },
    { modes = 'n', lhs = '<Bslash>q',  rhs = '<Cmd>FzfLua quickfix<CR>',    opts = { desc = 'FzfLua quickfix' } },
    { modes = 'n', lhs = '<Bslash>s',  rhs = '<Cmd>FzfLua grep_curbuf<CR>', opts = { desc = 'FzfLua grep current buf' } },
    { modes = 'n', lhs = '<Bslash>S',  rhs = '<Cmd>FzfLua live_grep<CR>',   opts = { desc = 'FzfLua live grep' } },
}

return {
    src = 'https://github.com/ibhagwan/fzf-lua',
    events = { 'CmdUndefined' },
    pattern = { 'FzfLua', 'Pi', 'PiResume' },
    config = function()
        require('fzf-lua').setup {
            fzf_colors = true,
            ui_select = function(opts, items) return { prompt = opts.prompt .. ' ' } end,
            defaults = {
                git_icons  = false,
                file_icons = false,
                formatter  = "path.filename_first",
            },
            winopts = {
                fullscreen = false,
                preview = {
                    default    = 'bat',
                    horizontal = "right:60%",
                    layout     = "horizontal",
                    scrollbar  = false,
                    winopts    = { number = false, cursorline = false },
                }
            },
            previewers = { bat = { args = "--color=always --theme=OneHalfDark --style=changes" } },
        }
    end
}
