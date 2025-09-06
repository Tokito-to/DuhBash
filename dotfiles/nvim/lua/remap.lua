-- Leader Maps
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Rexplore)

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Select & Fix Copy" })

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Copy to Clipboard" } )
vim.keymap.set("n", "<leader>Y", [["+Y]] , { desc = "Copy to ClipBoard" })

-- Control Maps
vim.keymap.set("n",  "<C-a>", "ggVG", { desc = "Select All" })

-- Alt Maps
vim.keymap.set("n", "<C-k>", ":wincmd k<CR>")
vim.keymap.set("n", "<C-j>", ":wincmd j<CR>")
vim.keymap.set("n", "<C-h>", ":wincmd h<CR>")
vim.keymap.set("n", "<C-l>", ":wincmd l<CR>")

-- SuperUser Write Keymap
local session_type = os.getenv('XDG_SESSION_TYPE')

vim.api.nvim_create_user_command('W',
    function()
        if session_type == 'tty' then
            print("tty unsupported!. Abort...")
            return
        else
            vim.cmd [[w !pkexec tee % > /dev/null]]
            vim.cmd [[edit!]]
        end
    end,
    { bang = true }
)

