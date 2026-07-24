return {
  {
    enabled = false,
    'gelguy/wilder.nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
      'romgrk/fzy-lua-native',
    },
    config = function()
      local wilder = require('wilder')

      wilder.setup({
        modes = { ':', '/' },
        next_key = '<C-j>',
        previous_key = '<C-k>',
      })

      wilder.set_option(
        'renderer',
        wilder.popupmenu_renderer(wilder.popupmenu_palette_theme({
          highlights = {
            accent = wilder.make_hl(
              'WilderAccent',
              'Pmenu',
              { { a = 1 }, { a = 1 }, { foreground = '#ff9036' } }
            ),
          },
          highlighter = {
            wilder.lua_fzy_highlighter(),
          },
          border = 'rounded',
          left = { ' ', wilder.popupmenu_devicons() },
          right = { ' ', wilder.popupmenu_scrollbar() },
          max_height = '75%',
          min_height = 0,
          prompt_position = 'top',
          reverse = 0,
        }))
      )

      wilder.set_option('pipeline', {
        wilder.branch(
          wilder.cmdline_pipeline({
            language = 'vim',
            fuzzy = 1,
          }),
          wilder.vim_search_pipeline()
        ),
      })
    end,
  },
  -- lazy.nvim
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      'rcarriga/nvim-notify',
    },
    config = function()
      require('noice').setup({
        views = {
          cmdline_popup = {
            position = {
              row = 5,
              col = '50%',
            },
            size = {
              width = 60,
              height = 'auto',
            },
          },
          popupmenu = {
            relative = 'editor',
            position = {
              row = 8,
              col = '50%',
            },
            size = {
              width = 60,
              height = 10,
            },
            border = {
              style = 'rounded',
              padding = { 0, 1 },
            },
            win_options = {
              winhighlight = { Normal = 'Normal', FloatBorder = 'DiagnosticInfo' },
            },
          },
        },
      })
    end
  },
}
