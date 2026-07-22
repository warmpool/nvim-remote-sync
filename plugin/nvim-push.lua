local push = require("nvim-push")
local log = require("nvim-push.log")

vim.api.nvim_create_user_command("Nvimpush", function(opts)
  if #opts.fargs == 0 then
    push.setup()
    local filepath = vim.api.nvim_buf_get_name(0)
    if filepath == "" then
      log.warn("No file to sync")
      return
    end
    push.rsync_file(filepath)
    return
  elseif #opts.fargs > 1 then
    log.warn("Usage: Nvimpush <setup|sync|showconfig> (default: setup)")
    return
  end

  local subcmd = opts.fargs[1]
  if subcmd == "setup" or subcmd == "" then
    push.setup()
  elseif subcmd == 'showconfig' then
    push.showconfig()
  elseif subcmd == "sync" then
    local filepath = vim.api.nvim_buf_get_name(0)
    if filepath == "" then
      log.warn("No file to sync")
      return
    end
    push.rsync_file(filepath)
  else
    log.warn("Usage: Nvimpush <setup|sync|showconfig> (default: setup)")
  end
end, {
  desc = "nvim-push commands",
  nargs = "?",
  complete = function()
    return { "setup", "sync", "showconfig" }
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("NvimPush", { clear = true }),
  callback = function(args)
    local filepath = vim.api.nvim_buf_get_name(args.buf)
    if filepath == "" then
      return
    end
    push.rsync_file(filepath)
  end,
  desc = "Rsync file on save",
})
