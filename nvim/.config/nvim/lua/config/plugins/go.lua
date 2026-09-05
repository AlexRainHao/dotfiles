return {
  'ray-x/go.nvim',
  dependencies = {
    'ray-x/guihua.lua',
    'neovim/nvim-lspconfig',
    'nvim-treesitter/nvim-treesitter',
    'FeiyouG/commander.nvim',
  },
  config = function()
    require('go').setup({
      gofmt = 'golines',
      gofmt_args = {
        '--max-len=80',
        '--base-formatter=goimports',
      },
    })

    local commander = require('commander')

    commander.add({
      {
        desc = 'Go Add json Tag',
        cmd = '<CMD>GoAddTag json<CR>',
      },
      {
        desc = 'Go Remove json Tag',
        cmd = '<CMD>GoRmTag json',
      },
      {
        desc = 'Go Add yaml Tag',
        cmd = '<CMD>GoAddTag yaml<CR>',
      },
      {
        desc = 'Go Remove yaml Tag',
        cmd = '<CMD>GoRmTag yaml',
      },
      {
        desc = 'Go Fill Struct',
        cmd = '<CMD>GoFillStruct<CR>',
      },
    })
  end,
  ft = { 'go', 'gomod' },
  build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
}
