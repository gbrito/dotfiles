return {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = true,
	cmd = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeCollapse", "NvimTreeRefresh" },
	keys = {
		{ "<leader>ee", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file explorer" },
		{ "<leader>ef", "<cmd>NvimTreeFindFile<CR>", desc = "Toggle file explorer on current file" },
		{ "<leader>ec", "<cmd>NvimTreeCollapse<CR>", desc = "Collapse file explorer" },
		{ "<leader>er", "<cmd>NvimTreeRefresh<CR>", desc = "Refresh file explorer" },
	},
	dependencies = {
		{ "nvim-tree/nvim-web-devicons" },
	},
	config = function()
		local api = require("nvim-tree.api")
		local nvimtree = require("nvim-tree")

		local function on_attach(bufnr)
			api.map.on_attach.default(bufnr)

			vim.keymap.set("n", "H", api.filter.dotfiles.toggle, {
				buffer = bufnr,
				noremap = true,
				silent = true,
				nowait = true,
				desc = "Toggle Filter: Dotfiles",
			})
		end

		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		vim.cmd([[ highlight NvimTreeIndentMarker guifg=#3FC5FF ]])

		nvimtree.setup({
			on_attach = on_attach,
			view = {
				width = 35,
				relativenumber = true,
			},

			renderer = {
				indent_markers = {
					enable = true,
				},
				icons = {
					glyphs = {
						folder = {
							arrow_closed = "", -- arrow when folder is closed
							arrow_open = "", -- arrow when folder is open
						},
					},
				},
			},

			actions = {
				open_file = {
					window_picker = {
						enable = false,
					},
				},
			},

			filters = {
				dotfiles = true,
				custom = { ".DS_Store", "CLAUDE.md", "AGENTS.md", ".claude", ".opencode" },
			},

			git = {
				ignore = false,
			},
		})
	end,
}
