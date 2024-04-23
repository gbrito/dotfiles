return {
    "nvim-telescope/telescope.nvim",

    tag = "0.1.6",

    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-live-grep-args.nvim",
        "nvim-tree/nvim-web-devicons",
    },

    config = function()
        local telescope = require("telescope")
        local actions = require("telescope.actions")
        local builtin = require("telescope.builtin")

        telescope.load_extension("live_grep_args")

        telescope.setup({
            defaults = {
                vimgrep_arguments = {
                    "rg",
                    "-L",
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column",
                    "--hidden",
                    "--smart-case"
                },
                file_ignore_patterns = {
                    "%.dump",
                    "%.sql",
                    "%.xlsx",
                    "%.zip",
                    "^node_modules/",
                    "%.git/",
                    "__pycache__/",
                    "%.idea/"
                },
                mappings = {
                    i = {
                        ["<C-k>"] = actions.move_selection_previous,
                        ["<C-j>"] = actions.move_selection_next,
                        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                    }
                }
            }
        })

        vim.keymap.set("n", "<leader>ff",
            ":lua require('telescope.builtin').find_files({ follow = true, hidden = true })<CR>",
            {})
        vim.keymap.set("n", "<leader>fr", builtin.oldfiles, {})
        vim.keymap.set("n", "<leader>fs", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
            {})
        vim.keymap.set('n', '<C-p>', builtin.git_files, {})
        vim.keymap.set("n", "<leader>fc", builtin.grep_string, {})
        vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})

        vim.keymap.set('n', '<leader>fws', function()
            local word = vim.fn.expand("<cword>")
            builtin.grep_string({ search = word })
        end)
        vim.keymap.set('n', '<leader>fWs', function()
            local word = vim.fn.expand("<cWORD>")
            builtin.grep_string({ search = word })
        end)
    end
}
