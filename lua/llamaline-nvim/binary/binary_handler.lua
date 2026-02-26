local api = vim.api
local u = require("llamaline-nvim.util")
local loop = u.uv
local config = require("llamaline-nvim.config")
local preview = require("llamaline-nvim.completion_preview")
local log = require("llamaline-nvim.logger")

local BinaryLifecycle = {}

BinaryLifecycle.HARD_SIZE_LIMIT = 10e6

function BinaryLifecycle:is_running()
  return true
end

function BinaryLifecycle:start_binary()
  -- no op
end

function BinaryLifecycle:stop_binary()
  -- no op
end

---@param buffer integer
---@param event_type "text_changed" | "cursor" | "manual"
function BinaryLifecycle:on_update(buffer, event_type)
  if event_type == "cursor" then
    preview:dispose_inlay()
    return
  end

  local cursor = api.nvim_win_get_cursor(0)
  self:provide_inline_completion_items(buffer, cursor)
end

function BinaryLifecycle:same_context(context)
  if self.last_context == nil then
    return false
  end
  return context.cursor[1] == self.last_context.cursor[1]
      and context.cursor[2] == self.last_context.cursor[2]
      and context.file_name == self.last_context.file_name
      and context.document_text == self.last_context.document_text
end

local function handle_completion(buffer, cursor, completion)
  if not vim.api.nvim_buf_is_valid(buffer) then
    print("not valid buffer")
    return
  end

  local text_split = u.get_text_before_after_cursor(cursor)

  preview:render_with_inlay(
    buffer,
    0,
    completion,
    text_split.text_after_cursor,
    text_split.text_before_cursor
  )
end

function BinaryLifecycle:provide_inline_completion_items(buffer, cursor)
  local prefix = u.get_cursor_prefix(buffer, cursor, 30)
  local suffix = u.get_cursor_suffix(buffer, cursor, 30)

  local prompt = ""
  if config.fim_style == "<PRE>" then
    prompt = "<PRE> " .. prefix .. " <SUF> " .. suffix .. " <MID>"
  elseif config.fim_style == "<|fim_prefix|>" then
    prompt = "<|fim_prefix|>" .. prefix .. "<|fim_suffix|>" .. suffix .. "<|fim_middle|>"
  else
    print("config.fim_style had an unsupported value")
    return
  end
  print("prmptd")

  local body = vim.json.encode({
    model = config.ollama_model,
    prompt = prompt,
    stream = false,
  })

  vim.system({
    "curl",
    "-s",
    "-X", "POST",
    "http://localhost:11434/api/generate",
    "-d", body,
  }, { text = true }, function(obj)
    print("ollama returned")
    if not obj.stdout then
      print("not stdout")
      return
    end
    -- print(obj.stdout)

    local ok, decoded = pcall(vim.json.decode, obj.stdout)
    if not ok or not decoded.response then
      print("not ok")
      return
    end

    local completion = decoded.response:gsub("<EOT>", "")
    completion = completion:gsub("^%s+", "")
    -- print(completion)

    vim.schedule(function()
      handle_completion(buffer, cursor, completion)
    end)
  end)
end

return BinaryLifecycle
