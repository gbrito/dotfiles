local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")
local mason_null_ls = require("mason-null-ls")

-- enable mason and configure icons
mason.setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

mason_lspconfig.setup({
    -- list of servers for mason to install
    ensure_installed = {
        "html",
        "cssls",
        "lua_ls",
        "pyright",
        "rust_analyzer",
    },
    -- auto-install configured servers (with lspconfig)
    automatic_installation = true, -- not the same as ensure_installed
})

mason_null_ls.setup({
    -- list of formatters & linters for mason to install
    ensure_installed = {
        "prettier",
        "stylua",
        "black",
    },
    automatic_installation = true,
})
