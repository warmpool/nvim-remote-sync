local M = {}

local log_path = vim.fn.stdpath("data") .. "/remote-sync.log"

local level_names = {
  [vim.log.levels.DEBUG] = "DEBUG",
  [vim.log.levels.INFO] = "INFO",
  [vim.log.levels.WARN] = "WARN",
  [vim.log.levels.ERROR] = "ERROR",
}

local function timestamp()
  return os.date("%Y-%m-%d %H:%M:%S")
end

local function write_file(line)
  local fd = io.open(log_path, "a")
  if not fd then
    return
  end
  fd:write(line .. "\n")
  fd:close()
end

function M.log(msg, level)
  level = level or vim.log.levels.INFO
  local name = level_names[level] or "INFO"
  local line = string.format("[%s] [%s] %s", timestamp(), name, msg)
  write_file(line)
  vim.notify(msg, level)
end

function M.info(msg)
  M.log(msg, vim.log.levels.INFO)
end

function M.warn(msg)
  M.log(msg, vim.log.levels.WARN)
end

function M.error(msg)
  M.log(msg, vim.log.levels.ERROR)
end

function M.debug(msg)
  M.log(msg, vim.log.levels.DEBUG)
end

function M.path()
  return log_path
end

return M
