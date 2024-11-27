return {
    "VonHeikemen/lsp-zero.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-cmdline",
        "rafamadriz/friendly-snippets",
        "j-hui/fidget.nvim",
        "jose-elias-alvarez/null-ls.nvim",
        "MunifTanjim/prettier.nvim",
    },

    config = function()
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local lsp_zero = require('lsp-zero')
        local luasnip = require('luasnip')

        require("fidget").setup({})

        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            formatting = lsp_zero.cmp_format(),
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
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end),
                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end),
            }),
            -- sources for autocompletion
            sources = cmp.config.sources({
                { name = "luasnip" }, -- snippets
                { name = "nvim_lsp" },
                { name = "buffer" },  -- text within current buffer
                { name = "path" },    -- file system paths
            }),
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
        })

        -- Setup up vim-dadbod
        cmp.setup.filetype({ "sql" }, {
            sources = {
                { name = "vim-dadbod-completion" },
                { name = "buffer" },
            },
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })

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

        -- define our custom language server here
        lsp_zero.new_client({
            name = 'odoo-lsp',
            cmd = { 'odoo-lsp' },
            filetypes = { 'javascript', 'xml', 'python' },
            root_dir = function()
                return lsp_zero.dir.find_first({ '.odoo_lsp', '.odoo_lsp.json' })
            end,
        })

        require('mason').setup({})
        require('mason-lspconfig').setup({
            handlers = {
                lsp_zero.default_setup,
            },
        })

        local null_ls = require("null-ls")
        local sources = {
            null_ls.builtins.formatting.beautysh,
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
            bin = 'prettier',
            cli_options = {
                bracket_spacing = false,
                use_tabs = false,
                print_width = 88,
                prose_wrap = "always",
                semi = true,
                trailing_comma = "es5",
                html_whitespace_sensitivity = "strict",
            },
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
                "xml",
                "yaml",
            },
        })
    end
}
