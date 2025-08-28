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

                -- Navigate to related diagnostic information
                map('<leader>cc', function()
                    local line = vim.fn.line('.') - 1
                    local diagnostics = vim.diagnostic.get(0, { lnum = line })

                    if #diagnostics == 0 then
                        print("No diagnostics at cursor position")
                        return
                    end

                    -- Collect all related locations
                    local related_items = {}
                    for _, diag in ipairs(diagnostics) do
                        if diag.user_data and diag.user_data.lsp and diag.user_data.lsp.relatedInformation then
                            for _, info in ipairs(diag.user_data.lsp.relatedInformation) do
                                if info.location and info.location.uri then
                                    local filename = vim.uri_to_fname(info.location.uri)
                                    local lnum = info.location.range.start.line + 1
                                    local col = info.location.range.start.character + 1
                                    table.insert(related_items, {
                                        filename = filename,
                                        lnum = lnum,
                                        col = col,
                                        text = info.message,
                                    })
                                end
                            end
                        end
                    end

                    if #related_items == 0 then
                        print("No related information found")
                        return
                    end

                    -- If only one item, jump directly
                    if #related_items == 1 then
                        local item = related_items[1]
                        vim.cmd('edit ' .. item.filename)
                        vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
                        return
                    end

                    -- Multiple items: use quickfix list
                    local qf_items = {}
                    for _, item in ipairs(related_items) do
                        table.insert(qf_items, {
                            filename = item.filename,
                            lnum = item.lnum,
                            col = item.col,
                            text = item.text,
                        })
                    end

                    vim.fn.setqflist(qf_items)
                    vim.cmd('copen')
                end, 'Navigate to related diagnostic information')
            end,
        })

        vim.diagnostic.config {
            severity_sort = true,
            float = {
                border = 'rounded',
                source = 'if_many',
                -- Format function to include related information
                format = function(diagnostic)
                    local message = diagnostic.message
                    -- Check for related information from LSP
                    if diagnostic.user_data and diagnostic.user_data.lsp then
                        local related = diagnostic.user_data.lsp.relatedInformation
                        if related and #related > 0 then
                            message = message .. "\n\nRelated Information:"
                            for _, info in ipairs(related) do
                                message = message .. "\n• " .. info.message
                                if info.location and info.location.uri then
                                    local filename = vim.uri_to_fname(info.location.uri)
                                    local line = info.location.range.start.line + 1
                                    message = message .. " (" .. filename .. ":" .. line .. ")"
                                end
                            end
                        end
                    end
                    return message
                end
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
                filetypes = { 'javascript', 'xml', 'python' },
                root_dir = function(fname)
                    local root = require('lspconfig.util').root_pattern('.odoo_lsp', '.odoo_lsp.json', '.git')(fname)
                    if root then
                        return root
                    end
                    -- Fallback to current working directory if no root pattern found
                    return vim.fn.getcwd()
                end,
                init_options = {
                    progress = true,
                },
            },
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

        -- Define odoo_lsp server configuration
        local lspconfig = require('lspconfig')
        local configs = require('lspconfig.configs')

        if not configs.odoo_lsp then
            configs.odoo_lsp = {
                default_config = {
                    cmd = { 'odoo-lsp' },
                    filetypes = { 'javascript', 'xml', 'python' },
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
    end,
}
