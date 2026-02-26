local log = require("llamaline-nvim.logger")
local u = require("llamaline-nvim.util")

local loop = u.uv

local M = {}

M.show_log = function()
  local log_path = log:get_log_path()
  if log_path ~= nil then
    vim.cmd.tabnew()
    vim.cmd(string.format(":e %s", log_path))
  else
    log:warn("No log file found to show!")
  end
end

M.clear_log = function()
  local log_path = log:get_log_path()
  if log_path ~= nil then
    loop.fs_unlink(log_path)
  else
    log:warn("No log file found to remove!")
  end
end

return M
