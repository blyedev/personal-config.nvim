-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    dap.set_log_level 'TRACE'

    require('mason-nvim-dap').setup {
      automatic_setup = true,
      handlers = {},
      automatic_installation = true,
      ensure_installed = {
        'delve',
        'java-debug-adapter',
      },
    }

    dap.adapters.java = function(callback)
      -- callback {
      --   type = 'server',
      --   host = '127.0.0.1',
      --   port = 5005,
      -- }
      -- Ensure that an LSP client that can handle the java debug request is active
      local clients = vim.lsp.get_active_clients()
      if not clients then
        print 'No active LSP client available'
        return
      end

      -- Find a Java LSP client
      local client = nil
      for _, lsp_client in ipairs(clients) do
        if lsp_client.name == 'jdtls' then -- assuming the Java LSP client is named 'jdtls'
          client = lsp_client
          break
        end
      end

      if not client then
        print 'Java LSP client not available'
        return
      end

      -- Send a request to the Java LSP to start a debug session
      local params = {
        -- You might need to adjust these parameters based on your project's specifics
        -- This is just an example and may not directly apply
        command = 'vscode.java.startDebugSession',
      }

      client.request('workspace/executeCommand', params, function(err, result)
        if err then
          print('Error starting debug session: ' .. err.message)
          return
        end

        local port = result and result.port
        if port then
          callback {
            type = 'server',
            host = '127.0.0.1',
            port = port,
          }
        else
          print 'Failed to get debugging port from LSP'
        end
      end, vim.api.nvim_get_current_buf())
    end

    dap.configurations.java = {
      {
        type = 'java',
        request = 'attach',
        name = 'Debug (Attach) - Gradle',
        hostName = '0.0.0.0',
        port = 5005, -- Ensure this matches the port used in Gradle settings
      },
    }

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup()
  end,
}
