local bufferline = require("bufferline")

bufferline.setup()

vim.keymap.set("n", "<leader>tc", ":BufferLineCloseOthers<CR>")
vim.keymap.set("n", "<C-n>", ":BufferLineCyclePrev<CR>")
vim.keymap.set("n", "<C-m>", ":BufferLineCycleNext<CR>")
