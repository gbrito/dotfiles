local bufferline = require("bufferline")

bufferline.setup({
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

vim.keymap.set("n", "<leader>bc", ":BufferLineCloseOthers<CR>")
vim.keymap.set("n", "<leader>l", ":BufferLinePick<CR>")
vim.keymap.set("n", "<leader>b", ":BufferLinePickClose<CR>")
