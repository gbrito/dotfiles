return {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    dependencies = {
        "rafamadriz/friendly-snippets",
    },

    config = function()
        require("luasnip.loaders.from_snipmate").lazy_load()
    end,
}
