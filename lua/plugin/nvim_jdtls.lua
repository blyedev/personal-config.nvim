local M = {}

function M.setup()
  local mason_registry = require 'mason-registry'
  local jdtls = require 'jdtls'

  -- Early termination if jdtls is not installed
  if not mason_registry.is_installed 'jdtls' then
    print 'jdtls is not installed via Mason.'
    return
  end

  local function find_launcher_jar(jdtls_path)
    local plugins_path = jdtls_path .. '/plugins'
    local find_command = "find '" .. plugins_path .. "' -type f -name 'org.eclipse.equinox.launcher_*.jar' -print -quit"

    local handle = io.popen(find_command)

    if handle == nil then
      return
    end

    local result = handle:read '*l' -- Read only the first line of output
    handle:close()

    return result -- directly return the path
  end

  local jdtls_path = mason_registry.get_package('jdtls'):get_install_path()
  local path_to_launcher = find_launcher_jar(jdtls_path)
  local path_to_lsp_server = jdtls_path .. '/config_linux'
  local lombok_path = jdtls_path .. '/lombok.jar'

  local root_markers = { 'mvnw', 'gradlew', 'build.gradle' }
  local root_dir = require('jdtls.setup').find_root(root_markers)

  if root_dir == '' then
    return
  end

  -- TODO: Audit
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
  local workspace_dir = vim.fn.stdpath 'data' .. '/site/java/workspace-root/' .. project_name
  os.execute('mkdir -p ' .. workspace_dir)

  local bundles = {
    vim.fn.glob(vim.fn.expand '~/.config/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.52.0.jar', true),
  }
  -- vim.list_extend(bundles, vim.split(vim.fn.glob(vim.fn.stdpath 'config' .. '/resources/vscode-java-test-main/server/*.jar', true), '\n'))

  local config = {
    cmd = {
      os.getenv 'JAVA_HOME' .. '/bin/java',
      '-Declipse.application=org.eclipse.jdt.ls.core.id1',
      '-Dosgi.bundles.defaultStartLevel=4',
      '-Declipse.product=org.eclipse.jdt.ls.core.product',
      '-Dlog.protocol=true',
      '-Dlog.level=ALL',
      -- '-javaagent:' .. lombok_path, -- Why?
      '-Xmx1g',
      '--add-modules=ALL-SYSTEM',
      '--add-opens',
      'java.base/java.util=ALL-UNNAMED',
      '--add-opens',
      'java.base/java.lang=ALL-UNNAMED',
      '-jar',
      path_to_launcher,
      '-configuration',
      path_to_lsp_server,
      '-data',
      workspace_dir,
    },

    root_dir = root_dir,

    -- Further configuration
    settings = {
      java = {},
    },

    flags = {
      allow_incremental_sync = true,
    },

    init_options = {
      bundles = bundles,
    },
  }

  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'java',
    callback = function()
      jdtls.start_or_attach(config)
      require('jdtls').setup_dap()
      vim.keymap.set('n', '<leader>gf', function()
        require('jdtls').organize_imports()
        vim.lsp.buf.format()
      end, {})
    end,
  })
end

return M
