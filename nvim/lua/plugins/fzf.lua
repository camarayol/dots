return {
    source = "https://github.com/ibhagwan/fzf-lua",
    config = function()
        local fzf = function(cmd, opts) return string.format("<Cmd>lua require('fzf-lua').%s(%s)<CR>", cmd, opts) end
        Core.setKeyMaps {
            { "n", "\\",            fzf("builtin", "{resume=true}"),      { desc = "[Fzf] builtin"       } },
            { "n", "F",             fzf("files"),                         { desc = "[Fzf] Find files"    } },
            { "n", "B",             fzf("buffers"),                       { desc = "[Fzf] Find buffers"  } },
            { "n", "<C-f>",         fzf("lgrep_curbuf", "{resume=true}"), { desc = "[Fzf] Curbuf search" } },
            { "n", "<leader><C-f>", fzf("live_grep", "{resume=true}"),    { desc = "[Fzf] Global search" } },
        }

        require("fzf-lua").setup {
            winopts      = {
                height = 0.95,
                width = 0.85,
                border = "border",
                preview = { default = "builtin", vertical = "right", horizontal = "right" },
            },
            builtin      = { winopts = { height = 0.80, width = 0.80 } },
            commands     = { winopts = { preview = { hidden = "hidden" } } },
            colorschemes = { live_preview = false },
            git          = {
                commits = {
                    cmd = "git log --graph --color=always --date=format:'%m-%d' --pretty=format:'%C(yellow)%h%d %C(magenta)%cd %C(blue)%cn %C(white)%s %Creset'",
                    preview = "git show --color=always {2} | $(git config pager.diff || echo 'cat')",
                },
                actions = { ["default"] = require("fzf-lua.actions").dummy_abort }
            },
            grep         = { rg_opts = "--column --no-heading --color=always --smart-case --max-columns=4096" }
        }
    end
}
