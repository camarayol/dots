local M = {
    src = 'https://github.com/nvim-lualine/lualine.nvim',
    depends = { 'https://github.com/nvim-tree/nvim-web-devicons' },
}

M.config = function()
    require('lualine').setup {
        options = {
            theme                = {
                normal   = {
                    a = { fg = '#98c379', bg = '#2c323c' },
                    b = { fg = '#abb2bf', bg = '#2c323c' },
                    c = { fg = '#abb2bf', bg = '#2c323c' },
                },
                insert   = { a = { fg = '#61afef', bg = '#2c323c' } },
                visual   = { a = { fg = '#c678dd', bg = '#2c323c' } },
                command  = { a = { fg = '#e5c07b', bg = '#2c323c' } },
                terminal = { a = { fg = '#56b6c2', bg = '#2c323c' } },
                replace  = { a = { fg = '#e06c75', bg = '#2c323c' } },
            },
            globalstatus         = true,
            icons_enabled        = false,
            section_separators   = '',
            component_separators = '',
            always_divide_middle = false,
        },
        sections = {
            lualine_a = { 'mode' },
            lualine_b = {
                { 'branch' },
                { 'diff', symbols = { added = '+', modified = '~', removed = '-' } },
                { 'diagnostics', symbols = { error = '󱓻 ', warn = '󱓻 ', info = '󱓻 ', hint = '󱓻 ' } }
            },
            lualine_c = {},
            lualine_x = { { 'filename', path = 1 }, 'filesize', 'filetype', 'encoding', 'fileformat' },
            lualine_y = { 'location', 'progress' },
            lualine_z = {
                { 'searchcount',    fmt = function(str) return str ~= '' and string.format('%7s', str) or str end, },
                { 'selectioncount', fmt = function(str) return str ~= '' and string.format('%2s', str) or str end, },
            }
        }
    }
end

return M
