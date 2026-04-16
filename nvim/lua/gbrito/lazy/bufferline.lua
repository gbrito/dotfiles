return {
	"akinsho/bufferline.nvim",
	event = "VeryLazy",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	keys = {
		{ "<leader>l", "<cmd>BufferLinePick<CR>", desc = "Buffer pick" },
		{ "<leader>c", "<cmd>BufferLinePickClose<CR>", desc = "Buffer pick-close" },
		{ "<leader>bc", "<cmd>BufferLineCloseOthers<CR>", desc = "Buffer close others" },
	},
	opts = {
		options = {
			mode = "buffers",
			offsets = {
				{
					filetype = "NvimTree",
					text = "File Explorer",
					highlight = "Directory",
					separator = true,
				},
			},
		},
	},
}
