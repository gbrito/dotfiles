return {
    "neovim/nvim-lspconfig",
    dependencies = {
        { 'williamboman/mason.nvim', opts = {} },
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',
        {
            'j-hui/fidget.nvim',
            opts = {
                -- Options for the notification window
                notification = {
                    window = {
                        winblend = 0, -- Background transparency
                    },
                },
            },
        },
        'saghen/blink.cmp',
    },
    config = function()
        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
            callback = function(event)
                local map = function(keys, func, desc, mode)
                    mode = mode or 'n'
                    vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                end
                map('<leader>cn', vim.lsp.buf.rename, '[R]e[n]ame')
                map('<leader>ca', vim.lsp.buf.code_action, 'Goto [C]ode [A]ction', { 'n', 'x' })
                map('<leader>cr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                map('gi', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
                map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                map('K', vim.lsp.buf.hover, '[H]over')
                map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
                map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
                map('gt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')
            end,
        })

        vim.diagnostic.config {
            severity_sort = true,
            float = { border = 'rounded', source = 'if_many' },
            underline = { severity = vim.diagnostic.severity.ERROR },
            signs = vim.g.have_nerd_font and {
                text = {
                    [vim.diagnostic.severity.ERROR] = '󰅚 ',
                    [vim.diagnostic.severity.WARN] = '󰀪 ',
                    [vim.diagnostic.severity.INFO] = '󰋽 ',
                    [vim.diagnostic.severity.HINT] = '󰌶 ',
                },
            } or {},
            virtual_text = {
                source = 'if_many',
                spacing = 2,
                format = function(diagnostic)
                    local diagnostic_message = {
                        [vim.diagnostic.severity.ERROR] = diagnostic.message,
                        [vim.diagnostic.severity.WARN] = diagnostic.message,
                        [vim.diagnostic.severity.INFO] = diagnostic.message,
                        [vim.diagnostic.severity.HINT] = diagnostic.message,
                    }
                    return diagnostic_message[diagnostic.severity]
                end,
            },
        }

        local servers = {
            odoo_lsp = {
                filetypes = { 'javascript', 'xml', 'python' },
                root_dir = function(fname)
                    return require('lspconfig.util').root_pattern('.odoo_lsp', '.odoo_lsp.json', '.git')(fname)
                        or vim.fs.dirname(fname)
                end,
                init_options = {
                    progress = true,
                },
            },
            pyright = {
                settings = {
                    pyright = {
                        -- Using Ruff's import organizer
                        disableOrganizeImports = true,
                    },
                    python = {
                        analysis = {
                            -- Ignore all files for analysis to exclusively use Ruff for linting
                            ignore = { '*' },
                        },
                    },
                }
            },
            lua_ls = {
                settings = {
                    Lua = {
                        completion = {
                            callSnippet = 'Replace',
                        },
                    },
                },
            },
        }
        local capabilities = require('blink.cmp').get_lsp_capabilities()
        -- Ensure window/workDoneProgress capability is set
        capabilities.window = capabilities.window or {}
        capabilities.window.workDoneProgress = true

        -- Define odoo_lsp server configuration
        local lspconfig = require('lspconfig')
        local configs = require('lspconfig.configs')

        if not configs.odoo_lsp then
            configs.odoo_lsp = {
                default_config = {
                    cmd = { 'odoo-lsp' },
                    filetypes = { 'javascript', 'xml', 'python' },
                    root_dir = function(fname)
                        return lspconfig.util.root_pattern('.odoo_lsp', '.odoo_lsp.json', '.git')(fname)
                            or vim.fs.dirname(fname)
                    end,
                },
            }
        end

        -- Filter out odoo_lsp from ensure_installed since it's not available in Mason
        local ensure_installed = {}
        for server_name, _ in pairs(servers or {}) do
            if server_name ~= "odoo_lsp" then
                table.insert(ensure_installed, server_name)
            end
        end
        vim.list_extend(ensure_installed, {
            'beautysh',
            'html-lsp',
            'lua-language-server',
            'luacheck',
            'ruff',
            'pyright',
            'sourcery',
            'stylua',
            'typescript-language-server',
        })
        require('mason-tool-installer').setup { ensure_installed = ensure_installed }

        require('mason-lspconfig').setup {
            ensure_installed = {},
            automatic_enable = true,
            automatic_installation = false,
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                    require('lspconfig')[server_name].setup(server)
                end,
            },
        }

        -- Manually setup odoo_lsp since it's not available through Mason
        if servers.odoo_lsp then
            local server = servers.odoo_lsp
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            -- Add explicit handlers to ensure notifications work
            server.handlers = {
                ["$/progress"] = vim.lsp.handlers.progress,
                ["window/showMessage"] = vim.lsp.handlers.show_message,
                ["window/logMessage"] = vim.lsp.handlers.log_message,
            }
            require('lspconfig').odoo_lsp.setup(server)
        end
    end,
}
