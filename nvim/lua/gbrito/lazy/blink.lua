return {
    'saghen/blink.cmp',
    build = 'rustup run nightly cargo build --release',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
        -- Snippet Engine
        {
            'L3MON4D3/LuaSnip',
            version = '2.*',
            build = (function()
                -- Build Step is needed for regex support in snippets.
                -- This step is not supported in many windows environments.
                -- Remove the below condition to re-enable on windows.
                if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
                    return
                end
                return 'make install_jsregexp'
            end)(),
            dependencies = {},
            opts = {},
        },
        'brenoprata10/nvim-highlight-colors',
        'folke/lazydev.nvim',
        'moyiz/blink-emoji.nvim',
        'MahanRahmati/blink-nerdfont.nvim',
        'Kaiser-Yang/blink-cmp-avante',
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
        keymap = {
            preset = 'default',
        },

        appearance = {
            nerd_font_variant = 'mono',
        },

        completion = {
            documentation = { auto_show = true, auto_show_delay_ms = 500 },
        },

        sources = {
            default = { 'snippets', 'avante', 'lazydev', 'lsp', 'path', 'buffer' },
            providers = {
                avante = {
                    module = 'blink-cmp-avante',
                    name = 'Avante',
                },
                lazydev = {
                    name = 'LazyDev',
                    module = 'lazydev.integrations.blink',
                    score_offset = 100,
                },
                nerdfont = {
                    -- TODO: update appearance to only show emoji and not lsp symbol
                    module = 'blink-nerdfont',
                    name = 'Nerd Fonts',
                    score_offset = 15,
                    opts = { insert = true },
                },
                emoji = {
                    -- TODO: update appearance to only show emoji and not lsp symbol
                    module = 'blink-emoji',
                    name = 'Emoji',
                    score_offset = 25,
                    opts = { insert = true },
                },
            },
        },

        snippets = { preset = 'luasnip' },
        fuzzy = { implementation = 'prefer_rust_with_warning' },
        signature = { enabled = true },
    },
}
