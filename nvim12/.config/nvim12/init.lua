-- Search
vim.o.ignorecase = true
vim.o.smartcase = true

-- temp files
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false
vim.o.undofile = true

vim.g.mapleader = " "
vim.opt.clipboard:append("unnamedplus")
vim.keymap.set("i", "jk", "<Esc>")

vim.pack.add({
  { src = "https://github.com/vague-theme/vague.nvim" },
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/mason-org/mason.nvim' },
  { src = 'https://github.com/stevearc/oil.nvim' },
  { src = 'https://github.com/christoomey/vim-tmux-navigator' },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter",        version = "main" },
})

-- Oil Setup
require("oil").setup({
  lsp_file_methods = {
    enabled = true,
    timeout_ms = 1000,
    autosave_changes = true,
  },
  columns = {
    "permissions",
    "icon",
  },
  float = {
    max_width = 0.7,
    max_height = 0.6,
    border = "rounded",
  },
})

-- LSP Setup
require("mason").setup()
vim.lsp.enable({ "lua_ls", "svelte" })
vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)

-- auto complete for LSP to omnicomplete
-- Ideally autocomplete is improved with tab, and dynamic boxes
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client:supports_method('textDocument/completion') then
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})
vim.cmd("set completeopt+=noselect")

-- UI Stuff
vim.cmd("colorscheme vague")
vim.o.termguicolors = true
vim.o.cursorline = true

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.smartindent = true

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"

vim.o.background = "dark" -- or "light"
vim.o.winborder = "rounded"
vim.cmd([[
  highlight Normal guibg=NONE ctermbg=NONE
  highlight NormalNC guibg=NONE ctermbg=NONE
  highlight NormalFloat guibg=NONE
  highlight FloatBorder guibg=NONE
]])

-- window management
vim.keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window veritcally" })
vim.keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make plits equal size" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- when doing /texthere to highligh occurances of a word, remap esc to clear that once done
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights from buffer" })

vim.opt.autochdir = true

-- clean up packages
local function pack_clean()
  local active_plugins = {}
  local unused_plugins = {}

  for _, plugin in ipairs(vim.pack.get()) do
    active_plugins[plugin.spec.name] = plugin.active
  end

  for _, plugin in ipairs(vim.pack.get()) do
    if not active_plugins[plugin.spec.name] then
      table.insert(unused_plugins, plugin.spec.name)
    end
  end

  if #unused_plugins == 0 then
    print("No unused plugins.")
    return
  end

  local choice = vim.fn.confirm("Remove unused plugins?", "&Yes\n&No", 2)
  if choice == 1 then
    vim.pack.del(unused_plugins)
  end
end

vim.keymap.set("n", "<leader>pc", pack_clean)
