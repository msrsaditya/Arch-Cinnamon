-- Basics
vim.opt.number = true              -- Show line numbers
vim.opt.mouse = 'a'                -- Enable mouse support
vim.opt.clipboard = 'unnamedplus'  -- Use system clipboard

-- Cursor Reset
vim.api.nvim_create_autocmd("ExitPre", {
  group = vim.api.nvim_create_augroup("RestoreCursor", { clear = true }),
  callback = function()
    vim.opt.guicursor = "a:ver90-blinkwait600-blinkon600-blinkoff600"
  end,
})

-- File
vim.opt.fileencoding = 'utf-8' -- Default file encoding
vim.opt.backup = false         -- Don't create backup files
vim.opt.swapfile = false       -- Don't create swap files
vim.opt.undofile = true        -- Enable persistent undo

-- Indentation
vim.opt.expandtab = true      -- Convert tabs to spaces
vim.opt.shiftwidth = 4        -- Number of spaces for auto-indent
vim.opt.tabstop = 4           -- Number of spaces that a tab counts for
vim.opt.smartindent = true    -- Enable smart-indent

-- Search
vim.opt.ignorecase = true     -- Case insensitive search
vim.opt.hlsearch = true       -- Highlight search results
vim.opt.incsearch = true      -- Show search matches as you type

-- Visual
vim.opt.termguicolors = true  -- Enable 24-bit RGB colors
