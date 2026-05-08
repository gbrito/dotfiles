return {
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",
			build = "make",

			-- `cond` is a condition used to determine whether this plugin should be
			-- installed and loaded.
			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-live-grep-args.nvim" },
		{ "nvim-telescope/telescope-ui-select.nvim" },
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
	},

	keys = {
		{
			"<leader>ff",
			function()
				require("telescope.builtin").find_files({ follow = true, hidden = true })
			end,
			desc = "[F]ind [F]iles",
		},
		{
			"<leader>fr",
			function()
				require("telescope.builtin").oldfiles()
			end,
			desc = "[F]ind [R]ecent files",
		},
		{
			"<leader>fs",
			function()
				require("telescope").extensions.live_grep_args.live_grep_args()
			end,
			desc = "[F]ind [S]tring (live grep)",
		},
		{
			"<leader>fc",
			function()
				require("telescope.builtin").grep_string()
			end,
			desc = "[F]ind [C]ursor grep",
		},
		{
			"<leader>vh",
			function()
				require("telescope.builtin").help_tags()
			end,
			desc = "[V]iew [H]elp tags",
		},
		{
			"<C-p>",
			function()
				require("telescope.builtin").git_files()
			end,
			desc = "Git files",
		},
		{
			"<leader>fws",
			function()
				require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") })
			end,
			desc = "[F]ind [W]ord under cursor",
		},
		{
			"<leader>fWs",
			function()
				require("telescope.builtin").grep_string({ search = vim.fn.expand("<cWORD>") })
			end,
			desc = "[F]ind [W]ORD under cursor",
		},
	},

	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			extensions = {
				live_grep_args = {
					additional_args = { "--follow" },
				},
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
			},
			defaults = {
				vimgrep_arguments = {
					"rg",
					"--follow",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--hidden",
					"--smart-case",
				},
				file_ignore_patterns = {
					"%.dump",
					"%.sql",
					"%.xlsx",
					"%.zip",
					"^node_modules/",
					"%.git/",
					"__pycache__/",
					"%.idea/",
				},
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
						["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
					},
				},
			},
		})

		pcall(telescope.load_extension, "fzf")
		pcall(telescope.load_extension, "ui-select")
		pcall(telescope.load_extension, "live_grep_args")
	end,
}
