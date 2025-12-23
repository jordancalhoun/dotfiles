-- window management
vim.keymap.set("n", "<leader>wh", "<C-w>s", { desc = "Split window horizontally" })
vim.keymap.set("n", "<leader>we", "<C-w>=", { desc = "Make plits equal size" })
vim.keymap.set("i", "jk", "<Esc>")

-- when doing /texthere to highligh occurances of a word, remap esc to clear that once done
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights from buffer" })
