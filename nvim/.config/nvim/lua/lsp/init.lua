local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('*', {
  capabilities = capabilities,
})

-- Configure diagnostics
vim.diagnostic.config({
  underline = true,
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '✘',
      [vim.diagnostic.severity.WARN] = '▲',
      [vim.diagnostic.severity.HINT] = '⚑',
      [vim.diagnostic.severity.INFO] = '»',
    },
  },
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'none', -- Changed from "rounded" to "none"
    source = 'if_many',
    header = '',
    prefix = '',
  },
})

-- Set up CursorHold autocommand to show diagnostics on hover
vim.api.nvim_create_autocmd('CursorHold', {
  callback = function()
    vim.diagnostic.open_float({
      focusable = false,
      close_events = {
        'BufLeave',
        'CursorMoved',
        'InsertEnter',
        'FocusLost',
      },
      border = 'rounded', -- Changed from "rounded" to "none"
      source = 'if_many',
      prefix = '',
    })
  end,
})

-- Set up LspAttach autocmd for per-buffer configuration
local autocomplete_configured = false
vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP actions',
  callback = function(event)
    -- Configure autocomplete once (not per buffer)
    if not autocomplete_configured then
      local ok, err = pcall(require('config.plugins.lsp').configfunc)
      if ok then
        autocomplete_configured = true
      else
        vim.notify(
          'Failed to configure autocomplete: ' .. tostring(err),
          vim.log.levels.ERROR
        )
      end
    end

    local ok, err = pcall(require('lsp.keymaps').setup, event.buf)
    if not ok then
      vim.notify(
        'Failed to setup LSP keymaps: ' .. tostring(err),
        vim.log.levels.ERROR
      )
    end
  end,
})

require('lsp.servers.misc').setup()
require('lsp.servers.lua').setup()
require('lsp.servers.python').setup()
require('lsp.servers.markdown').setup()
require('lsp.servers.typescript').setup()
require('lsp.servers.web').setup()
require('lsp.servers.go').setup()
require('lsp.servers.rust').setup()
require('lsp.servers.flutter').setup()

local format_on_save_group = vim.api.nvim_create_augroup(
  'LspFormatOnSave',
  { clear = true }
)
vim.api.nvim_create_autocmd('BufWritePre', {
  group = format_on_save_group,
  pattern = '*',
  callback = function(event)
    if not vim.bo[event.buf].modifiable or vim.bo[event.buf].buftype ~= '' then
      return
    end

    local filetype = vim.bo[event.buf].filetype
    local formatter_name = filetype == 'go' and 'null-ls' or nil
    local clients = vim.lsp.get_clients({
      bufnr = event.buf,
      method = 'textDocument/formatting',
      name = formatter_name,
    })

    if #clients == 0 then
      return
    end

    vim.lsp.buf.format({
      bufnr = event.buf,
      async = false,
      timeout_ms = 3000,
      name = formatter_name,
    })
  end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.py',
  callback = function()
    vim.lsp.buf.code_action({
      context = { only = { 'source.organizeImports' } },
      apply = true,
    })
  end,
})

local enable_document_color = function()
  local group = vim.api.nvim_create_augroup('CustomLSPDocumentColor', { clear = true })
  local opts = { style = 'virtual' }

  vim.api.nvim_create_autocmd('LspAttach', {
    group = group,
    callback = function(event)
      if not vim.lsp.document_color then
        return
      end

      local client_id = event.data and event.data.client_id
      local client = client_id and vim.lsp.get_client_by_id(client_id)
      if not client then
        return
      end

      if client:supports_method('textDocument/documentColor', event.buf) then
        vim.lsp.document_color.enable(true, { bufnr = event.buf }, opts)
      end
    end,
  })

  vim.api.nvim_create_autocmd('User', {
    group = group,
    pattern = 'FlutterToolsLspAnalysisCompleted',
    callback = function()
      if not vim.lsp.document_color then
        return
      end

      for _, client in ipairs(vim.lsp.get_clients()) do
        for bufnr in pairs(client.attached_buffers) do
          if client:supports_method('textDocument/documentColor', bufnr) then
            vim.lsp.document_color.enable(true, { bufnr = bufnr }, opts)
          end
        end
      end
    end,
  })
end


-- vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile', 'BufEnter' }, {
--   pattern = '*.dart',
--   callback = function()
--     vim.cmd('UltiSnipsAddFiletypes dart-flutter')
--   end,
-- })


-- vim.lsp.document_color which introduced from `neovim v0.12+`
enable_document_color()
