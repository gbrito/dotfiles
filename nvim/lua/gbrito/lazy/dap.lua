return {
    "mfussenegger/nvim-dap",
    dependencies = {
        {
            "mfussenegger/nvim-dap-python",
            "rcarriga/nvim-dap-ui",
            "theHamsta/nvim-dap-virtual-text",
            "nvim-telescope/telescope-dap.nvim",
        }
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")
        local dapvirtualtext = require("nvim-dap-virtual-text")
        require('dap-python').setup('~/.virtualenvs/debugpy/bin/python')

        dap.set_log_level('DEBUG')

        dapui.setup()
        dapvirtualtext.setup()

        dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
        end

        vim.keymap.set('n', '<C-b>', function() dap.toggle_breakpoint() end)
        vim.keymap.set('n', '<F4>', function()
            require('dap.ext.vscode').load_launchjs(".dap-config.json")
            dap.continue()
        end)
        vim.keymap.set('n', '<F8>', function() dap.step_over() end)
        vim.keymap.set('n', '<F9>', function() dap.step_into() end)
        vim.keymap.set('n', '<F10>', function() dap.step_out() end)
        vim.keymap.set('n', '<F5>', function() dapui.toggle() end)
    end
}
