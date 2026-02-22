local api = require("llamaline.nvim.api")
local log = require("llamaline.nvim.logger")

local M = {}

M.setup = function()
  vim.api.nvim_create_user_command("LlamaLineStart", function()
    api.start()
  end, {})

  vim.api.nvim_create_user_command("LlamaLineStop", function()
    api.stop()
  end, {})

  vim.api.nvim_create_user_command("LlamaLineRestart", function()
    api.restart()
  end, {})

  vim.api.nvim_create_user_command("LlamaLineToggle", function()
    api.toggle()
  end, {})

  vim.api.nvim_create_user_command("LlamaLineStatus", function()
    log:trace(string.format("LlamaLine is %s", api.is_running() and "running" or "not running"))
  end, {})

  vim.api.nvim_create_user_command("LlamaLineUseFree", function()
    api.use_free_version()
  end, {})

  vim.api.nvim_create_user_command("LlamaLineUsePro", function()
    api.use_pro()
  end, {})

  vim.api.nvim_create_user_command("LlamaLineLogout", function()
    api.logout()
  end, {})

  vim.api.nvim_create_user_command("LlamaLineShowLog", function()
    api.show_log()
  end, {})

  vim.api.nvim_create_user_command("LlamaLineClearLog", function()
    api.clear_log()
  end, {})
end

return M
