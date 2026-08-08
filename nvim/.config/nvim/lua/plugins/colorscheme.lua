return {
  {
    "webhooked/kanso.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("kanso").setup({
        transparent = true,
        background = {
          dark = "ink",
          light = "pearl",
        },
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanso-ink",
    },
  },
}
