return {
  {
    'AlexRainHao/lazy-reload.nvim',
    lazy = false,
    main = 'lazy-reload',
    opts = {
      reload_modules = {
        'config.defaults',
        'config.keymaps',
        'config.backup',
        'specific',
        'lsp',
      },
      reload_plugins = {
        'commander.nvim',
        'uv.nvim',
        'go.nvim',
        'nvim-notify',
      },
      lazy_spec = function()
        return require('config.plugin_specs')()
      end,
      before_plugin_reload = function()
        local ok, commander = pcall(require, 'commander')
        if ok then
          commander.clear()
        end
      end,
      after_reload = function()
        pcall(require, 'lsp.keymaps')
      end,
    },
  },
}
