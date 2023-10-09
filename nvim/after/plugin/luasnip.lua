local ls = require("luasnip")
local keymap = vim.keymap

require("luasnip.loaders.from_snipmate").lazy_load()

keymap.set({"i", "s"}, "<Tab>", function() ls.jump( 1) end, {silent = true})
keymap.set({"i", "s"}, "<S-Tab>", function() ls.jump(-1) end, {silent = true})

