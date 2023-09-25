local telescope = require("telescope")
local actions = require("telescope.actions")
local builtin = require("telescope.builtin")

telescope.setup({
    defaults = {
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

keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Fuzzy find files in project" })
keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Fuzzy find recent files" })
keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Fuzzy string in project" })
keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Fuzzy string under cursor in project" })
keymap.set("n", "<leader>vh", builtin.help_tags, {})
