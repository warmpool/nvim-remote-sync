local rsync = require("remote-sync")
local log = require("remote-sync.log")

local subcmds = {
  setup = 'setup',
  sync = 'sync',
  showconfig = 'showconfig',
  toggle = 'toggle'
}

local function user_command(opts)
  -- validate sub command
  local valid_subcmd = false
  local subcmd = ''
  if #opts.fargs == 0 then
    -- no input is given
    valid_subcmd = true
  elseif #opts.fargs == 1 then
    subcmd = opts.fargs[1]
    -- only 1 valid input
    for _, s in pairs(subcmds) do
      if subcmd == s then
        valid_subcmd = true
        break
      end
    end
  end

  if not valid_subcmd then
    local usage = ''
    for _, s in pairs(subcmds) do
      usage = usage .. s .. '|'
    end
    usage = usage:sub(1, #usage - 1)
    log.warn("Usage: RemoteSync <" .. usage .. "> (default: setup)")
    return
  end

  if subcmd == "" then
    -- # do everything if nothing's specified
    rsync.setup()
    rsync.showconfig()
    rsync.toggle_autocmd()
    rsync.rsync_curr_file()
    --
  elseif subcmd == subcmds.setup then
    -- # do only setup
    rsync.setup()
    rsync.showconfig()
  elseif subcmd == subcmds.showconfig then
    -- # show config
    rsync.showconfig()
  elseif subcmd == subcmds.sync then
    -- # sync file
    rsync.rsync_curr_file()
  elseif subcmd == subcmds.toggle then
    rsync.toggle_autocmd()
  end
end

vim.api.nvim_create_user_command("RemoteSync", user_command, {
  desc = "remote-sync commands",
  nargs = "?",
  complete = function()
    return { "setup", "sync", "showconfig", 'toggle' }
  end,
})
