local cmp = require("cmp")
local cmp_select = {behavior = cmp.SelectBehavior.Select}

local luasnip = require("luasnip")

cmp.setup({
  completion = {
    completeopt = "menu,menuone,preview,noselect",
  },
  snippet = { -- configure how nvim-cmp interacts with snippet engine
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-k>'] = cmp.mapping.select_prev_item(cmp_select),
    ['<C-j>'] = cmp.mapping.select_next_item(cmp_select),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-e>'] = cmp.mapping.abort(), -- close completion window
    ['<CR>'] = cmp.mapping.confirm({ select = false }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<Tab>'] = nil,
    ['<S-Tab>'] = nil,
  }),
  -- sources for autocompletion
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" }, -- snippets
    { name = "buffer" }, -- text within current buffer
    { name = "path" }, -- file system paths
  }),
})

local lspconfig = require("lspconfig")
local cmp_nvim_lsp = require("cmp_nvim_lsp")
local keymap = vim.keymap -- for conciseness
local opts = { noremap = true, silent = true }

local on_attach = function(client, bufnr)
    opts.buffer = bufnr

    keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration
    keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations
    keymap.set("n", "<leader>ws", function() vim.lsp.buf.workspace_symbol() end, opts)
    keymap.set("n", "<leader>of", function() vim.diagnostic.open_float() end, opts)
    keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
    keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
    keymap.set("n", "<leader>cr", function() vim.lsp.buf.references() end, opts)
    keymap.set("n", "<leader>cn", function() vim.lsp.buf.rename() end, opts)
    keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
end

local capabilities = cmp_nvim_lsp.default_capabilities()

local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

lspconfig["html"].setup({
    capabilities = capabilities,
    on_attach = on_attach,
})

-- configure typescript server with plugin
lspconfig["tsserver"].setup({
    capabilities = capabilities,
    on_attach = on_attach,
})

-- configure css server
lspconfig["cssls"].setup({
    capabilities = capabilities,
    on_attach = on_attach,
})

-- configure rust server
lspconfig["rust_analyzer"].setup({
    capabilities = capabilities,
    on_attach = on_attach,
})

-- configure python server
lspconfig["ruff_lsp"].setup({
    capabilities = capabilities,
    on_attach = on_attach,
})

-- configure lua server (with special settings)
lspconfig["lua_ls"].setup({
    capabilities = capabilities,
    on_attach = on_attach,
    settings = { -- custom settings for lua
        Lua = {
            -- make the language server recognize "vim" global
            diagnostics = {
                globals = { "vim" },
            },
            workspace = {
                -- make language server aware of runtime files
                library = {
                    [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                    [vim.fn.stdpath("config") .. "/lua"] = true,
                },
            },
        },
    },
})
