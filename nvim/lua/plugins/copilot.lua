return {
    source = 'https://github.com/zbirenbaum/copilot.lua',
    config = function()
        require('copilot').setup {
            panel = { enabled = false },
            suggestion = {
                enabled = true,
                auto_trigger = true,
                debounce = 150,
                keymap = {
                    accept = '<M-l>',
                    accept_word = false,
                    accept_line = false,
                    next = '<M-]>',
                    prev = '<M-[>',
                },
            },
        }
    end
}
