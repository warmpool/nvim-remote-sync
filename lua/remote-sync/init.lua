local config = require("remote-sync.config")
local log = require("remote-sync.log")

local M = {}

local state = {
  status = "off", -- ready | synced | synced | error | off
  config = nil,
  root = nil,
}

function M.get_status()
  return state.status
end

function M.lualine_component(prefix)
  prefix = prefix or 'rs:'
  return function()
    local status = state.status
    return prefix .. status
  end
end

local function set_status(s)
  state.status = s
  vim.schedule(function()
    vim.cmd("redrawstatus")
  end)
end

local function relative_path(root, filepath)
  if filepath:sub(1, #root) == root then
    return filepath:sub(#root + 2)
  end
  return filepath
end

function M.rsync_file(filepath)
  if not state.config then
    return
  end

  set_status("syncing..")
  local root = state.root
  local cfg = state.config
  local rel = relative_path(root, filepath)

  local remote_target = cfg.remote_host .. ":" .. cfg.remote_dir .. "/" .. rel

  local ssh_cmd = "ssh"
  if cfg.ssh_port and cfg.ssh_port ~= 22 then
    ssh_cmd = ssh_cmd .. " -p " .. tostring(cfg.ssh_port)
  end
  if cfg.ssh_key and cfg.ssh_key ~= "" then
    ssh_cmd = ssh_cmd .. " -i " .. cfg.ssh_key
  end

  local args = { "-avp", "-e", ssh_cmd, filepath, remote_target }

  local stderr_output = ""
  local stdout_output = ""

  local stdout = vim.uv.new_pipe()
  local stderr = vim.uv.new_pipe()

  local handle
  handle = vim.uv.spawn("rsync", {
    args = args,
    stdio = { nil, stdout, stderr },
  }, function(code)
    if stdout then
      stdout:close()
    end
    if stderr then
      stderr:close()
    end
    if handle then
      handle:close()
    end

    vim.schedule(function()
      if code == 0 then
        set_status("synced")
        log.info("Synced: " .. rel)
      else
        set_status("error")
        log.error("Sync failed (" .. rel .. "): " .. stderr_output)
      end
    end)
  end)

  if not handle then
    set_status("error")
    vim.schedule(function()
      log.error("Failed to start rsync")
    end)
    return
  end

  if stdout then
    stdout:read_start(function(_, data)
      if data then
        stdout_output = stdout_output .. data
      end
    end)
  end

  if stderr then
    stderr:read_start(function(_, data)
      if data then
        stderr_output = stderr_output .. data
      end
    end)
  end
end

function M.rsync_curr_file()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    log.warn("No file to sync")
    return
  end
  M.rsync_file(filepath)
end

function M.showconfig()
  if not state.config then
    print("remote-sync: config is not setup yet")
    return
  end
  local cfg = state.config
  local lines = {
    "remote-sync config:",
    "  project root: " .. (state.root or "not set"),
    "  remote_host:  " .. (cfg.remote_host or "not set"),
    "  remote_dir:   " .. (cfg.remote_dir or "not set"),
    "  ssh_port:     " .. (cfg.ssh_port or "22"),
    "  ssh_key:      " .. (cfg.ssh_key or "not set"),
    "  rsync_flags:  " .. (cfg.rsync_flags or "not set"),
  }
  print(table.concat(lines, "\n"))
end

function M.setup()
  local root = config.find_project_root()
  state.root = root

  local cfg, err = config.load(root)
  if cfg then
    state.config = cfg
    set_status('ready')
    return
  end

  log.info(err)
  config.prompt(function(new_cfg, should_save)
    if new_cfg == nil then
      return -- setup cancelled
    end
    if should_save then
      local ok, save_err = config.save_to_disk(root, new_cfg)
      if ok then
        log.info("Config saved to " .. config.config_path(root))
      else
        log.error(save_err)
        return -- setup failed to save
      end
    end
    state.config = new_cfg
    set_status('ready')
  end)
end

-- auto command

local autocmd_id = nil
local function autocmd_on()
  return vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("RemoteSync", { clear = true }),
    callback = function(args)
      local filepath = vim.api.nvim_buf_get_name(args.buf)
      if filepath == "" then
        return
      end
      M.rsync_file(filepath)
    end,
    desc = "Rsync file on save",
  })
end

function M.toggle_autocmd()
  if autocmd_id == nil then
    autocmd_id = autocmd_on()
    log.info('autocmd on id=(' .. autocmd_id .. ')')
    set_status('ready')
  else
    vim.api.nvim_del_autocmd(autocmd_id)
    autocmd_id = nil
    log.info('autocmd off')
    set_status('off')
  end
end

return M
