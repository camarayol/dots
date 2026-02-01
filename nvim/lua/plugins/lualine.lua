return {
    source = 'https://github.com/nvim-lualine/lualine.nvim',
    depends = { 'https://github.com/nvim-tree/nvim-web-devicons' },
    config = function()
        require('lualine').setup {
            options = {
                globalstatus = true,
                icons_enabled = false,
                section_separators = '',
                component_separators = '',
                always_divide_middle = false,
                refresh = { statusline = 500 },
            },
            sections = {
                --  
                lualine_a = { { 'mode', separator = { left = '', right = '' } } },
                lualine_b = {
                    { 'branch',      separator = { right = '' } },
                    { 'diff',        separator = { right = '' }, symbols = { added = '+', modified = '~', removed = '-' } },
                    { 'diagnostics', separator = { right = '' }, symbols = { error = '󱓻 ', warn = '󱓻 ', info = '󱓻 ', hint = '󱓻 ' } },
                },
                lualine_c = { '%=', { 'filename', path = 1 } },
                lualine_x = { 'filesize', { 'filetype', icons_enabled = true }, 'encoding', 'fileformat' },
                lualine_y = { { 'location', separator = { left = '' } }, { 'progress', separator = { left = '', right = '' } } },
                lualine_z = {}
            },
        }
    end
}
