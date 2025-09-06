return {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = {
        'nvim-tree/nvim-web-devicons',
        'jasonpanosso/harpoon-tabline.nvim'
    },

    config = function()
        local harpoon = require("harpoon")
        require('harpoon-tabline').setup()
        harpoon:setup()

        vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
        vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

        vim.keymap.set("n", "<A-S-1>", function() harpoon:list():select(1) end)
        vim.keymap.set("n", "<A-S-2>", function() harpoon:list():select(2) end)
        vim.keymap.set("n", "<A-S-3>", function() harpoon:list():select(3) end)
        vim.keymap.set("n", "<A-S-4>", function() harpoon:list():select(4) end)

        -- Toggle previous & next buffers stored within Harpoon list
        vim.keymap.set("n", "<A-S-Left>", function() harpoon:list():prev() end)
        vim.keymap.set("n", "<A-S-Right>", function() harpoon:list():next() end)
    end
}

