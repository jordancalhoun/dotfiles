return {
  {
    "datsfilipe/vesper.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("vesper").setup({
        transparent = true,
        overrides = {
          SnacksNormal = { link = "Normal" },
          SnacksNormalNC = { link = "Normal" },
          SnacksPicker = { link = "Normal" },
          SnacksPickerList = { link = "Normal" },
          SnacksPickerInput = { link = "Normal" },
          SnacksPickerBox = { link = "Normal" },
          SnacksPickerPreview = { link = "Normal" },
        },
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "vesper",
    },
  },
}
