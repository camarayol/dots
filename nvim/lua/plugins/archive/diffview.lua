return {
    -- https://github.com/sindrets/diffview.nvim
    "sindrets/diffview.nvim",

    keys = {
        { mode = "n", "<leader>gl", "<Cmd>DiffviewLog<CR>"         },
        { mode = "n", "<leader>go", "<Cmd>DiffviewOpen<CR>"        },
        { mode = "n", "<leader>gc", "<Cmd>DiffviewClose<CR>"       },
        { mode = "n", "<leader>gf", "<Cmd>DiffviewFocusFiles<CR>"  },
        { mode = "n", "<leader>gh", "<Cmd>DiffviewFileHistory<CR>" },
    },
    opts = { use_icons = false }
}
