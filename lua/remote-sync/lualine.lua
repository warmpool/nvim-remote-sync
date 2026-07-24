local M = {}

function M.component()
  return require("remote-sync").lualine_component()
end

return M
