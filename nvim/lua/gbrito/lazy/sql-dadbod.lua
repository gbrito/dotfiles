return {
    "tpope/vim-dadbod",
    dependencies = {
        "kristijanhusak/vim-dadbod-completion",
        "kristijanhusak/vim-dadbod-ui",
    },
    vim.keymap.set("n", "<leader>db", "<cmd>DBUIToggle<CR>")
}
