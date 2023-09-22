local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

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
        "ruff_lsp",
        "rust_analyzer",
    },
    -- auto-install configured servers (with lspconfig)
    automatic_installation = true, -- not the same as ensure_installed
})
