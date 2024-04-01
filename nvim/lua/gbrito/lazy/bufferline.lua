return {
    "akinsho/bufferline.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons"
    },
    config = function()
        require("bufferline").setup({
            options = {
                mode = 'buffers',
                offsets = {
                    {
                        filetype = "NvimTree",
                        text = "File Explorer",
                        highlight = "Directory",
                        separator = true,
                    }
                },
            },
        })
--[[  ]]
        vim.keymap.set("n", "<leader>bc", ":BufferLineCloseOthers<CR>")
        vim.keymap.set("n", "<leader>l", ":BufferLinePick<CR>")
        vim.keymap.set("n", "<leader>c", ":BufferLinePickClose<CR>")
    end
}
