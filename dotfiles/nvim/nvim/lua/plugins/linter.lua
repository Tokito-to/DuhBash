return {
    'mfussenegger/nvim-lint',
    event = { "BufReadPre", "BufNewFile" },

    config = function()
        local lint = require('lint')

        lint.linters_by_ft = {
            sh = { 'shellcheck' },
            python = { 'flake8' }
        }

        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                lint.try_lint()
            end,
        })

        vim.keymap.set("n", "<leader>ll", function()
            lint.try_lint()
        end, { desc = "Trigger linting for current file" })

        vim.diagnostic.enable = true
        vim.diagnostic.config({
            virtual_text = true
        })

        vim.keymap.set('n', '<leader>gk', function()
            local lines = not vim.diagnostic.config().virtual_lines
            local text = not vim.diagnostic.config().virtual_text
            vim.diagnostic.config({ virtual_lines = lines, virtual_text = text })
        end, { desc = 'Toggle diagnostic virtual_lines' })
    end
}

