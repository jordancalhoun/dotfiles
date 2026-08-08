vim.opt.autochdir = true

-- Forward yanks from remote sessions through the terminal to the local clipboard.
if vim.env.SSH_CONNECTION then
  vim.g.clipboard = "osc52"
  vim.opt.clipboard = "unnamedplus"
end

-- define the node version for Copilot to use, in case project is using older version
vim.g.copilot_node_command = os.getenv("HOME") .. "/.nodenv/versions/22.15.0/bin/node"
