return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "williamboman/mason.nvim", opts = {} },
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{
			"j-hui/fidget.nvim",
			opts = {
				notification = {
					override_vim_notify = true,
					window = { winblend = 0 },
				},
				integration = {
					["nvim-tree"] = { enable = false },
				},
			},
		},
		"saghen/blink.cmp",
	},
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("gbrito-lsp-attach", { clear = true }),
			callback = function(event)
				local map = function(keys, func, desc, mode)
					mode = mode or "n"
					vim.keymap.set(mode, keys, func, { buf = event.buf, desc = "LSP: " .. desc })
				end
				map("<leader>cn", vim.lsp.buf.rename, "[R]e[n]ame")
				map("<leader>ca", vim.lsp.buf.code_action, "Goto [C]ode [A]ction", { "n", "x" })
				map("<leader>cr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
				map("gi", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
				map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
				map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
				map("K", vim.lsp.buf.hover, "[H]over")
				map("gO", require("telescope.builtin").lsp_document_symbols, "Open Document Symbols")
				map("gW", require("telescope.builtin").lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
				map("gt", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")
			end,
		})

		vim.diagnostic.config({
			severity_sort = true,
			float = { border = "rounded", source = "if_many" },
			underline = { severity = vim.diagnostic.severity.ERROR },
			signs = vim.g.have_nerd_font and {
				text = {
					[vim.diagnostic.severity.ERROR] = "󰅚 ",
					[vim.diagnostic.severity.WARN] = "󰀪 ",
					[vim.diagnostic.severity.INFO] = "󰋽 ",
					[vim.diagnostic.severity.HINT] = "󰌶 ",
				},
			} or {},
			virtual_text = {
				source = "if_many",
				spacing = 2,
				format = function(diagnostic)
					return diagnostic.message
				end,
			},
		})

		local capabilities = require("blink.cmp").get_lsp_capabilities()
		capabilities.window = capabilities.window or {}
		capabilities.window.workDoneProgress = true
		vim.lsp.config("*", { capabilities = capabilities })

		vim.lsp.config("lua_ls", {
			settings = {
				Lua = { completion = { callSnippet = "Replace" } },
			},
		})

		vim.lsp.config("ruff", {
			init_options = {
				settings = {
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
				},
			},
		})

		-- Pyright is kept for go-to-definition / hover across third-party packages;
		-- linting is delegated to Ruff (analysis.ignore = { '*' }).
		vim.lsp.config("pyright", {
			settings = {
				pyright = { disableOrganizeImports = true },
				python = { analysis = { ignore = { "*" } } },
			},
		})

		vim.lsp.config("sourcery", {
			cmd = { "sourcery", "lsp" },
			filetypes = { "python" },
			root_markers = { ".git", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt" },
			init_options = {
				token = nil,
				extension_version = "vim.lsp",
				editor_version = "neovim",
			},
		})

		vim.lsp.config("odoo_lsp", {
			cmd = { "odoo-lsp" },
			filetypes = { "javascript", "xml", "python", "csv" },
			root_markers = { ".odoo_lsp", ".odoo_lsp.json" },
			init_options = { progress = true },
		})

		require("mason-tool-installer").setup({
			ensure_installed = {
				"lua_ls",
				"ruff",
				"pyright",
				"beautysh",
				"html-lsp",
				"luacheck",
				"prettier",
				"stylua",
				"typescript-language-server",
			},
		})

		require("mason-lspconfig").setup({
			ensure_installed = {},
			automatic_enable = true,
			automatic_installation = false,
		})

		vim.lsp.enable({ "odoo_lsp", "sourcery" })
	end,
}
