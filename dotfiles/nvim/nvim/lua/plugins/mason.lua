return {
    'mason-org/mason.nvim',
    dependencies = {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
    },

    config = function()
        require("mason").setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                }
            }
        })

        require("mason-tool-installer").setup({
            ensure_installed = {
                "stylua", -- lua formatter
                "shellcheck" -- Bash linter
            },
        })
    end
}

