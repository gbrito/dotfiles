function ColorMyPencils(color)
    color = color or "tokyonight"
    local ok, _ = pcall(vim.cmd.colorscheme, color)
    if not ok then
        vim.notify("Colorscheme " .. color .. " not found, falling back to default", vim.log.levels.WARN)
        vim.cmd.colorscheme("default")
    else
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end
end

return {
    "folke/tokyonight.nvim",
    config = function()
        require("tokyonight").setup({
            style = "storm",
            transparent = false,
            terminal_colors = true,
            styles = {
                comments = { italic = false },
                keywords = { italic = false },
                sidebars = "dark",
                floats = "dark",
            },
        })
        ColorMyPencils()
    end
}
