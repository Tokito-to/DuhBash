-- General settings
vim.opt.colorcolumn = "80"
vim.opt.updatetime = 50
vim.opt.list = true
vim.opt.listchars = "tab:» ,lead:•,trail:•"

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.guicursor = ""
vim.opt.termguicolors = true

-- Indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.autoindent = true

-- Wrapping and scrolling
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.whichwrap = "h,l,<,>,[,]"

-- Search
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Status Bar
vim.opt.cmdheight = 1

-- Files and backups
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.cache/nvim/undodir"
vim.opt.undofile = true

-- Miscellaneous
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

-- FileTree
vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 1
vim.g.netrw_winsize = 50
vim.g.netrw_liststyle = 4
vim.g.netrw_keepdir = 0

