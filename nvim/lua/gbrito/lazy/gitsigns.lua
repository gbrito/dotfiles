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
        vim.keymap.set("n", "<leader>b", ":Gitsigns blame_line<CR>")
        vim.keymap.set("n", "<leader>gd", ":Gitsigns diffthis<CR>")
        vim.keymap.set("n", "<leader>gn", ":Gitsigns nav_hunk 'next'<CR>")
    end
}
