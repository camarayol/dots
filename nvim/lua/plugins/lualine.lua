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
                    a = { fg = '#98c379', bg = 'none' },
                    b = { fg = '#abb2bf', bg = 'none' },
                    c = { fg = '#abb2bf', bg = 'none' },
                },
                insert   = { a = { fg = '#61afef', bg = 'none' } },
                visual   = { a = { fg = '#c678dd', bg = 'none' } },
                command  = { a = { fg = '#e5c07b', bg = 'none' } },
                terminal = { a = { fg = '#56b6c2', bg = 'none' } },
                replace  = { a = { fg = '#e06c75', bg = 'none' } },
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
            lualine_z = { 'searchcount', 'selectioncount' }
        }
    }
end

return M
