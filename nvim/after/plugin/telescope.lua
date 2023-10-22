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
        },
        mappings = {
            i = {
                ["<C-k>"] = actions.move_selection_previous,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
            }
        }
    }
})

local keymap = vim.keymap

keymap.set("n", "<leader>ff", ":lua require('telescope.builtin').find_files({ follow = true, hidden = true })<CR>",
    { desc = "Fuzzy find files in project" })
keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Fuzzy find recent files" })
keymap.set("n", "<leader>fs", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
    { desc = "Fuzzy string in project" })
keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Fuzzy string under cursor in project" })
keymap.set("n", "<leader>vh", builtin.help_tags, {})
