return {
    source = 'https://github.com/nvim-tree/nvim-web-devicons',
    config = function()
        require('nvim-web-devicons').setup {
            override_by_filename = {},
            override_by_extension = {},
        }
    end
}
