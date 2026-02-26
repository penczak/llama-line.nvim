local api = require("llamaline-nvim.api")

local M = {}

M.setup = function()
  vim.api.nvim_create_user_command("LlamaLineShowLog", function()
    api.show_log()
  end, {})

  vim.api.nvim_create_user_command("LlamaLineClearLog", function()
    api.clear_log()
  end, {})
end

return M
