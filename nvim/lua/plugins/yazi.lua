vim.api.nvim_set_keymap('n', '<Leader>f', '<Cmd>Yazi toggle<CR>', { noremap = true, silent = true })

local M  = {
    src = 'https://github.com/mikavilpas/yazi.nvim',
    depends = { 'https://github.com/nvim-lua/plenary.nvim' },
    events = { 'CmdUndefined' },
    pattern = { 'Yazi' },
}

M.config = function()
    -- local YaziFloatingWindow = require('yazi.window').YaziFloatingWindow

    -- function YaziFloatingWindow:open_and_display()
    --     local buf = vim.api.nvim_create_buf(false, true)
    --     vim.cmd('topleft vsplit')
    --     local win = vim.api.nvim_get_current_win()
    --     vim.api.nvim_win_set_buf(win, buf)
    --     vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * 0.3))
    --
    --     self.win, self.content_buffer = win, buf
    --
    --     vim.bo[buf].filetype = 'yazi'
    --     vim.cmd('setlocal bufhidden=hide nocursorcolumn')
    --
    --     vim.api.nvim_create_autocmd('WinEnter', {
    --         buffer = buf,
    --         callback = function()
    --             if vim.api.nvim_get_current_buf() == buf then vim.cmd('startinsert') end
    --         end,
    --     })
    --     vim.keymap.set('t', '<Esc>', '<Esc>', { buffer = buf })
    --     if vim.fn.mode(true) == 'nt' then vim.api.nvim_feedkeys('i', 'n', false) end
    --     return self
    -- end
    --
    -- function YaziFloatingWindow:close()
    --     if vim.api.nvim_win_is_valid(self.win) then vim.api.nvim_win_close(self.win, true) end
    --     vim.schedule(function()
    --         if vim.api.nvim_buf_is_valid(self.content_buffer) then
    --             vim.api.nvim_buf_delete(self.content_buffer, { force = true })
    --         end
    --     end)
    -- end

    require('yazi').setup {
        -- config_home = vim.fn.expand('$XDG_CONFIG_HOME/yazi/nvim'),

        open_for_directories = false,

        open_multiple_tabs = false,

        change_neovim_cwd_on_close = false,

        highlight_groups = {
            -- See https://github.com/mikavilpas/yazi.nvim/pull/180
            hovered_buffer = nil,
            -- See https://github.com/mikavilpas/yazi.nvim/pull/351
            hovered_buffer_in_same_directory = nil,
        },

        floating_window_scaling_factor = 0.9,

        yazi_floating_window_winblend = 0,

        yazi_floating_window_border = 'rounded',

        yazi_floating_window_zindex = nil,

        log_level = vim.log.levels.OFF,

        -- open_file_function = function(chosen_file, config, state) end,

        keymaps = {
            show_help                            = '<F1>',
            open_file_in_vertical_split          = '<C-v>',
            open_file_in_horizontal_split        = '<C-x>',
            open_file_in_tab                     = '<C-t>',
            grep_in_directory                    = '<C-s>',
            replace_in_directory                 = '<C-g>',
            cycle_open_buffers                   = '<Tab>',
            send_to_quickfix_list                = '<C-q>',
            copy_relative_path_to_selected_files = false,
            change_working_directory             = false,
            open_and_pick_window                 = false,
        },

        -- set_keymappings_function = function(buf, config, context) end,

        clipboard_register = '*',

        hooks = {
            -- yazi_opened                = function(path, buf, config) end,

            -- yazi_closed_successfully   = function(file, config, state) end,

            -- yazi_opened_multiple_files = function(files, config, state) end,

            -- on_yazi_ready              = function(buf, config, api) end,

            -- before_opening_window      = function(winopts) end,
        },

        highlight_hovered_buffers_in_same_directory = true,

        integrations = {
            grep_in_directory = 'fzf-lua',
            grep_in_selected_files = 'fzf-lua',

            -- replace_in_directory = function(directory) end,

            -- replace_in_selected_files = function(selected_files) end,

            resolve_relative_path_application = nil,

            resolve_relative_path_implementation = nil,

            -- available options:
            -- snacks.bufdelete
            -- snacks-if-available
            bufdelete_implementation = 'snacks-if-available',

            -- available options:
            -- - nil (default, no action added)
            -- - "snacks.picker" (snacks.nvim)
            picker_add_copy_relative_path_action = nil,
        },

        future_features = { use_cwd_file = true },
    }
end

return M
