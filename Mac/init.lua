vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "

vim.wo.number = true


-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local plugins = {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    }
  }
}

table.insert(plugins, {
  "akinsho/toggleterm.nvim",
  config = function()
    require("toggleterm").setup({
      direction = "float",
      float_opts = {
        border = "curved",
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.8),
        winblend = 10,
      },
      close_on_exit = false,
    })
  end,
})

local opts = {}
require("lazy").setup(plugins, opts)

local builtin = require("telescope.builtin")
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

local configs = require("nvim-treesitter.configs")
configs.setup({
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html" },
  highlight = { enable = true },
  indent = { enable = true },
})

require("catppuccin").setup()
vim.cmd.colorscheme "catppuccin"



local Terminal = require("toggleterm.terminal").Terminal

-- Create a persistent floating terminal instance
local cpp_runner = Terminal:new({
  direction = "float",
  close_on_exit = false,
  hidden = true,
})

function CompileAndRunCpp()
  vim.cmd('w') -- Save the file before compiling
  local filename = vim.fn.expand("%:p") -- Get full path of the current file
  local output_file = filename:gsub("%.%w+$", "") -- Remove file extension

  -- AppleScript command to open a new iTerm2 tab and run the program
  local script = string.format(
    [[
    osascript -e 'tell application "iTerm2"
      tell current window
        create tab with profile "Default"
        tell current session
          write text "g++-14 -std=c++14 -o %s %s && %s"
        end tell
      end tell
    end tell'
    ]],
    output_file, filename, output_file
  )

  -- Execute the AppleScript command
  os.execute(script)
end

-- Keybinding to compile & run C++ in a new iTerm2 tab
vim.keymap.set("n", "<leader>r", ":lua CompileAndRunCpp()<CR>", { noremap = true, silent = true })


