local M  = {
    src = 'https://github.com/nvim-lualine/lualine.nvim',
    depends = { 'https://github.com/nvim-tree/nvim-web-devicons' },
    events = { 'VimEnter' },
}

M.config = function()
    require('lualine').setup {
        options = {
            theme = {
                normal = {
                    a = { fg = '#98c379', bg = '#282C34' },
                    b = { fg = '#abb2bf', bg = '#282C34' },
                    c = { fg = '#abb2bf', bg = '#282C34' },
                },
                insert   = { a = { fg = '#61afef', bg = '#282C34' } },
                visual   = { a = { fg = '#c678dd', bg = '#282C34' } },
                command  = { a = { fg = '#e5c07b', bg = '#282C34' } },
                terminal = { a = { fg = '#56b6c2', bg = '#282C34' } },
                replace  = { a = { fg = '#e06c75', bg = '#282C34' } },
            },
            globalstatus = true,
            icons_enabled = false,
            section_separators = '',
            component_separators = '',
            always_divide_middle = false,
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = {
                { 'branch' },
                { 'diff', symbols = { added = '+', modified = '~', removed = '-' } },
                { 'diagnostics', symbols = { error = '󱓻 ', warn = '󱓻 ', info = '󱓻 ', hint = '󱓻 ' } },
                { 'filename', path = 1 },
            },
            lualine_c = {},
            lualine_x = { 'filesize', 'filetype', 'encoding', 'fileformat' },
            lualine_y = { 'location', 'progress' },
            lualine_z = { 'searchcount', 'selectioncount', 'lsp_status' }
        }
    }
end

return M
