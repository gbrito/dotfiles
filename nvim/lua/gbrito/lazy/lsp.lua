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
                    override_vim_notify = true, -- Use Fidget for vim.notify()
                    window = {
                        winblend = 0, -- Background transparency
                    },
                },
                -- Explicitly disable implicit integrations
                integration = {
                    ["nvim-tree"] = {
                        enable = false,
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
                    vim.keymap.set(mode, keys, func, { buf = event.buf, desc = 'LSP: ' .. desc })
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
            float = {
                border = 'rounded',
                source = 'if_many',
            },
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
                filetypes = { 'javascript', 'xml', 'python', 'csv' },
                root_dir = function(fname)
                    local util = require('lspconfig.util')
                    local cwd = vim.fn.getcwd()
                    if util.root_pattern('.odoo_lsp', '.odoo_lsp.json')(cwd) then
                        return cwd
                    end
                    local root = util.root_pattern('.odoo_lsp', '.odoo_lsp.json')(fname)
                    if root then
                        return root
                    end
                    -- Fallback to current working directory
                    return cwd
                end,
                init_options = {
                    progress = true,
                },
            },
            sourcery = {},
            ruff = {
                init_options = {
                    settings = {
                        -- Ruff configuration
                        organizeImports = true,
                        fixAll = true,
                        configuration = [[
[format]
quote-style = "double"
indent-style = "space"

[lint.flake8-quotes]
inline-quotes = "double"
docstring-quotes = "double"
multiline-quotes = "double"
                        ]],
                    }
                }
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

        -- Define custom LSP server configurations
        local lspconfig = require('lspconfig')
        local configs = require('lspconfig.configs')

        -- Define sourcery LSP configuration
        if not configs.sourcery then
            configs.sourcery = {
                default_config = {
                    cmd = { 'sourcery', 'lsp' },
                    filetypes = { 'python' },
                    root_dir = lspconfig.util.root_pattern('.git', 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt'),
                    init_options = {
                        token = nil, -- Add your Sourcery token here if you have one
                        extension_version = 'vim.lsp',
                        editor_version = 'neovim',
                    },
                },
            }
        end

        if not configs.odoo_lsp then
            configs.odoo_lsp = {
                default_config = {
                    cmd = { 'odoo-lsp' },
                    filetypes = { 'javascript', 'xml', 'python', 'csv' },
                    root_dir = function(fname)
                        -- Look for Odoo-specific files/directories
                        local root = lspconfig.util.root_pattern(
                            '.odoo_lsp',
                            '.odoo_lsp.json'
                        )(fname)

                        if root then
                            return root
                        end

                        -- Try to get the file's directory
                        local dir = vim.fs.dirname(fname)
                        if dir and dir ~= "" and dir ~= "/" then
                            return dir
                        end

                        -- Last resort: use current working directory
                        return vim.fn.getcwd()
                    end,
                },
            }
        end

        -- Filter out custom LSP servers from ensure_installed since they're not available in Mason
        local ensure_installed = {}
        for server_name, _ in pairs(servers or {}) do
            if server_name ~= "odoo_lsp" and server_name ~= "sourcery" then
                table.insert(ensure_installed, server_name)
            end
        end
        vim.list_extend(ensure_installed, {
            'beautysh',
            'html-lsp',
            'lua-language-server',
            'luacheck',
            'prettier',
            'ruff',
            'pyright',
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

        -- Manually setup custom LSP servers not available through Mason
        if servers.odoo_lsp then
            local server = servers.odoo_lsp
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            -- Ensure we have a valid root_dir function
            server.root_dir = function(fname)
                local util = require('lspconfig.util')
                -- Try to find root based on patterns
                local root = util.root_pattern('.odoo_lsp', '.odoo_lsp.json')(fname)
                if root then
                    return root
                end
                -- If no root found, use the file's directory or cwd
                local dir = vim.fs.dirname(fname)
                if dir and dir ~= "" then
                    return dir
                end
                return vim.fn.getcwd()
            end
            require('lspconfig').odoo_lsp.setup(server)
        end

        -- Manually setup sourcery since it requires custom configuration
        if servers.sourcery then
            local server = servers.sourcery
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig').sourcery.setup(server)
        end
    end,
}
