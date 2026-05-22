vim.opt.autochdir = true

-- define the node version for Copilot to use, in case project is using older version
vim.g.copilot_node_command = os.getenv("HOME") .. "/.nodenv/versions/22.15.0/bin/node"
