return {
    "lewis6991/gitsigns.nvim",
    config = function()
        require("gitsigns").setup({
            signcolumn = true,
            watch_gitdir = {
                follow_files = true
            },
            attach_to_untracked = true
        })
        vim.keymap.set("n", "<leader>gg", ":Gitsigns blame_line<CR>")
        vim.keymap.set("n", "<leader>gd", ":Gitsigns diffthis<CR>")
    end
}
