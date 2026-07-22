local log = require("nvim-push.log")
local M = {}

local config_filename = ".nvim-push.json"

local required_fields = { "remote_host", "remote_dir" }

local optional_fields = {
  ssh_port = 22,
  ssh_key = "",
  rsync_flags = "-avp",
}

function M.config_path(root)
  return root .. "/" .. config_filename
end

function M.find_project_root()
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")
  if vim.v.shell_error == 0 and git_root[1] and git_root[1] ~= "" then
    return git_root[1]
  end
  return vim.fn.getcwd()
end

function M.load(root)
  local path = M.config_path(root)
  local fd = io.open(path, "r")
  if not fd then
    return nil, "Config file not found: " .. path
  end
  local content = fd:read("*a")
  fd:close()

  local ok, parsed = pcall(vim.json.decode, content)
  if not ok or type(parsed) ~= "table" then
    return nil, "Failed to parse config file: " .. path
  end

  local err = M.validate(parsed)
  if err then
    return nil, err
  end

  return parsed, nil
end

function M.validate(config)
  for _, field in ipairs(required_fields) do
    if not config[field] or config[field] == "" then
      return "Missing required field: " .. field
    end
  end
  return nil
end

function M.fill_defaults(config)
  local result = vim.tbl_deep_extend("force", {}, config)
  for field, default in pairs(optional_fields) do
    if result[field] == nil or result[field] == "" then
      result[field] = default
    end
  end
  return result
end

function M.save_to_disk(root, config)
  local path = M.config_path(root)
  local fd = io.open(path, "w")
  if not fd then
    return false, "Failed to write config to: " .. path
  end
  fd:write(vim.json.encode(config, { indent = "  " }))
  fd:close()
  return true, nil
end

function M.prompt(callback)
  local config = {}
  local fields = {
    { key = "remote_host", prompt = "Remote host (user@hostname): " },
    { key = "remote_dir",  prompt = "Remote directory: " },
    { key = "ssh_port",    prompt = "SSH port (default 22): ",      optional = true },
    { key = "ssh_key",     prompt = "SSH key path (optional): ",    optional = true },
    { key = "rsync_flags", prompt = "Rsync flags (default -avp): ", optional = true },
  }

  local function ask(i)
    if i > #fields then -- ask to save the file if all fields are filled
      config = M.fill_defaults(config)
      local function ask_save(cb)
        vim.ui.input({ prompt = "Save config to " .. config_filename .. " ? (y/n): " }, function(input)
          if input == nil then
            return cb(nil) -- C-c pressed, cancel
          end
          if input == "y" then
            cb(config, true)
          elseif input == "n" then
            cb(config, false)
          else
            log.warn("Please enter 'y' or 'n'.")
            return ask_save(cb)
          end
        end)
      end
      ask_save(callback)
      return
    end

    local field = fields[i] -- ask for each field
    vim.ui.input({ prompt = field.prompt }, function(input)
      if input == nil then
        return callback(nil) -- C-c pressed, cancel setup
      end
      if input == "" then
        if not field.optional then -- keep asking if nothing is entered
          log.warn("Field '" .. field.key .. "' is required.")
          return ask(i)
        end
      else
        config[field.key] = input
      end
      return ask(i + 1)
    end)
  end

  ask(1)
end

return M
