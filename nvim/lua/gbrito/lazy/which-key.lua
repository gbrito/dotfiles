return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	opts = {
		preset = "modern",
		spec = {
			{ "<leader>f", group = "Find" },
			{ "<leader>e", group = "File explorer" },
			{ "<leader>b", group = "Buffer" },
			{ "<leader>g", group = "Git / Hunks" },
		},
	},
	keys = {
		{
			"<leader>?",
			function()
				require("which-key").show({ global = false })
			end,
			desc = "Buffer local keymaps (which-key)",
		},
	},
}
