local lsp_zero = require('lsp-zero')

local lua_opts = lsp_zero.nvim_lua_ls()
require('lspconfig').lua_ls.setup(lua_opts)

local keymap = vim.keymap -- for conciseness
local opts = { noremap = true, silent = true }

local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end


lsp_zero.on_attach(function(client, bufnr)
    opts.buffer = bufnr

    keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    keymap.set("n", "gD", vim.lsp.buf.declaration, opts)                  -- go to declaration
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
end)

require('mason').setup({})
require('mason-lspconfig').setup({
    handlers = {
        lsp_zero.default_setup,
    },
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
    completion = {
        completeopt = "menu,menuone,preview,noselect",
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
        { name = "buffer" },  -- text within current buffer
        { name = "path" },    -- file system paths
    }),
})

local null_ls = require("null-ls")

local sources = {
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.formatting.black,
    null_ls.builtins.diagnostics.ruff,
    null_ls.builtins.diagnostics.write_good,
}

null_ls.setup({
    sources = sources,
    on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
            vim.keymap.set("n", "<Leader>f", function()
                vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
            end, { buffer = bufnr, desc = "[lsp] format" })
        end

        if client.supports_method("textDocument/rangeFormatting") then
            vim.keymap.set("x", "<Leader>f", function()
                vim.lsp.buf.format({ bufnr = vim.api.nvim_get_current_buf() })
            end, { buffer = bufnr, desc = "[lsp] format" })
        end
    end,
})

local prettier = require("prettier")
prettier.setup({
    bin = 'prettier', -- or `'prettierd'` (v0.22+)
    filetypes = {
        "css",
        "graphql",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "less",
        "markdown",
        "scss",
        "typescript",
        "typescriptreact",
        "yaml",
    },
})
